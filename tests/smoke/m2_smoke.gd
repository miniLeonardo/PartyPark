extends Node
## Automatischer Durchlauf für M2/M3: Titel → Beitritt → Hauptmenü → komplettes Schnellturnier → Freies Spiel
## mit allen Minispielen → Optionen. Ein Tastaturspieler (bleibt im Spiel untätig), Rest Computer.
## Start (schnell, ohne Echtzeit): godot --headless --path . --fixed-fps 60 -- --smoke-m2
## Optional: --shots=<ordner> speichert Bildschirmfotos (nur mit Renderer).

var _failures: int = 0
var _checks: int = 0
var _shot_dir: String = ""
var _shot_count: int = 0
## --short: Zeitlimits der Minispiele auf 20 s kürzen (für langsame Läufe mit Renderer).
var _short: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--shots="):
			_shot_dir = arg.trim_prefix("--shots=")
		if arg == "--short":
			_short = true
	_run.call_deferred()


func _run() -> void:
	print("SMOKE M2: Start")
	await _frames(10)
	await _shot("titel")
	await _tap_key(KEY_SPACE)
	await _frames(5)
	_check(get_tree().current_scene.name == "JoinScreen", "Titel → Beitritt")
	PlayerRoster.cpu_fill_enabled = true
	await _tap_key(KEY_ESCAPE)
	await _frames(5)
	_check(get_tree().current_scene.name == "MainMenu", "Beitritt → Hauptmenü")
	await _shot("hauptmenue")

	# --- Schnellturnier ---
	await _tap_key(KEY_SPACE)
	await _frames(5)
	var tournament: Node = get_tree().current_scene
	_check(tournament.name == "Tournament", "Schnellturnier startet")
	var rounds: int = int(tournament.get("rounds_total"))
	for r: int in rounds:
		var ok: bool = await _play_round(func() -> MatchFlow: return tournament.get("flow") as MatchFlow, "Turnier Runde %d" % (r + 1))
		if not ok:
			_finish()
			return
		await _wait_until(func() -> bool: return int(tournament.get("state")) != 0, 600)
		await _frames(60)
		if r == 0:
			await _shot("zwischenstand")
		await _tap_key(KEY_SPACE)
		await _frames(5)
	await _wait_until(func() -> bool: return int(tournament.get("state")) == 2, 300)
	_check(int(tournament.get("state")) == 2, "Siegerehrung erreicht")
	await _frames(120)
	await _shot("siegerehrung")
	var history: Array = tournament.get("history")
	_check(history.size() == rounds, "%d Runden gespielt" % rounds)
	for i: int in range(1, history.size()):
		_check(history[i]["format"] != history[i - 1]["format"], "Runde %d: anderes Format als davor" % (i + 1))
	var totals: Dictionary = tournament.get("totals")
	var sum: int = 0
	for index: int in totals:
		sum += int(totals[index])
	print("  Gesamtpunkte: %s" % str(totals))
	_check(sum > 0, "Punkte wurden vergeben")
	await _tap_key(KEY_SPACE)
	await _frames(10)
	_check(get_tree().current_scene.name == "MainMenu", "Siegerehrung → Hauptmenü")

	# --- Freies Spiel: jedes Minispiel einmal ---
	await _tap_key(KEY_S)
	await _tap_key(KEY_SPACE)
	await _frames(5)
	var free_play: Node = get_tree().current_scene
	_check(free_play.name == "FreePlay", "Freies Spiel startet")
	await _shot("freies_spiel")
	var infos: Array = free_play.get("_infos")
	for i: int in infos.size():
		var info: MinigameInfo = infos[i]
		if i > 0:
			await _tap_key(KEY_S)
		await _tap_key(KEY_SPACE)
		await _frames(3)
		if int(free_play.get("state")) == 1:
			await _shot("teams_%s" % info.id)
			await _tap_key(KEY_SPACE)
		var ok: bool = await _play_round(func() -> MatchFlow: return free_play.get("flow") as MatchFlow, "Freies Spiel %s" % info.display_name)
		if not ok:
			_finish()
			return
		await _wait_until(func() -> bool: return int(free_play.get("state")) == 0, 300)
		_check(int(free_play.get("state")) == 0, "%s: zurück zur Liste" % info.display_name)
	await _tap_key(KEY_E)
	await _frames(5)
	_check(get_tree().current_scene.name == "MainMenu", "Freies Spiel → Hauptmenü")

	# --- Optionen ---
	for i: int in 3:
		await _tap_key(KEY_S)
	await _tap_key(KEY_SPACE)
	await _frames(5)
	_check(get_tree().current_scene.name == "OptionsMenu", "Optionen öffnen")
	await _shot("optionen")
	var before: int = Settings.cpu_difficulty
	await _tap_key(KEY_A)
	_check(Settings.cpu_difficulty == maxi(0, before - 1), "Links senkt die Computer-Stärke")
	await _tap_key(KEY_D)
	_check(Settings.cpu_difficulty == before, "Rechts erhöht sie wieder")
	await _tap_key(KEY_E)
	await _frames(5)
	_check(get_tree().current_scene.name == "MainMenu", "Optionen → Hauptmenü")
	_finish()


