class_name InputSource
extends RefCounted
## Eingabequelle eines Spielerplatzes (Gamepad, Tastatur oder Computergegner).
## Der InputRouter ruft poll() einmal pro Physik-Frame auf; just_pressed vergleicht mit dem Vorframe.

## Eindeutiger Schlüssel, z. B. "joy:0", "kb:left", "ai:3".
var key: String = ""

var _down: Dictionary[StringName, bool] = {}
var _prev: Dictionary[StringName, bool] = {}
var _move: Vector2 = Vector2.ZERO
## Zweiter Stick zum Umsehen (Ego-Spiele), Länge 0 bis 1.
var _aim: Vector2 = Vector2.ZERO
## Tasten, die seit dem letzten poll() gedrückt wurden (auch wenn schon wieder losgelassen).
var _latched: Dictionary[StringName, bool] = {}


## Liest den aktuellen Zustand ein. Nur vom InputRouter aufrufen.
func poll() -> void:
	_prev = _down
	_down = {}
	var buttons: Dictionary[StringName, bool] = _read_buttons()
	for action: StringName in InputBindings.BUTTON_ACTIONS:
		_down[action] = buttons.get(action, false) or _latched.get(action, false)
	_latched.clear()
	_move = _read_move().limit_length(1.0)
	_aim = _read_aim().limit_length(1.0)
	_down[InputBindings.NAV_UP] = _move.y < -InputBindings.NAV_THRESHOLD
	_down[InputBindings.NAV_DOWN] = _move.y > InputBindings.NAV_THRESHOLD
	_down[InputBindings.NAV_LEFT] = _move.x < -InputBindings.NAV_THRESHOLD
	_down[InputBindings.NAV_RIGHT] = _move.x > InputBindings.NAV_THRESHOLD


## Setzt den Zustand komplett zurück (z. B. wenn ein Controller getrennt wurde).
func reset() -> void:
	_down = {}
	_prev = {}
	_latched.clear()
	_move = Vector2.ZERO
	_aim = Vector2.ZERO


## Merkt einen Tastendruck aus einem Eingabe-Ereignis vor, damit sehr kurze Drücke
## zwischen zwei Abfragen (niedrige Bildrate) nicht verloren gehen. Vom InputRouter aufgerufen.
func latch_event(event: InputEvent) -> void:
	for action: StringName in _actions_for_event(event):
		_latched[action] = true


## Bewegung, Länge 0 bis 1. y negativ heißt nach oben bzw. vom Bildschirm weg.
func get_move() -> Vector2:
	return _move


## Umsehen mit dem rechten Stick. x positiv = nach rechts, y positiv = nach unten.
func get_aim() -> Vector2:
	return _aim


## Hat die Quelle einen zweiten Stick? Sonst drehen Ego-Spiele mit links/rechts (Tastatur-Debug).
func has_aim_stick() -> bool:
	return false


## Beschriftung der Umsehen-Eingabe, z. B. „rechter Stick“.
func get_aim_label() -> String:
	return "rechter Stick" if has_aim_stick() else "%s links/rechts drehen" % get_move_label()


func is_down(action: StringName) -> bool:
	return _down.get(action, false)


func just_pressed(action: StringName) -> bool:
	return _down.get(action, false) and not _prev.get(action, false)


func just_released(action: StringName) -> bool:
	return _prev.get(action, false) and not _down.get(action, false)


## Hat diese Quelle in diesem Frame irgendeine Taste neu gedrückt?
func any_just_pressed() -> bool:
	for action: StringName in InputBindings.BUTTON_ACTIONS:
		if just_pressed(action):
			return true
	return false


func rumble(_weak: float, _strong: float, _duration: float) -> void:
	pass


## Darf diese Quelle per Tastendruck einem Platz beitreten?
func is_joinable() -> bool:
	return true


## Ist das Gerät hinter der Quelle noch verbunden?
func is_available() -> bool:
	return true


func get_display_name() -> String:
	return key


## Gerätegruppe für Tastenhinweise, z. B. „Controller“ oder „Tastatur links“.
func get_kind_name() -> String:
	return get_display_name()


## Beschriftung der Taste für eine Aktion auf diesem Gerät, z. B. „A“, „Kreuz“ oder „Leertaste“.
func get_action_label(action: StringName) -> String:
	return String(action)


## Beschriftung der Bewegungseingabe, z. B. „Stick“ oder „WASD“.
func get_move_label() -> String:
	return "Stick"


## Unterklassen: welche Aktionen löst dieses gedrückte Ereignis bei dieser Quelle aus?
func _actions_for_event(_event: InputEvent) -> Array[StringName]:
	return []


## Unterklassen liefern den Rohzustand der Tasten.
func _read_buttons() -> Dictionary[StringName, bool]:
	return {}


## Unterklassen liefern den Rohzustand des zweiten Sticks.
func _read_aim() -> Vector2:
	return Vector2.ZERO


## Unterklassen liefern den Rohzustand der Bewegung.
func _read_move() -> Vector2:
	return Vector2.ZERO
