class_name Blaster
extends Node3D
## Einheitliche Waffe für Schießspiele (D85, D89, WP 5a).
## Besitzt einheitliche Ankerpunkte für Griff (Hand) und Mündung (Muzzle/Geschossstart)
## sowie Mündungsfeuer- und Rückstoß-Effekte.

@export var weapon_name: String = "Spielzeug-Blaster"
@export var recoil_distance: float = 0.08
@export var recoil_recovery_speed: float = 12.0

@onready var muzzle: Marker3D = $Muzzle
@onready var grip: Marker3D = $Grip
@onready var model_node: Node3D = $Model

var _recoil: float = 0.0


func _process(delta: float) -> void:
	if _recoil > 0.0:
		_recoil = move_toward(_recoil, 0.0, recoil_recovery_speed * delta)
		if model_node:
			model_node.position.z = _recoil


func fire_effect() -> void:
	_recoil = recoil_distance
	if muzzle:
		Fx.burst(&"sparks", muzzle.global_position, Color(1, 0.8, 0.2), 0.5)


func get_muzzle_position() -> Vector3:
	return muzzle.global_position if muzzle else global_position


func get_muzzle_direction() -> Vector3:
	return -global_basis.z.normalized()
