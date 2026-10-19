extends Node
## Automatischer Durchlauf für M1 mit simulierten Tastatur- und Gamepad-Eingaben.
## Start: godot --headless --path . -- --smoke-m1   (Game hängt dieses Skript dann ein)
## Beendet sich mit Exit-Code 0 (alles grün) oder 1.

var _failures: int = 0
var _checks: int = 0
## Optional: Bildschirmfotos nach --shots=<ordner> speichern (nur mit Fenster/Renderer sinnvoll).
var _shot_dir: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--shots="):
			_shot_dir = arg.trim_prefix("--shots=")
	_run.call_deferred()


func _run() -> void:
	print("SMOKE M1: Start")
	await _frames(10)
	_check(get_tree().current_scene.name == "JoinScreen", "Hauptszene ist der Beitrittsbildschirm")

	# Beitritt Tastatur
	await _tap_key(KEY_SPACE)
	_check(_slot_key(0) == "kb:left", "Tastatur links belegt Platz 1")
	var join_screen: Node = get_tree().current_scene
	_check(join_screen._card_hints[0].text.contains("Esc: Los"), "Karte von Spieler 1 zeigt Esc als Start-Taste")
	_check(join_screen._hint.text.contains("Esc (Tastatur links)"), "Hinweiszeile nennt Esc für Tastatur links")
	_check(join_screen._hint.text.contains("Enter (Tastatur rechts)"), "Hinweiszeile nennt Enter zum Beitreten für Tastatur rechts")
	await _tap_key(KEY_ENTER)
	_check(_slot_key(1) == "kb:right", "Tastatur rechts belegt Platz 2")

	# Beitritt Gamepad mit Doppelgänger (gleichzeitiger Druck auf zwei Geräten)
	InputRouter.debug_connect_gamepad(10)
	InputRouter.debug_connect_gamepad(11)
	await _frames(2)
	await _tap_pad_both(10, 11, JOY_BUTTON_A)
	_check(_slot_key(2) == "joy:10", "Gamepad 10 belegt Platz 3")
	_check(PlayerRoster.human_count() == 3, "Doppelgänger-Gamepad 11 ist nicht beigetreten")
	_check(join_screen._card_hints[2].text.contains("Start: Los") and join_screen._card_hints[2].text.contains("A: Hüpfen"), "Karte von Spieler 3 zeigt Controller-Tasten")
	_check(GamepadInput.detect_label_style("DualSense Wireless Controller") == "playstation", "PlayStation-Controller wird erkannt")
	_check(GamepadInput.detect_label_style("Nintendo Switch Pro Controller") == "nintendo", "Nintendo-Controller wird erkannt")
	_check(GamepadInput.detect_label_style("Xbox Series Controller") == "xbox", "Xbox-Controller wird erkannt")
	await _frames(15)
	await _tap_pad_both(10, 11, JOY_BUTTON_A)
	_check(PlayerRoster.human_count() == 3, "Doppelgänger bleibt draußen, wenn das belegte Gamepad erneut A drückt")

	# Austreten und wieder beitreten
	await _tap_key(KEY_BACKSPACE)
	_check(PlayerRoster.slots[1].is_empty(), "B (Rücktaste) lässt Tastatur rechts austreten")
	await _tap_key(KEY_ENTER)
	_check(_slot_key(1) == "kb:right", "Tastatur rechts tritt wieder auf Platz 2 bei")

	await _shot("01_beitritt")

	# Computergegner umschalten
	await _tap_key(KEY_Q)
	_check(not PlayerRoster.cpu_fill_enabled, "Y schaltet Computer aus")
	await _tap_key(KEY_Q)
	_check(PlayerRoster.cpu_fill_enabled, "Y schaltet Computer wieder an")

	# Start
	await _tap_key(KEY_ESCAPE)
	await _frames(10)
	var arena: Node = get_tree().current_scene
	_check(arena != null and arena.name == "TestArena", "Start lädt die Testarena")
	if arena == null or arena.name != "TestArena":
		_finish()
		return
	_check(arena.players.size() == 4, "4 Figuren in der Arena")
	_check(PlayerRoster.slots[3].is_cpu, "Platz 4 ist Computer")
	_check(arena._hint.text.contains("Esc (Tastatur links)") and arena._hint.text.contains("Start (Controller)") and arena._hint.text.contains("P (Tastatur rechts)"), "Arena-Hinweis nennt Pause-Taste je Gerät")
	await _frames(30)

	var p1: Player = arena.get_player(0)
	var p2: Player = arena.get_player(1)
	var p3: Player = arena.get_player(2)
	var p4: Player = arena.get_player(3)
	_check(p1.is_on_floor() and p4.is_on_floor(), "Figuren stehen auf dem Boden")
	await _shot("02_arena")

	# Unabhängige Steuerung
	var a1: Vector3 = p1.global_position
	var a2: Vector3 = p2.global_position
	var a3: Vector3 = p3.global_position
	_key(KEY_D, true)
	await _frames(30)
	_key(KEY_D, false)
	await _frames(20)
	_check(p1.global_position.x - a1.x > 1.5, "D bewegt Spieler 1 nach rechts")
	_check(_flat_distance(p2.global_position, a2) < 0.05, "Spieler 2 bleibt dabei stehen")
	_check(_flat_distance(p3.global_position, a3) < 0.05, "Spieler 3 bleibt dabei stehen")

	var b1: Vector3 = p1.global_position
	_pad_axis(10, JOY_AXIS_LEFT_Y, -1.0)
	await _frames(30)
	_pad_axis(10, JOY_AXIS_LEFT_Y, 0.0)
	await _frames(20)
	_check(a3.z - p3.global_position.z > 1.5, "Stick oben bewegt Spieler 3 vom Bildschirm weg")
	_check(_flat_distance(p1.global_position, b1) < 0.05, "Spieler 1 bleibt dabei stehen")

	# Deadzone
	var c3: Vector3 = p3.global_position
	_pad_axis(10, JOY_AXIS_LEFT_X, 0.15)
	await _frames(30)
	_pad_axis(10, JOY_AXIS_LEFT_X, 0.0)
	_check(_flat_distance(p3.global_position, c3) < 0.01, "Stickausschlag in der Deadzone bewegt nichts")

	# Springen
	var y0: float = p1.global_position.y
	var peak: float = y0
	_key(KEY_SPACE, true)
	for i: int in 25:
		await _frames(1)
		peak = maxf(peak, p1.global_position.y)
	_check(peak - y0 > 0.8, "Leertaste lässt Spieler 1 springen")
	_key(KEY_SPACE, false)
	await _frames(60)
	_check(p1.is_on_floor(), "Spieler 1 landet wieder")

	# Schubsen: Spieler 1 schaut nach rechts (+X), Spieler 2 direkt davor
	_key(KEY_D, true)
	await _frames(4)
	_key(KEY_D, false)
	await _frames(20)
	p2.respawn(p1.global_position + Vector3(1.2, 0.2, 0.0))
	await _frames(20)
	var push_from: Vector3 = p2.global_position
	await _tap_key(KEY_F)
	await _frames(25)
	_check(p2.global_position.x - push_from.x > 1.5, "F schubst Spieler 2 weg")

	# Pause durch Spieler 1, Weiter mit A
	await _tap_key(KEY_ESCAPE)
	_check(get_tree().paused and Game.pause_menu.is_open, "Esc öffnet das Pause-Menü")
	_check(Game.pause_menu._controls.text.contains("Leertaste: Bestätigen"), "Pause-Menü zeigt Tastatur-Bedienung des Öffnenden")
	await _shot("03_pause")
	await _tap_key(KEY_SPACE)
	await _frames(2)
	_check(not get_tree().paused and not Game.pause_menu.is_open, "A auf „Weiter“ setzt fort")

	# Pause durch Spieler 3 (Gamepad), schließen mit B durch Spieler 2
	await _tap_pad(10, JOY_BUTTON_START)
	_check(Game.pause_menu.is_open, "Start auf Gamepad öffnet Pause")
	_check(Game.pause_menu._controls.text.contains("A: Bestätigen"), "Pause-Menü zeigt Controller-Bedienung des Öffnenden")
	await _tap_key(KEY_BACKSPACE)
	await _frames(2)
	_check(not Game.pause_menu.is_open and not get_tree().paused, "Ein anderer Spieler schließt mit B")

	# Verbindungsabbruch und automatische Wiederaufnahme
	InputRouter.debug_disconnect_gamepad(10)
	await _frames(3)
	_check(PlayerRoster.slots[2].disconnected and get_tree().paused, "Abziehen pausiert das Spiel")
	_check(Game.disconnect_overlay.visible, "Hinweis „Controller getrennt“ sichtbar")
	await _shot("04_getrennt")
	InputRouter.debug_connect_gamepad(10)
	await _frames(3)
	_check(not PlayerRoster.slots[2].disconnected and _slot_key(2) == "joy:10", "Wiederanstecken übernimmt den Platz automatisch")
	_check(not get_tree().paused, "Spiel läuft danach weiter")

	# Übernahme durch ein anderes Gamepad
	InputRouter.debug_disconnect_gamepad(10)
	await _frames(3)
	await _tap_pad(11, JOY_BUTTON_A)
	_check(_slot_key(2) == "joy:11", "Anderer Controller übernimmt Platz 3 mit A")
	_check(not get_tree().paused, "Spiel läuft nach Übernahme weiter")

	# Absturz und Respawn
	p1.global_position = Vector3(0.0, -20.0, 0.0)
	await _frames(5)
	_check(p1.global_position.y > -1.0, "Abgestürzte Figur erscheint wieder")

	# Zurück zum Beitritt über das Pause-Menü
	await _tap_key(KEY_ESCAPE)
	await _tap_key(KEY_S)
	await _tap_key(KEY_SPACE)
	await _frames(10)
	_check(get_tree().current_scene.name == "JoinScreen", "„Zurück zum Beitritt“ lädt den Beitrittsbildschirm")
	_check(not get_tree().paused, "Beitrittsbildschirm ist nicht pausiert")
	_check(PlayerRoster.human_count() == 3 and PlayerRoster.slots[3].is_empty(), "Menschen bleiben beigetreten, Computer entfernt")
	_finish()


