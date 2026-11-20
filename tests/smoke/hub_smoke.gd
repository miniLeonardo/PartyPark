extends Node
## Smoke-Test für den Freizeitpark-Hub.
## Start: godot --headless --path . --fixed-fps 60 -- --smoke-hub   (optional --shots=<ordner>)
##
## Seit 2026-11-20 spielt der Test die Geräte mit echter Eingabe und Physik durch, statt Figuren an
## ihr Ziel zu teleportieren (so blieb der unlösbare alte Turm unbemerkt). Gesteuert wird über eine
## AIInput, die anstelle der Tastatur im Spielerplatz steckt; Sprung und Bewegung laufen durch
## dieselben Fähigkeiten wie beim Menschen.

var _failures: int = 0
var _checks: int = 0
var _shot_dir: String = ""
var _ai1: AIInput
var _ai2: AIInput


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--shots="):
			_shot_dir = arg.trim_prefix("--shots=")
	_run.call_deferred()


func _run() -> void:
	print("SMOKE HUB: Start")
	await _frames(5)

	# Zwei Menschen (Tastatur links/rechts), Computer im Roster wie im echten Ablauf
	PlayerRoster.clear_cpus()
	for source: InputSource in InputRouter.get_sources():
		if source is KeyboardInput:
			PlayerRoster.join(source)
	PlayerRoster.fill_with_cpu()
	_check(PlayerRoster.get_human_slots().size() == 2, "2 menschliche Spieler beigetreten")

	Game.start_hub()
	await _frames(10)
	var hub: Hub = get_tree().current_scene as Hub
	_check(hub != null, "Hub-Szene geladen")
	if hub == null:
		_finish()
		return
	_check(hub.players.size() == 2, "Nur menschliche Figuren im Park (D124): %d" % hub.players.size())
	_check(hub.camera is HubCamera, "HubCamera vorhanden")

	var terrain: Node = hub.get_node("Terrain")
	var scenery: Node = hub.get_node("Scenery")
	var pg: Node = terrain.get_node("Playground")
	_check(terrain.get_node_or_null("CentralPlaza") != null, "Plaza vorhanden")
	_check(pg.get_node_or_null("TowerLift") == null, "Alter Turm-Lift entfernt")

	var p1: Player = hub.players[0]
	var p2: Player = hub.players[1]
	_ai1 = _take_over(p1)
	_ai2 = _take_over(p2)
	_park(p2, Vector3(6, 0.5, 6))

	if not _shot_dir.is_empty():
		DirAccess.make_dir_recursive_absolute(_shot_dir)
		await _frames(20)
		await _shot("01_plaza")

	# --- Stufenhilfe: auf das Karussell (0,4 m Kante) laufen, ohne zu springen ---
	_park(p1, Vector3(43.5, 0.5, 0.0))
	_park(p2, Vector3(43.5, 0.5, 2.0))
	await _frames(10)
	await _walk_to(p1, _ai1, Vector3(37.5, 0, 0.0), 90)
	_check(p1.global_position.y > 0.55, "Stufenhilfe: Figur läuft ohne Sprung aufs Karussell (y=%.2f)" % p1.global_position.y)

	# --- Trampolin: aus 3 m fallen lassen, Rückprall messen ---
	var tramp: HubTrampoline = pg.get_node("TrampolineEast") as HubTrampoline
	_park(p1, tramp.global_position + Vector3(0, 3.0, 0))
	var peak_vy: float = 0.0
	for i: int in 90:
		await _frames(1)
		peak_vy = maxf(peak_vy, p1.velocity.y)
	_check(peak_vy > 12.0, "Trampolin wirft beim Landen hoch (%.1f m/s)" % peak_vy)
	_park(p1, tramp.global_position + Vector3(4.5, 0.5, 0))
	await _walk_to(p1, _ai1, tramp.global_position + Vector3(0, 0, 0), 60)
	_check(p1.global_position.y > tramp.global_position.y + 1.0, "Trampolin: Wer hinaufläuft, wird ebenfalls hochgeworfen")

	# --- Rutsche: oben starten, hinunterrutschen, Schanze ---
	var slide: HubSlide = pg.get_node("Slide") as HubSlide
	var top_local := Vector3(0, slide.slide_height + 0.5, slide.slide_length * 0.5 - 1.8 + 1.0)
	_park(p1, slide.to_global(top_local))
	_park(p2, slide.to_global(top_local) + Vector3(0, 0, 0))
	_park(p2, Vector3(-28, 0.5, 8))
	await _frames(10)
	var max_speed: float = 0.0
	var max_air: float = 0.0
	var target: Vector3 = slide.to_global(Vector3(0, 0, -slide.slide_length))
	for i: int in 240:
		_steer(p1, _ai1, target)
		await _frames(1)
		max_speed = maxf(max_speed, Vector2(p1.velocity.x, p1.velocity.z).length())
		if not p1.is_on_floor():
			max_air = maxf(max_air, p1.velocity.y)
	_ai1.release_all()
	_check(max_speed > 10.0, "Rutsche beschleunigt (%.1f m/s)" % max_speed)
	_check(max_air > 5.0, "Schanze wirft am Ende hoch (%.1f m/s)" % max_air)
	_check(slide.to_local(p1.global_position).z < -slide.slide_length * 0.5, "Figur landet hinter der Schanze")

	# --- Kletterturm: jeden Sprung mit echter Eingabe nachspielen ---
	var tower: HubTower = pg.get_node("ClimbingTower") as HubTower
	_park(p2, tower.to_global(Vector3(0, 0.5, 13.0)))
	await _climb_tower(p1, tower)

	# Krone: oben hinlaufen und aufsetzen
	_park(p1, tower.to_global(Vector3(0, HubTower.LEVEL_HEIGHT * 3.0 + 0.3, 2.5)))
	_park(p2, tower.to_global(Vector3(2.6, HubTower.LEVEL_HEIGHT * 3.0 + 0.3, 0.8)))
	await _frames(10)
	await _walk_to(p1, _ai1, tower.crown.summit_home_position, 90)
	_check(tower.crown.current_state == HubCrown.State.WORN and tower.crown.wearer == p1, "Krone wird oben durch Hinlaufen aufgesetzt")
	if not _shot_dir.is_empty():
		await _frames(20)
		await _shot("02_turm_spitze")
	tower.crown.drop_from_push(p2)
	for i: int in 240:
		await _frames(1)
	var crown_rests: bool = tower.crown.current_state == HubCrown.State.WORN or (tower.crown.current_state == HubCrown.State.DROPPED and tower.crown._velocity == Vector3.ZERO)
	_check(crown_rests, "Krone fliegt nach Schubser weg und bleibt liegen oder wird aufgefangen")
	_check(tower.crown.global_position.y > 0.0, "Krone fällt nicht durch den Boden (y=%.1f)" % tower.crown.global_position.y)
	tower.crown.reset_to_summit()

	# Netz: Sturz aus Passage 2 landet auf der 6-m-Etage
	_park(p1, tower.to_global(HubTower.step_position(1, 6) + Vector3(0, 0.3, 0)))
	await _frames(5)
	# Fehlsprung nachstellen: ohne Sprung vorwärts in die Lücke zur nächsten (höheren) Stufe laufen
	var next_step: Vector3 = tower.to_global(HubTower.step_position(1, 7))
	for i: int in 30:
		_steer(p1, _ai1, next_step)
		await _frames(1)
	_ai1.release_all()
	await _frames(90)
	var local_y: float = tower.to_local(p1.global_position).y
	_check(absf(local_y - HubTower.LEVEL_HEIGHT) < 0.4, "Sturz aus Passage 2 endet auf dem 6-m-Netz (y=%.2f)" % local_y)

	if not _shot_dir.is_empty():
		_park(p1, tower.to_global(HubTower.step_position(0, 5) + Vector3(0, 0.3, 0)))
		_park(p2, tower.to_global(HubTower.step_position(1, 3) + Vector3(0, 0.3, 0)))
		await _frames(40)
		await _shot("03_turm_klettern")

	# --- Kamera-Leine (D121) ---
	_park(p1, Vector3(-10, 0.5, 0))
	_park(p2, Vector3(20, 0.5, 0))
	await _frames(20)
	var x_before: float = p2.global_position.x
	_ai2.move = p2.world_to_input(Vector3.RIGHT)
	await _frames(60)
	_ai2.release_all()
	_check(p2.global_position.x < x_before + 0.5, "Leine: Spieler 2 kann nicht weiter weg (%.1f → %.1f)" % [x_before, p2.global_position.x])
	_ai2.move = p2.world_to_input(Vector3.LEFT)
	await _frames(20)
	_ai2.release_all()
	_check(p2.global_position.x < x_before - 1.0, "Leine: Zurücklaufen geht")
	if not _shot_dir.is_empty():
		await _frames(30)
		await _shot("04_leine")

	# Kamera nimmt Kletterhöhe ins Bild
	_park(p1, tower.to_global(Vector3(0, HubTower.LEVEL_HEIGHT * 3.0 + 0.3, 1.0)))
	_park(p2, tower.to_global(Vector3(0, 0.5, 14.0)))
	await _frames(150)
	var cam: Camera3D = hub.camera
	var on_screen: bool = true
	var rect: Rect2 = cam.get_viewport().get_visible_rect()
	for p: Player in [p1, p2]:
		var head: Vector3 = p.global_position + Vector3.UP * 1.5
		var sp: Vector2 = cam.unproject_position(head)
		if cam.is_position_behind(head) or not rect.has_point(sp):
			on_screen = false
	_check(on_screen, "Kamera zeigt Spieler auf der Turmspitze und am Boden gleichzeitig")

	# --- Pads (D123): Countdown nur, wenn alle drauf sind ---
	var attractions: Node = terrain.get_node("Attractions")
	var station: HubMinigameStation = attractions.get_node("Station_bumper_cars") as HubMinigameStation
	var pad: HubActivationPad = station.activation_pad
	_park(p1, pad.global_position + Vector3(0, 0.5, 0))
	_park(p2, Vector3(0, 0.5, 4))
	await _frames(10)
	_check(not pad._is_counting, "Pad: ein Spieler allein startet nichts")
	_ai1.tap(InputBindings.JUMP)
	await _frames(30)
	_check(not pad._is_counting, "Pad: Springen (A) startet kein Spiel mehr")
	_park(p2, pad.global_position + Vector3(0.8, 0.5, 0))
	await _frames(10)
	_check(pad._is_counting, "Pad: Countdown läuft, wenn alle drauf sind")
	_park(p2, Vector3(0, 0.5, 4))
	await _frames(10)
	_check(not pad._is_counting, "Pad: Countdown bricht ab, sobald einer runtergeht")

	var pavilion: HubTournamentPavilion = attractions.get_node("TournamentPavilion") as HubTournamentPavilion
	_check(pavilion.activation_pad.global_position.y > pavilion.global_position.y + 0.38, "Turnier-Pad liegt auf dem Podest, nicht darin")

	# --- Minispiel in eigener Szene und zurück neben die Bude (D125) ---
	var return_pos: Vector3 = station.get_return_position()
	hub.play_minigame(station.info, return_pos)
	await _frames(15)
	_check(get_tree().current_scene != null and get_tree().current_scene.name == "HubMinigame", "Minispiel läuft in eigener Szene")
	var flow_ok: bool = false
	if get_tree().current_scene != null:
		var mf: Node = get_tree().current_scene.get_node_or_null("MatchFlow")
		flow_ok = get_tree().current_scene.get("flow") != null or mf != null
	_check(flow_ok, "MatchFlow im Minispiel aktiv")
	_check(get_tree().get_nodes_in_group(Player.GROUP).size() == 4, "Minispiel mit 4 Figuren (Computer aufgefüllt): %d" % get_tree().get_nodes_in_group(Player.GROUP).size())
	Game.return_to_hub()
	await _frames(15)
	hub = get_tree().current_scene as Hub
	_check(hub != null, "Zurück im Park")
	if hub != null:
		_check(hub.players.size() == 2, "Wieder nur menschliche Figuren im Park")
		_check(hub.players[0].global_position.distance_to(return_pos) < 3.0, "Rückkehr neben die Bude, nicht aufs Pad")
		var new_station: HubMinigameStation = hub.get_node("Terrain/Attractions/Station_bumper_cars") as HubMinigameStation
		await _frames(30)
		_check(not new_station.activation_pad._is_counting, "Kein sofortiger Neustart nach der Rückkehr")

	# Rückweg nach Turnier-Abbruch: Flag wird zurückgesetzt
	Game.launched_from_hub = true
	Game.goto_main_menu()
	await _frames(5)
	_check(not Game.launched_from_hub, "Abbruch ins Hauptmenü setzt launched_from_hub zurück")

	_finish()


