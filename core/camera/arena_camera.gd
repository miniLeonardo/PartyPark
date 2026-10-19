class_name ArenaCamera
extends Camera3D
## Hält alle Figuren einer Gruppe im Bild: Mittelpunkt und Abstand aus deren Ausdehnung, geglättet.
## Blickrichtung ist fest (keine Drehung um die Hochachse), damit die Steuerung kamerarelativ stabil bleibt.

## Neigung nach unten in Grad (90 = senkrecht von oben).
@export_range(10.0, 89.0) var pitch_deg: float = 52.0
## Drehung um die Hochachse in Grad (0 = Blick nach -Z).
@export var yaw_deg: float = 0.0
@export var min_distance: float = 11.0
@export var max_distance: float = 32.0
## Zusätzlicher Rand um die Figuren in Metern.
@export var padding: float = 3.0
## Glättung der Mittelpunktbewegung; höher = direkter.
@export var follow_smoothing: float = 3.0
## Glättung des Zooms; höher = direkter.
@export var zoom_smoothing: float = 2.0
## Fester Versatz des Zielpunkts.
@export var target_offset: Vector3 = Vector3(0.0, 0.5, 0.0)
## Figuren unterhalb dieser Höhe (fallend) werden ignoriert.
@export var ignore_below_height: float = -3.0
@export var target_group: StringName = &"players"

var _center: Vector3 = Vector3.ZERO
var _distance: float = 16.0
var _initialized: bool = false


func _ready() -> void:
	fov = 50.0
	_update_camera(0.0, true)


func _process(delta: float) -> void:
	_update_camera(delta, not _initialized)


func _update_camera(delta: float, snap: bool) -> void:
	var points: Array[Vector3] = []
	for node: Node in get_tree().get_nodes_in_group(target_group):
		var target := node as Node3D
		if target != null and target.global_position.y > ignore_below_height:
			points.append(target.global_position)
	if points.is_empty():
		if snap:
			_place()
		return
	var bounds := AABB(points[0], Vector3.ZERO)
	for point: Vector3 in points:
		bounds = bounds.expand(point)
	var center: Vector3 = bounds.get_center() + target_offset
	var radius: float = Vector2(bounds.size.x, bounds.size.z).length() * 0.5 + padding
	var wanted: float = clampf(radius / tan(deg_to_rad(fov) * 0.5), min_distance, max_distance)
	if snap:
		_center = center
		_distance = wanted
		_initialized = true
	else:
		_center = _center.lerp(center, clampf(follow_smoothing * delta, 0.0, 1.0))
		_distance = lerpf(_distance, wanted, clampf(zoom_smoothing * delta, 0.0, 1.0))
	_place()


func _place() -> void:
	var pitch: float = deg_to_rad(pitch_deg)
	var back := Vector3(0.0, sin(pitch), cos(pitch)).rotated(Vector3.UP, deg_to_rad(yaw_deg))
	global_position = _center + back * _distance
	look_at(_center, Vector3.UP)
