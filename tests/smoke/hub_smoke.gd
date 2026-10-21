extends Node
## Smoke-Test für den 3D-Freizeitpark-Hub (WP 1 / ROADMAP 7.1).
## Start: godot --headless --path . -- --smoke-hub
## Prüft das Laden der Szene, Spawnen aller 4 Spieler, Vorhandensein von
## Gelände, Wegen, Randbegrenzung, Kulissenelementen und Zonen-Erkennung.

var _failures: int = 0
var _checks: int = 0
var _shot_dir: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--shots="):
			_shot_dir = arg.trim_prefix("--shots=")
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
		var pg: Node = terrain.get_node_or_null("Playground")
		_check(pg != null, "Playground-Knoten im Gelände vorhanden")
		if pg != null:
			_check(pg.get_node_or_null("Carousel") is HubCarousel, "Rummelplatz-Karussell (HubCarousel) vorhanden")
			_check(pg.get_node_or_null("TrampolineEast") is HubTrampoline, "Ost-Trampolin (HubTrampoline) vorhanden")
			_check(pg.get_node_or_null("Slide") is HubSlide, "Spielplatz-Rutsche (HubSlide) vorhanden")
			_check(pg.get_node_or_null("Seesaw") is HubSeesaw, "Physikalische Wippe (HubSeesaw) vorhanden")
			_check(pg.get_node_or_null("PondFerry") is HubMovingPlatform, "Teich-Pendelplattform (HubMovingPlatform) vorhanden")
			_check(pg.get_node_or_null("TowerLift") is HubMovingPlatform, "Turm-Schwebelift (HubMovingPlatform) vorhanden")

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

	if not _shot_dir.is_empty():
		DirAccess.make_dir_recursive_absolute(_shot_dir)
		p1.global_position = Vector3(0, 0.4, 4.0)
		await _frames(15)
		await _shot("01_hub_plaza")

	# Trampolin-Sprungfunktion testen (D103)
	var tramp: HubTrampoline = terrain.get_node("Playground/TrampolineEast") as HubTrampoline
	p1.global_position = tramp.global_position + Vector3(0, 1.5, 0)
	p1.velocity = Vector3(0, -10.0, 0)
	await _frames(5)
	_check(p1.velocity.y > 10.0, "Trampolin: Dynamischer Katapult-Impuls nach unten gerichtetem Fall aktiv")

	# Kletterturm, Siegerkrone & Konfetti-Buzzer testen (D100, D107, D108)
	var tower: HubTower = terrain.get_node_or_null("Playground/ClimbingTower") as HubTower
	_check(tower != null, "Kletterturm (HubTower) im Park vorhanden")
	if tower != null:
		_check(tower.crown != null and tower.crown is HubCrown, "Siegerkrone auf der Turmspitze vorhanden")
		_check(tower.buzzer != null and tower.buzzer is HubConfettiBuzzer, "Konfetti-Buzzer auf der Turmspitze vorhanden")

		if not _shot_dir.is_empty():
			p1.global_position = Vector3(0, 0.4, -22.0)
			await _frames(15)
			await _shot("02_hub_tower")

		# Krone aufsetzen
		p1.global_position = tower.crown.global_position
		await _frames(5)
		_check(tower.crown.current_state == HubCrown.State.WORN and tower.crown.wearer == p1, "Siegerkrone: Spieler 1 setzt die Krone beim Erreichen auf")

		if not _shot_dir.is_empty():
			await _frames(15)
			await _shot("03_hub_summit_crown")

		# Schubser -> Krone fliegt als Physik-Item ab (D108)
		var p2: Player = hub.players[1]
		tower.crown.drop_from_push(p2)
		await _frames(3)
		_check(tower.crown.current_state == HubCrown.State.DROPPED and tower.crown._velocity.length() > 5.0, "Siegerkrone: Springt bei Schubser als Physik-Item mit Bogenflug ab")

		# Buzzer auslösen
		p1.global_position = tower.buzzer.global_position
		await _frames(5)
		_check(tower.buzzer._cooldown > 0.0, "Konfetti-Buzzer: Löst bei Betreten der Turmspitze aus")

	# Attraktionen, Minispiel-Buden & Turnier-Pavillon testen (D109, D110, D111, D112)
	var attractions: Node = terrain.get_node_or_null("Attractions")
	_check(attractions != null, "Attractions-Knoten auf dem Süd-Boulevard vorhanden")
	if attractions != null:
		var pavilion: HubTournamentPavilion = attractions.get_node_or_null("TournamentPavilion") as HubTournamentPavilion
		_check(pavilion != null, "Turnier-Pavillon (HubTournamentPavilion) vorhanden")
		if pavilion != null:
			_check(pavilion.activation_pad != null, "Turnier-Pavillon besitzt eigenes ActivationPad")
			# Rundenzahl-Umschalter testen
			pavilion.rounds = 5
			pavilion._on_switcher_entered(p1)
			_check(pavilion.rounds == 10, "Turnier-Pavillon: Umschaltung auf 10 Runden erfolgreich")

		var st_cars: HubMinigameStation = attractions.get_node_or_null("Station_bumper_cars") as HubMinigameStation
		_check(st_cars != null and st_cars.info != null, "Minispiel-Bude Autoscooter (HubMinigameStation) vorhanden")
		if st_cars != null and st_cars.activation_pad != null:
			p1.global_position = st_cars.activation_pad.global_position + Vector3(0, 0.2, 0)
			await _frames(5)
			_check(st_cars.activation_pad._is_counting, "Aktivierungs-Pad: Countdown startet, wenn alle Menschen die Platte betreten")
			# Verlassen bricht ab (D111)
			p1.global_position = Vector3(0, 0.4, 0) # Zurück zur Plaza
			await _frames(5)
			_check(not st_cars.activation_pad._is_counting, "Aktivierungs-Pad: Countdown bricht sofort ab, wenn ein Spieler die Platte verlässt")

			# Vollständigen Ablauf Hub -> Minispiel -> zurück in Hub prüfen (Haltepunkt 2)
			hub.play_minigame(st_cars.info)
			await _frames(5)
			_check(hub.active_flow != null, "Ablauf: Minispiel-MatchFlow erfolgreich aus Hub gestartet")
			_check(not p1.visible and not p1.controls_enabled, "Ablauf: Hub-Spieler während Minispiel pausiert")
			# Spielende simulieren
			hub._on_flow_completed(MinigameResult.new(), {})
			await _frames(5)
			_check(hub.active_flow == null, "Ablauf: Nach MatchFlow wieder nahtlos in der Park-Lobby")
			_check(p1.visible and p1.controls_enabled, "Ablauf: Spielerfiguren in der Lobby wieder aktiv")

	# Wegweiser prüfen (D112)
	_check(scenery.get_node_or_null("Signpost_0") is HubSignpost, "Holz-Wegweiser (HubSignpost) an den Wegkreuzungen vorhanden")

	# Großraum-Kamera mit dynamischer Turm-Neigung und Offscreen-Pfeilen prüfen (D113, D114)
	var hcam: HubCamera = hub.camera as HubCamera
	_check(hcam != null and hcam._indicator_layer != null, "HubCamera besitzt OffscreenIndicators-Layer (D113)")
	if hcam != null:
		p1.global_position = Vector3(0, 0.4, 0)
		await _frames(5)
		var initial_pitch: float = hcam.pitch_deg
		# Spieler 1 auf Turmspitze setzen -> Neigungswinkel verflacht sich Richtung high_pitch_deg (D114)
		p1.global_position = Vector3(0, 20.5, -34.0)
		hcam._center = p1.global_position
		await _frames(15)
		_check(hcam.pitch_deg < initial_pitch - 1.0, "HubCamera: Neigung flacht bei Höhe dynamisch ab (D114)")

		# Offscreen-Indikatoren prüfen: Wenn Spieler weit weg platziert wird (D113)
		p1.global_position = Vector3(150.0, 0.4, 150.0)
		await _frames(5)
		var ind_p1: Control = hcam._indicators.get(p1.slot) as Control
		_check(ind_p1 != null and ind_p1.visible, "HubCamera: Offscreen-Pfeil für entfernten Spieler sichtbar (D113)")
		# Zurückstellen
		p1.global_position = Vector3(0, 0.4, 0)
		await _frames(5)

	# Parkbesucher & Atmosphäre prüfen (D115, D116, D117)
	var crowd: Node = scenery.get_node_or_null("Crowd")
	_check(crowd != null, "Parkbesucher-Knoten (Crowd) vorhanden (D115)")
	if crowd != null:
		var visitor_count: int = crowd.get_child_count()
		_check(visitor_count >= 20, "Mindestens 20 Parkbesucher platziert (%d)" % visitor_count)
		var vis0: ParkVisitor = crowd.get_node_or_null("Visitor_0") as ParkVisitor
		_check(vis0 != null and vis0._model_node != null, "Parkbesucher-Modell erfolgreich instanziiert (Kenney Mini Characters)")
		if vis0 != null:
			# Reaktion bei Annäherung prüfen (D115)
			p1.global_position = vis0.global_position + Vector3(0.5, 0, 0.5)
			await _frames(10)
			_check(vis0._hop_time > 0.0 or vis0._cheer_cooldown > 0.0, "Parkbesucher: Reagiert mit Hüpfen/Jubel auf Spielernähe (D115)")
			p1.global_position = Vector3(0, 0.4, 0)
			await _frames(5)

	# Dynamisch pulsierende Lichterketten prüfen (D116)
	var sl1: HubStringLights = scenery.get_node_or_null("StringLights1") as HubStringLights
	_check(sl1 != null and not sl1._bulb_materials.is_empty(), "Dynamisch pulsierende Lichterketten aktiv (D116)")

	# Audio-Atmosphäre prüfen (D117)
	var ambiance: HubAmbiance = hub.get_node_or_null("Ambiance") as HubAmbiance
	_check(ambiance != null, "Zonenabhängige Park-Audio-Atmosphäre (HubAmbiance) aktiv (D117)")

	if not _shot_dir.is_empty():
		p1.global_position = Vector3(32.0, 0.4, 0.0)
		await _frames(15)
		await _shot("04_hub_rummel_carousel")
		p1.global_position = Vector3(-32.0, 0.4, 6.0)
		await _frames(15)
		await _shot("05_hub_playground_slide")

	_finish()


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
