class_name Wolf
extends CharacterBody3D
## Computer-Wolf (D37): schleicht zum Gehege und jagt Schafe heraus. Wird er geschubst,
## flieht er vom Feld und kommt nach einer Pause zurück. Steuerung durch das Minispiel.

signal chased_away

@export var speed: float = 4.3
@export var flee_speed: float = 9.0
@export var gravity: float = 30.0

## Zielpunkt, den das Minispiel setzt.
var target: Vector3 = Vector3.ZERO
var fleeing: bool = false

var _knockback: Vector3 = Vector3.ZERO
var _stun: float = 0.0


func _ready() -> void:
	add_to_group(PushAbility.PUSHABLE_GROUP)
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.2
	shape.shape = capsule
	shape.position.y = 0.6
	add_child(shape)
	var fur := StageKit.make_material(Color(0.36, 0.36, 0.4))
	var body := MeshInstance3D.new()
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.4
	body_mesh.height = 1.3
	body.mesh = body_mesh
	body.rotation_degrees = Vector3(90, 0, 0)
	body.position.y = 0.6
	body.material_override = fur
	add_child(body)
	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.32
	head_mesh.height = 0.6
	head.mesh = head_mesh
	head.position = Vector3(0, 0.95, -0.7)
	head.material_override = fur
	add_child(head)
	for x: float in [-0.15, 0.15]:
		var ear := MeshInstance3D.new()
		var ear_mesh := PrismMesh.new()
		ear_mesh.size = Vector3(0.18, 0.25, 0.08)
		ear.mesh = ear_mesh
		ear.position = Vector3(x, 1.3, -0.7)
		ear.material_override = fur
		add_child(ear)
	var eyes := MeshInstance3D.new()
	var eye_mesh := BoxMesh.new()
	eye_mesh.size = Vector3(0.36, 0.06, 0.05)
	eyes.mesh = eye_mesh
	eyes.position = Vector3(0, 1.02, -0.98)
	var glow := StandardMaterial3D.new()
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.albedo_color = Color(1, 0.85, 0.2)
	eyes.material_override = glow
	add_child(eyes)


## Wird von PushAbility aufgerufen.
func receive_push(impulse: Vector3, lift: float, stun_time: float, _by: Node) -> void:
	_knockback = Vector3(impulse.x, 0.0, impulse.z) * 1.3
	velocity.y = maxf(velocity.y, lift)
	_stun = stun_time + 0.4
	if not fleeing:
		fleeing = true
		chased_away.emit()


func _physics_process(delta: float) -> void:
	_stun -= delta
	_knockback = _knockback.move_toward(Vector3.ZERO, 15.0 * delta)
	var direction: Vector3 = target - global_position
	direction.y = 0.0
	var wanted: Vector3 = Vector3.ZERO
	if _stun <= 0.0 and direction.length() > 0.3:
		wanted = direction.normalized() * (flee_speed if fleeing else speed)
	velocity.x = wanted.x + _knockback.x
	velocity.z = wanted.z + _knockback.z
	if fleeing and _stun <= 0.0:
		# Auf der Flucht ohne Kollision über den Zaun: Höhe halten statt durch den Boden zu fallen.
		velocity.y = 0.0
	elif not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()
	if wanted.length() > 0.1:
		rotation.y = lerp_angle(rotation.y, atan2(-wanted.x, -wanted.z), clampf(8.0 * delta, 0.0, 1.0))
