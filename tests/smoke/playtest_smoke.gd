extends Node
## Spieltest-Statistik für alle Minispiele: jedes Spiel mehrfach mit Computern in allen drei Stärken,
## dazu Läufe, in denen Platz 1 untätig bleibt (wie ein Mensch, der nichts drückt).
## Ausgabe je Spiel: Dauer, Anteil Zeitablauf, Unentschieden, Siegverteilung nach Platz und Team,
## Ergebnis des Untätigen. Kein Bestanden/Fehler außer „jede Runde endet“; die Zahlen sind zum Lesen.
## Start: godot --headless --path . --fixed-fps 60 -- --smoke-playtest [--game=<id>] [--runs=<n>] [--shots=<ordner>]

var _only: String = ""
var _runs: int = 6
var _shot_dir: String = ""
var _failures: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--game="):
			_only = arg.trim_prefix("--game=")
		elif arg.begins_with("--runs="):
			_runs = int(arg.trim_prefix("--runs="))
		elif arg.begins_with("--shots="):
			_shot_dir = arg.trim_prefix("--shots=")
	_run.call_deferred()


func _run() -> void:
	print("PLAYTEST: Start (%d Läufe je Spiel + %d mit untätigem Platz 1)" % [_runs, maxi(2, _runs / 2)])
	get_tree().current_scene.queue_free()
	await get_tree().process_frame
	var sandbox := MinigameSandbox.new()
	add_child(sandbox)
	for info: MinigameInfo in MinigameRegistry.infos:
		if _only != "" and String(info.id) != _only:
			continue
		for format: int in info.formats:
			await _test_game(sandbox, info, format)
	print("PLAYTEST: %s" % ("OK" if _failures == 0 else "FEHLER (%d Runden ohne Ende)" % _failures))
	get_tree().quit(0 if _failures == 0 else 1)


func _test_game(sandbox: MinigameSandbox, info: MinigameInfo, format: int) -> void:
	var durations: Array[float] = []
	var timeouts: int = 0
	var draws: int = 0
	var wins_by_slot: Array[int] = [0, 0, 0, 0]
	var solo_wins: int = 0
	var coop_wins: int = 0
	var summaries: PackedStringArray = []
	var idle_places: Array[int] = []
	var total: int = _runs + maxi(2, _runs / 2)
	for run: int in total:
		var idle: bool = run >= _runs
		var difficulty: int = run % 3
		sandbox.start(info, format, difficulty, -1.0, 1000 + run * 77)
		if idle:
			# Platz 1 wird „menschlich“: die Computer-Steuerung des Spiels lässt ihn dann in Ruhe
			sandbox.slots[0].is_cpu = false
		var limit: float = sandbox.minigame.time_limit
		var frames: int = 0
		var shot_taken: bool = false
		while sandbox.running and float(frames) / 60.0 < limit + 10.0:
			await get_tree().physics_frame
			frames += 1
			if _shot_dir != "" and run == 0 and not shot_taken and frames == 60 * 6:
				shot_taken = true
				await _shot("%s_%d" % [info.id, format])
		var seconds: float = float(frames) / 60.0
		var result: MinigameResult = sandbox.result
		if result == null:
			_failures += 1
			print("  FEHLER: %s Lauf %d endet nicht" % [info.display_name, run])
		elif idle:
			idle_places.append(result.get_place(0))
		else:
			durations.append(seconds)
			if seconds >= limit - 0.5:
				timeouts += 1
			if result.is_draw:
				draws += 1
			if result.coop_won:
				coop_wins += 1
			for w: int in result.get_winners():
				wins_by_slot[w] += 1
			var ctx: MinigameContext = sandbox.minigame.context
			if ctx.solo >= 0 and result.get_place(ctx.solo) == 1:
				solo_wins += 1
			if sandbox.minigame.has_method("debug_summary"):
				summaries.append(String(sandbox.minigame.call("debug_summary")))
		sandbox.stop()
		await get_tree().physics_frame

	durations.sort()
	var avg: float = 0.0
	for d: float in durations:
		avg += d
	avg /= maxf(1.0, float(durations.size()))
	print("== %s (%s), Zeitlimit %d s" % [info.display_name, TeamFormat.display_name(format), int(sandbox_limit(info))])
	if not durations.is_empty():
		print("   Dauer: min %.0f s, Mittel %.0f s, max %.0f s; Zeitablauf %d/%d; Unentschieden %d" % [durations[0], avg, durations[-1], timeouts, durations.size(), draws])
	print("   Siege nach Platz: %s%s" % [str(wins_by_slot), ("; Solo gewinnt %d/%d" % [solo_wins, durations.size()]) if format == TeamFormat.Format.ONE_VS_THREE else (("; Team gewinnt %d/%d" % [coop_wins, durations.size()]) if format == TeamFormat.Format.COOP_VS_CPU else "")])
	print("   Untätiger Platz 1 landet auf Platz: %s" % str(idle_places))
	if not summaries.is_empty():
		print("   Details: %s" % " | ".join(summaries.slice(0, 3)))


func sandbox_limit(info: MinigameInfo) -> float:
	var scene: Minigame = (load(info.scene_path) as PackedScene).instantiate() as Minigame
	var limit: float = scene.time_limit
	scene.free()
	return limit


func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	if image == null:
		return
	DirAccess.make_dir_recursive_absolute(_shot_dir)
	image.save_png("%s/%s.png" % [_shot_dir, name])
