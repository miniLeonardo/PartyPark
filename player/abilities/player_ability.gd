class_name PlayerAbility
extends Node
## Basisklasse für Fähigkeiten der Spielfigur. Minispiele schalten Fähigkeiten über `enabled` an oder ab.

@export var enabled: bool = true

var player: Player


func _ready() -> void:
	player = get_parent() as Player


## Wird von Player._physics_process aufgerufen, nach Schwerkraft und vor move_and_slide().
func physics_update(_delta: float) -> void:
	pass


## Wird nach move_and_slide() aufgerufen (z. B. um Zusammenstöße auszuwerten).
func post_move_update(_delta: float) -> void:
	pass