## Spielt eine Runde über den MatchFlow: Bereit drücken, Spiel abwarten, Ergebnis bestätigen.
func _play_round(get_flow: Callable, label: String) -> bool:
	await _wait_until(func() -> bool: return get_flow.call() != null, 300)
	var flow: MatchFlow = get_flow.call()
	if flow == null:
		_check(false, "%s: MatchFlow vorhanden" % label)
		return false
	var game_name: String = flow.info.display_name
	if _short:
		flow.minigame.time_limit = minf(flow.minigame.time_limit, 20.0)
	await _wait_until(func() -> bool: return flow.phase == MatchFlow.Phase.RULES or flow.phase >= MatchFlow.Phase.COUNTDOWN, 600)
	if flow.phase == MatchFlow.Phase.RULES:
		await _shot("regeln_%s" % flow.info.id)
		await _tap_key(KEY_SPACE)
	await _wait_until(func() -> bool: return flow.phase >= MatchFlow.Phase.PLAY, 600)
	await _frames(240)
	await _shot("spiel_%s" % flow.info.id)
	var limit_frames: int = int((flow.minigame.time_limit + 20.0) * 60.0)
	await _wait_until(func() -> bool: return not is_instance_valid(flow) or flow.phase >= MatchFlow.Phase.RESULT, limit_frames)
	if not is_instance_valid(flow) or flow.phase < MatchFlow.Phase.RESULT:
		_check(false, "%s (%s): Spiel endet" % [label, game_name])
		return false
	var played: float = flow.minigame.elapsed
	_check(true, "%s (%s): %s nach %.0f s" % [label, game_name, flow.result.headline, played])
	await _shot("ergebnis_%s" % flow.info.id)
	await _frames(60)
	await _tap_key(KEY_SPACE)
	await _frames(5)
	return true


func _finish() -> void:
	print("SMOKE M2: %d von %d Prüfungen bestanden" % [_checks - _failures, _checks])
	print("SMOKE M2: %s" % ("OK" if _failures == 0 else "FEHLER"))
	get_tree().paused = false
	get_tree().quit(0 if _failures == 0 else 1)


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if condition:
		print("  ok    %s" % description)
	else:
		_failures += 1
		print("  FEHLER %s" % description)


func _wait_until(condition: Callable, max_frames: int) -> void:
	for i: int in max_frames:
		if condition.call():
			return
		await _frames(1)


func _shot(file_name: String) -> void:
	if _shot_dir.is_empty() or DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	_shot_count += 1
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png(_shot_dir.path_join("%02d_%s.png" % [_shot_count, file_name]))


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().process_frame
		await get_tree().physics_frame


func _key(keycode: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	event.keycode = keycode
	event.pressed = pressed
	Input.parse_input_event(event)


func _tap_key(keycode: Key) -> void:
	_key(keycode, true)
	await _frames(3)
	_key(keycode, false)
	await _frames(3)