# --- Turm ---

func _climb_tower(player: Player, tower: HubTower) -> void:
	var steps: int = HubTower.STEPS_PER_PASSAGE
	var lift: HubMovingPlatform = tower.get_node_or_null("P2_Lift") as HubMovingPlatform
	var failed: int = 0
	for passage: int in 3:
		# Anlauf: vom Boden bzw. von der Etage zur ersten Stufe
		var first: Vector3 = HubTower.step_position(passage, 0)
		var direction: float = -1.0 if passage % 2 == 0 else 1.0
		var r: float = HubTower.PATH_RADII[passage]
		var start_angle: float = HubTower.step_angle(passage, 0) - direction * 2.4 / r
		var start := Vector3(cos(start_angle) * r, float(passage) * HubTower.LEVEL_HEIGHT, sin(start_angle) * r)
		if not await _jump(player, tower, start, first, "P%d Anlauf" % (passage + 1)):
			failed += 1
		for i: int in range(1, steps):
			var from: Vector3 = HubTower.step_position(passage, i - 1)
			var to: Vector3 = HubTower.step_position(passage, i)
			var to_lift: bool = passage == 1 and i == steps / 2
			var from_lift: bool = passage == 1 and i - 1 == steps / 2
			if (to_lift or from_lift) and lift != null:
				# Auf den Lift springen, wenn er unten ist; vom Lift, wenn er oben ist
				var lift_top_nominal: float = HubTower.step_top(1, steps / 2)
				for w: int in 240:
					var lift_top: float = lift.position.y + 0.175
					if (to_lift and lift_top < lift_top_nominal - 0.5) or (from_lift and lift_top > lift_top_nominal + 0.5):
						break
					await _frames(1)
				if to_lift:
					to.y = lift.position.y + 0.175
			if not await _jump(player, tower, from, to, "P%d Stufe %d→%d" % [passage + 1, i, i + 1], from_lift):
				failed += 1
		# Von der letzten Stufe auf die Etage bzw. die Spitze
		var last: Vector3 = HubTower.step_position(passage, steps - 1)
		var landing_r: float = HubTower.LEVEL_RADII[passage] - 1.0
		# Etwas weiter in Laufrichtung, damit das Ziel nicht unter der ersten Stufe der nächsten Passage liegt
		var angle: float = HubTower.step_angle(passage, steps - 1) + direction * 0.45
		var level := Vector3(cos(angle) * landing_r, float(passage + 1) * HubTower.LEVEL_HEIGHT, sin(angle) * landing_r)
		if not await _jump(player, tower, last, level, "P%d auf Etage %d m" % [passage + 1, int(level.y)]):
			failed += 1
	_check(failed == 0, "Kletterturm vollständig mit echten Sprüngen lösbar (%d Fehlsprünge)" % failed)


