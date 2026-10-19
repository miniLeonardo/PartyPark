extends Node
## Autoload InputRouter: kennt alle Eingabequellen, fragt sie einmal pro Physik-Frame ab
## und liefert Beitrittswünsche. Die Zuordnung Quelle zu Spielerplatz hält PlayerRoster.

## Ein Controller wurde getrennt (Quelle bleibt als Objekt erhalten, ist aber nicht mehr verfügbar).
signal source_disconnected(source: InputSource)
## Ein Controller wurde neu erkannt.
signal source_connected(source: InputSource)

## Zeitfenster, in dem ein zweites Gamepad mit gleichzeitigem A-Druck als Doppelgänger gilt (D23).
const TWIN_WINDOW_MS: int = 150

## Tastatur-Debugspieler anlegen (nur in Debug-Builds wirksam).
var keyboard_players_enabled: bool = true

## Alle Quellen, Schlüssel siehe InputSource.key. Reihenfolge = Einfügereihenfolge.
var _sources: Dictionary[String, InputSource] = {}
var _last_claimed_pad_confirm_ms: int = -100000


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_physics_priority = -1000
	if OS.is_debug_build() and keyboard_players_enabled:
		register_source(KeyboardInput.new("kb:left", "Tastatur links", InputBindings.KEYBOARD_LEFT))
		register_source(KeyboardInput.new("kb:right", "Tastatur rechts", InputBindings.KEYBOARD_RIGHT))
	for device: int in Input.get_connected_joypads():
		_add_gamepad(device)
	Input.joy_connection_changed.connect(_on_joy_connection_changed)


func _physics_process(_delta: float) -> void:
	for source: InputSource in _sources.values():
		source.poll()
	# Merken, wann ein bereits belegtes Gamepad zuletzt A gedrückt hat (Doppelgänger-Schutz).
	for source: InputSource in _sources.values():
		if source is GamepadInput and PlayerRoster.has_source(source) and source.just_pressed(InputBindings.CONFIRM):
			_last_claimed_pad_confirm_ms = Time.get_ticks_msec()


func _input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if not (event is InputEventJoypadButton or event is InputEventKey):
		return
	for source: InputSource in _sources.values():
		source.latch_event(event)


## Nimmt eine Quelle in die Abfrage auf (Computergegner registriert PlayerRoster selbst).
func register_source(source: InputSource) -> void:
	_sources[source.key] = source


func unregister_source(source: InputSource) -> void:
	_sources.erase(source.key)


func get_sources() -> Array[InputSource]:
	var result: Array[InputSource] = []
	result.assign(_sources.values())
	return result


## Quellen, die noch keinem Platz gehören und in diesem Frame Bestätigen gedrückt haben.
## Pro Frame höchstens ein Gamepad; Gamepads, die gleichzeitig mit einem belegten Gamepad drücken, werden ignoriert.
func poll_join_requests() -> Array[InputSource]:
	var result: Array[InputSource] = []
	var now: int = Time.get_ticks_msec()
	for source: InputSource in _sources.values():
		if not source.is_joinable() or not source.is_available():
			continue
		if PlayerRoster.has_source(source):
			continue
		if not source.just_pressed(InputBindings.CONFIRM):
			continue
		if source is GamepadInput:
			if now - _last_claimed_pad_confirm_ms <= TWIN_WINDOW_MS:
				continue
			_last_claimed_pad_confirm_ms = now
		result.append(source)
	return result


## Nur für Tests: simuliert das Anstecken eines Controllers mit beliebiger Geräte-ID.
func debug_connect_gamepad(device: int) -> void:
	_on_joy_connection_changed(device, true)


## Nur für Tests: simuliert das Abziehen eines Controllers.
func debug_disconnect_gamepad(device: int) -> void:
	_on_joy_connection_changed(device, false)


func _add_gamepad(device: int) -> GamepadInput:
	var pad := GamepadInput.new(device)
	register_source(pad)
	return pad


func _on_joy_connection_changed(device: int, connected: bool) -> void:
	var key: String = "joy:%d" % device
	if connected:
		var old: InputSource = _sources.get(key)
		if old is GamepadInput and (old as GamepadInput).connected:
			return
		var pad: GamepadInput = _add_gamepad(device)
		print("InputRouter: Controller verbunden (%d, %s)" % [device, pad.get_display_name()])
		source_connected.emit(pad)
	else:
		var source: InputSource = _sources.get(key)
		if source == null:
			return
		(source as GamepadInput).connected = false
		source.reset()
		unregister_source(source)
		print("InputRouter: Controller getrennt (%d)" % device)
		source_disconnected.emit(source)
