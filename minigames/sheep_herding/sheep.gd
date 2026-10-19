class_name Sheep
extends CharacterBody3D
## Ein Schaf: läuft vor Spielern und Wolf weg, hält sich lose an die Herde und trödelt sonst herum.
## Die Steuerung kommt vom Minispiel (steer()), damit alle Schafe gemeinsam rechnen können.

@export var wander_speed: float = 1.2
@export var flee_speed: float = 6.0
@export var acceleration: float = 10.0
@export var gravity: float = 30.0

var desired: Vector3 = Vector3.ZERO
var _scare: Vector3 = Vector3.ZERO
var _body: Node3D


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.45
	shape.shape = sphere
	shape.position.y = 0.45
	add_child(shape)
	_body = Node3D.new()
	add_child(_body)
	var wool := MeshInstance3D.new()
	var wool_mesh := SphereMesh.new()
	wool_mesh.radius = 0.5
	wool_mesh.height = 0.85
	wool.mesh = wool_mesh
	wool.position.y = 0.55
	wool.material_override = StageKit.make_material(Color(0.97, 0.97, 0.95))
	_body.add_child(wool)
	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.2
	head_mesh.height = 0.36
	head.mesh = head_mesh
	head.position = Vector3(0, 0.75, -0.45)
	head.material_override = StageKit.make_material(Color(0.12, 0.12, 0.14))
	_body.add_child(head)
	for x: float in [-0.2, 0.2]:
		for z: float in [-0.2, 0.2]:
			var leg := MeshInstance3D.new()
			var leg_mesh := CylinderMesh.new()
			leg_mesh.top_radius = 0.06
			leg_mesh.bottom_radius = 0.06
			leg_mesh.height = 0.3
			leg.mesh = leg_mesh
			leg.position = Vector3(x, 0.15, z)
			leg.material_override = StageKit.make_material(Color(0.12, 0.12, 0.14))
			_body.add_child(leg)


## Plötzlicher Schreck (Bellen): Stoß weg von `from`.
func scare(from: Vector3, strength: float) -> void:
	var away: Vector3 = global_position - from
	away.y = 0.0
	if away.length_squared() < 0.0001:
		away = Vector3.BACK
	_scare += away.normalized() * strength
	velocity.y = maxf(velocity.y, 3.0)


func _physics_process(delta: float) -> void:
	var target: Vector3 = desired.limit_length(flee_speed) + _scare
	_scare = _scare.move_toward(Vector3.ZERO, 12.0 * delta)
	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	horizontal = horizontal.move_toward(target, acceleration * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()
	if horizontal.length() > 0.3:
		_body.rotation.y = lerp_angle(_body.rotation.y, atan2(-horizontal.x, -horizontal.z), clampf(8.0 * delta, 0.0, 1.0))
		_body.position.y = absf(sin(Time.get_ticks_msec() * 0.015)) * 0.06 * clampf(horizontal.length() / 3.0, 0.0, 1.0)