## Ein Sprung von `from` nach `to` (Oberseiten, lokal im Turm). Bei `keep_start` steht die Figur schon (Lift).
func _jump(player: Player, tower: HubTower, from: Vector3, to: Vector3, label: String, keep_start: bool = false) -> bool:
	if not keep_start:
		_park(player, tower.to_global(from + Vector3(0, 0.15, 0)))
		await _frames(8)
	var goal: Vector3 = tower.to_global(to)
	_ai1.hold(InputBindings.JUMP, true)
	_ai1.tap(InputBindings.JUMP)
	var left_ground: bool = false
	var ok: bool = false
	for i: int in 120:
		_steer(player, _ai1, goal)
		await _frames(1)
		if i == 14:
			_ai1.hold(InputBindings.JUMP, false)
		if not player.is_on_floor():
			left_ground = true
		elif left_ground:
			break
	_ai1.release_all()
	await _frames(4)
	var local: Vector3 = tower.to_local(player.global_position)
	ok = player.is_on_floor() and absf(local.y - to.y) < 0.45 and Vector2(local.x - to.x, local.z - to.z).length() < 1.6
	if not ok:
		printerr("    Sprung fehlgeschlagen: %s (Ziel %s, gelandet %s)" % [label, str(to), str(local)])
	return ok


