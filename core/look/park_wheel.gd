class_name ParkWheel
extends Node
## Dreht das Riesenrad langsam und hält die Gondeln senkrecht. Rein optisch.

@export var speed_deg: float = 6.0
var wheel: Node3D


func _process(delta: float) -> void:
	if wheel == null:
		return
	wheel.rotation.z += deg_to_rad(speed_deg) * delta
	for child: Node in wheel.get_children():
		if child.name.begins_with("Gondola"):
			(child as Node3D).rotation.z = -wheel.rotation.z
