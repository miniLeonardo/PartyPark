class_name AIInput
extends InputSource
## Computergegner (Gerüst für M3). Eine KI setzt move und pressed,
## die Figur liest sie wie bei einem Menschen über die InputSource-Schnittstelle.

## Gewünschte Bewegung, wird von der KI gesetzt.
var move: Vector2 = Vector2.ZERO
## Aktuell „gedrückte“ Tasten, wird von der KI gesetzt.
var pressed: Dictionary[StringName, bool] = {}


func _init(slot_index: int) -> void:
	key = "ai:%d" % slot_index


## Hilfsfunktion für KI-Code: Taste für genau einen Frame drücken.
func tap(action: StringName) -> void:
	pressed[action] = true


## Alle virtuellen Tasten loslassen.
func release_all() -> void:
	pressed.clear()


func is_joinable() -> bool:
	return false


func get_display_name() -> String:
	return "Computer"


func _read_buttons() -> Dictionary[StringName, bool]:
	var result: Dictionary[StringName, bool] = pressed.duplicate()
	return result


func _read_move() -> Vector2:
	return move