# --- Hilfen ---

func _take_over(player: Player) -> AIInput:
	var ai := AIInput.new(10 + player.slot.index)
	InputRouter.register_source(ai)
	player.slot.source = ai
	return ai


func _park(player: Player, at: Vector3) -> void:
	player.respawn(at)


## Lenkt die Figur waagerecht zum Ziel, bremst kurz davor.
func _steer(player: Player, ai: AIInput, goal: Vector3) -> void:
	var to_goal: Vector3 = goal - player.global_position
	to_goal.y = 0.0
	ai.move = player.world_to_input(to_goal.normalized()) if to_goal.length() > 0.3 else Vector2.ZERO


func _walk_to(player: Player, ai: AIInput, goal: Vector3, frames: int) -> void:
	for i: int in frames:
		_steer(player, ai, goal)
		await _frames(1)
	ai.release_all()


func _shot(file_name: String) -> void:
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	img.save_png(_shot_dir.path_join(file_name + ".png"))
	print("SHOT %s" % file_name)


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if condition:
		print("  ok    %s" % description)
	else:
		_failures += 1
		printerr("  FEHLER: %s" % description)


func _finish() -> void:
	print("SMOKE HUB: %d von %d Prüfungen bestanden" % [_checks - _failures, _checks])
	if _failures == 0:
		print("SMOKE HUB: OK")
	get_tree().quit(0 if _failures == 0 else 1)


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame
