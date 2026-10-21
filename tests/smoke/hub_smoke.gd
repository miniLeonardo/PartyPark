extends Node
## Smoke-Test für den 3D-Freizeitpark-Hub (WP 1 / ROADMAP 7.1).
## Start: godot --headless --path . -- --smoke-hub
## Prüft das Laden der Szene, Spawnen aller 4 Spieler, Vorhandensein von
## Gelände, Wegen, Randbegrenzung, Kulissenelementen und Zonen-Erkennung.

var _failures: int = 0
var _checks: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_run.call_deferred()


func _run() -> void:
	print("SMOKE HUB: Start")
	await _frames(5)

	# Spielerplätze belegen
	PlayerRoster.clear_cpus()
	for source: InputSource in InputRouter.get_sources():
		if source is KeyboardInput and source.key == "kb:left":
			PlayerRoster.join(source)
			break
	PlayerRoster.fill_with_cpu()
	_check(PlayerRoster.get_active_slots().size() == 4, "4 Spielerplätze belegt (1 Mensch, 3 CPUs)")

	# Hub starten
	Game.start_hub()
	await _frames(10)

	var hub: Hub = get_tree().current_scene as Hub
	_check(hub != null, "Hub-Szene erfolgreich geladen")
	if hub == null:
		_finish()
		return

	_check(hub.players.size() == 4, "4 Spielerfiguren in der Hub-Lobby vorhanden")
	_check(hub.camera != null and hub.camera is HubCamera, "HubCamera vorhanden und aktiv")

	# Prüfe Gelände- und Kulissenelemente
	var terrain: Node = hub.get_node_or_null("Terrain")
	var scenery: Node = hub.get_node_or_null("Scenery")
	_check(terrain != null, "Terrain-Knoten vorhanden")
	_check(scenery != null, "Scenery-Knoten vorhanden")

	if terrain != null:
		_check(terrain.get_node_or_null("CentralPlaza") != null, "Zentraler Festplatz (Plaza) vorhanden")
		_check(terrain.get_node_or_null("PlazaFountain") != null, "Park-Brunnen im Zentrum vorhanden")
		_check(terrain.get_node_or_null("Arch_PARKOUR_&_TURM") != null, "Tor zum Parkour-Bereich vorhanden")
		_check(terrain.get_node_or_null("Arch_RUMMELPLATZ") != null, "Tor zum Rummelplatz vorhanden")
		_check(terrain.get_node_or_null("Arch_ATTRAKTIONEN") != null, "Tor zum Attraktions-Boulevard vorhanden")
		_check(terrain.get_node_or_null("Arch_SPIELZEUG-WIESE") != null, "Tor zur Spielzeug-Wiese vorhanden")
		_check(terrain.get_node_or_null("Perimeter") != null, "Umlaufende Parkbegrenzung (Perimeter) vorhanden")

	if scenery != null:
		_check(scenery.get_node_or_null("FerrisWheel") != null, "Riesenrad in der Kulisse vorhanden")
		_check(scenery.get_node_or_null("Coaster") != null, "Achterbahn in der Kulisse vorhanden")
		_check(scenery.get_node_or_null("Tent") != null, "Zirkuszelte in der Kulisse vorhanden")

	# Spielerbewegung testen
	var p1: Player = hub.players[0]
	var initial_pos: Vector3 = p1.global_position
	_check(initial_pos.distance_to(Vector3.ZERO) < 10.0, "Spieler 1 startet auf der zentralen Plaza")

	# Simuliere Bewegung nach Norden (Richtung Parkour, negative Z-Achse)
	await _tap_key(KEY_W, 20)
	var moved_pos: Vector3 = p1.global_position
	_check(moved_pos.z < initial_pos.z - 1.0, "Spieler 1 läuft nach Norden Richtung Parkour")

	# Zonen-Erkennung prüfen
	p1.global_position = Vector3(0, 0.5, -20.0) # Im Nord-Korridor
	await _frames(5)
	_check(hub._current_zone == Hub.ParkZone.PARKOUR, "Zonenerkennung: Parkour & Kletterturm erkannt")

	p1.global_position = Vector3(25.0, 0.5, 0.0) # Im Ost-Korridor
	await _frames(5)
	_check(hub._current_zone == Hub.ParkZone.RUMMEL, "Zonenerkennung: Rummelplatz erkannt")

	p1.global_position = Vector3(0.0, 0.5, 25.0) # Im Süd-Korridor
	await _frames(5)
	_check(hub._current_zone == Hub.ParkZone.ATTRAKTIONEN, "Zonenerkennung: Attraktionen-Boulevard erkannt")

	p1.global_position = Vector3(-25.0, 0.5, 0.0) # Im West-Korridor
	await _frames(5)
	_check(hub._current_zone == Hub.ParkZone.SPIELZEUG_WIESE, "Zonenerkennung: Spielzeug-Wiese erkannt")

	# Absturz- und Respawn-Sicherung testen
	p1.global_position = Vector3(0, -10.0, 0)
	await _frames(3)
	_check(p1.global_position.y >= -1.0, "Absturz-Sicherung: Spieler wird nach Fall unter kill_height sicher respawnt")

	_finish()


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


func _tap_key(keycode: Key, duration_frames: int = 4) -> void:
	var ev_down := InputEventKey.new()
	ev_down.keycode = keycode
	ev_down.physical_keycode = keycode
	ev_down.pressed = true
	Input.parse_input_event(ev_down)
	await _frames(duration_frames)
	var ev_up := InputEventKey.new()
	ev_up.keycode = keycode
	ev_up.physical_keycode = keycode
	ev_up.pressed = false
	Input.parse_input_event(ev_up)
	await _frames(1)
