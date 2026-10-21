class_name HubMovingPlatform
extends AnimatableBody3D
## Bewegliche Plattform (Schwebelift / Pendel) für den Park (D106).
## Bewegt sich gleichmäßig zwischen zwei Punkten und nimmt Figuren physikalisch sauber mit.

@export var travel_offset: Vector3 = Vector3(0.0, 7.0, 0.0)
@export var travel_duration: float = 3.5
@export var pause_time: float = 0.8
@export var platform_size: Vector3 = Vector3(3.2, 0.4, 3.2)
@export var platform_color: Color = Color("#eedcb8")

var _start_pos: Vector3
var _timer: float = 0.0


func _ready() -> void:
	sync_to_physics = true
	_start_pos = position
	_build_visuals()


func _physics_process(delta: float) -> void:
	_timer += delta
	var total_cycle: float = (travel_duration + pause_time) * 2.0
	var cycle_time: float = fmod(_timer, total_cycle)

	var t: float = 0.0
	if cycle_time < travel_duration:
		# Hinweg (0 -> 1)
		var progress: float = cycle_time / travel_duration
		t = 0.5 - 0.5 * cos(progress * PI)
	elif cycle_time < travel_duration + pause_time:
		# Pause oben
		t = 1.0
	elif cycle_time < travel_duration * 2.0 + pause_time:
		# Rückweg (1 -> 0)
		var progress: float = (cycle_time - (travel_duration + pause_time)) / travel_duration
		t = 0.5 + 0.5 * cos(progress * PI)
	else:
		# Pause unten
		t = 0.0

	global_position = _start_pos + travel_offset * t


func _build_visuals() -> void:
	# Plattform-Mesh
	var mesh_inst := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = platform_size
	mesh_inst.mesh = box
	mesh_inst.material_override = Look.surface(platform_color, Look.Kind.STONE)
	add_child(mesh_inst)

	# Warnstreifen / Zierrand
	var trim := MeshInstance3D.new()
	var trim_box := BoxMesh.new()
	trim_box.size = Vector3(platform_size.x + 0.1, 0.12, platform_size.z + 0.1)
	trim.mesh = trim_box
	trim.material_override = Look.surface(Color("#ffd75e"), Look.Kind.METAL)
	trim.position = Vector3(0, -0.15, 0)
	trim.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(trim)

	# Kollision
	var shape := CollisionShape3D.new()
	var col_box := BoxShape3D.new()
	col_box.size = platform_size
	shape.shape = col_box
	add_child(shape)
