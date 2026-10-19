class_name InputSource
extends RefCounted
## Eingabequelle eines Spielerplatzes (Gamepad, Tastatur oder Computergegner).
## Der InputRouter ruft poll() einmal pro Physik-Frame auf; just_pressed vergleicht mit dem Vorframe.

## Eindeutiger Schlüssel, z. B. "joy:0", "kb:left", "ai:3".
var key: String = ""

var _down: Dictionary[StringName, bool] = {}
var _prev: Dictionary[StringName, bool] = {}
var _move: Vector2 = Vector2.ZERO
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


## Merkt einen Tastendruck aus einem Eingabe-Ereignis vor, damit sehr kurze Drücke
## zwischen zwei Abfragen (niedrige Bildrate) nicht verloren gehen. Vom InputRouter aufgerufen.
func latch_event(event: InputEvent) -> void:
	for action: StringName in _actions_for_event(event):
		_latched[action] = true


## Bewegung, Länge 0 bis 1. y negativ heißt nach oben bzw. vom Bildschirm weg.
func get_move() -> Vector2:
	return _move


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


## Unterklassen: welche Aktionen löst dieses gedrückte Ereignis bei dieser Quelle aus?
func _actions_for_event(_event: InputEvent) -> Array[StringName]:
	return []


## Unterklassen liefern den Rohzustand der Tasten.
func _read_buttons() -> Dictionary[StringName, bool]:
	return {}


## Unterklassen liefern den Rohzustand der Bewegung.
func _read_move() -> Vector2:
	return Vector2.ZERO