func _finish() -> void:
	print("SMOKE M1: %d von %d Prüfungen bestanden" % [_checks - _failures, _checks])
	print("SMOKE M1: %s" % ("OK" if _failures == 0 else "FEHLER"))
	get_tree().paused = false
	get_tree().quit(0 if _failures == 0 else 1)


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if condition:
		print("  ok    %s" % description)
	else:
		_failures += 1
		print("  FEHLER %s" % description)


func _shot(file_name: String) -> void:
	if _shot_dir.is_empty() or DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png(_shot_dir.path_join(file_name + ".png"))


func _slot_key(index: int) -> String:
	var source: InputSource = PlayerRoster.slots[index].source
	return "" if source == null else source.key


func _flat_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()


## Wartet count Durchläufe, in denen sowohl ein Bild als auch ein Physikschritt stattfand
## (wichtig bei niedriger Bildrate, wenn Eingaben nur einmal pro Bild verarbeitet werden).
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


func _pad_button(device: int, button: JoyButton, pressed: bool) -> void:
	var event := InputEventJoypadButton.new()
	event.device = device
	event.button_index = button
	event.pressed = pressed
	Input.parse_input_event(event)


func _pad_axis(device: int, axis: JoyAxis, value: float) -> void:
	var event := InputEventJoypadMotion.new()
	event.device = device
	event.axis = axis
	event.axis_value = value
	Input.parse_input_event(event)


func _tap_pad(device: int, button: JoyButton) -> void:
	_pad_button(device, button, true)
	await _frames(3)
	_pad_button(device, button, false)
	await _frames(3)


func _tap_pad_both(device_a: int, device_b: int, button: JoyButton) -> void:
	_pad_button(device_a, button, true)
	_pad_button(device_b, button, true)
	await _frames(3)
	_pad_button(device_a, button, false)
	_pad_button(device_b, button, false)
	await _frames(3)
