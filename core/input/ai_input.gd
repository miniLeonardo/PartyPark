class_name AIInput
extends InputSource
## Computergegner. Das Minispiel setzt `move` und Tasten, die Figur liest sie
## wie bei einem Menschen über die InputSource-Schnittstelle.

## Gewünschte Bewegung (Stick-Koordinaten, y negativ = vom Bildschirm weg).
var move: Vector2 = Vector2.ZERO
## Dauerhaft gehaltene Tasten.
var held: Dictionary[StringName, bool] = {}
## Für genau eine Abfrage gedrückte Tasten.
var _taps: Dictionary[StringName, bool] = {}


func _init(slot_index: int) -> void:
	key = "ai:%d" % slot_index


## Taste für genau eine Abfrage drücken (ergibt einmal just_pressed).
func tap(action: StringName) -> void:
	_taps[action] = true


func hold(action: StringName, down: bool) -> void:
	held[action] = down


## Alles loslassen und stehen bleiben.
func release_all() -> void:
	held.clear()
	_taps.clear()
	move = Vector2.ZERO


func is_joinable() -> bool:
	return false


func get_display_name() -> String:
	return "Computer"


func get_kind_name() -> String:
	return "Computer"


func _read_buttons() -> Dictionary[StringName, bool]:
	var result: Dictionary[StringName, bool] = held.duplicate()
	for action: StringName in _taps:
		result[action] = true
	_taps.clear()
	return result


func _read_move() -> Vector2:
	return move
