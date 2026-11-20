class_name HubTrampoline
extends Node3D
## Trampolin für den Freizeitpark (D103).
## Feste Matte auf Höhe `mat_height`; wer darauf landet (oder darauf steht), wird hochgeworfen:
## je höher der Fall, desto stärker der Rückprall (Basis base_bounce_speed, höchstens max_bounce_speed).
## Vorher war die Matte nur Optik, und der Sprung löste schon beim seitlichen Hineinlaufen aus.

@export var base_bounce_speed: float = 14.0
@export var max_bounce_speed: float = 28.0
@export var radius: float = 2.4
## Höhe der Matte über dem Boden (m). Niedrig genug für die Stufenhilfe im Park.
@export var mat_height: float = 0.4
## Anteil der Fallgeschwindigkeit, der in den Rückprall geht.
@export_range(0.0, 2.0) var fall_bonus: float = 0.85

var _mat_mesh: MeshInstance3D
var _mat_body: StaticBody3D
var _inside: Array[Player] = []
var _cooldown: Dictionary = {}
var _tween: Tween


func _ready() -> void:
	_build_visuals()
	_build_body()
	_build_trigger()


func _physics_process(delta: float) -> void:
	for player: Player in _cooldown.keys():
		_cooldown[player] -= delta
		if _cooldown[player] <= 0.0:
			_cooldown.erase(player)
	for player: Player in _inside:
		if is_instance_valid(player) and not _cooldown.has(player) and player.get_floor_collider() == _mat_body:
			_bounce(player)


func _bounce(player: Player) -> void:
	_cooldown[player] = 0.25
	var bounce: float = clampf(base_bounce_speed + player.landing_speed * fall_bonus, base_bounce_speed, max_bounce_speed)
	player.landing_speed = 0.0
	player.launch(bounce)

	Sfx.play(&"jump", global_position, 0.0, 0.9 + (bounce / max_bounce_speed) * 0.4)
	Fx.burst(&"dust", global_position + Vector3.UP * mat_height, Color("#ffd75e"), 1.0)
	var source: InputSource = player.get_input()
	if source != null:
		source.rumble(0.2, 0.7, 0.18)

	# Visuelles Federn der Matte (alten Tween beenden, sonst kämpfen sie gegeneinander)
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_mat_mesh, "position:y", mat_height - 0.25, 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_mat_mesh, "position:y", mat_height + 0.1, 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_mat_mesh, "position:y", mat_height, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _build_visuals() -> void:
	# Metallrahmen mit Standfüßen
	var frame_mat: Material = Look.surface(Color("#7a728a"), Look.Kind.METAL)
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = radius - 0.2
	ring_mesh.outer_radius = radius + 0.2
	ring_mesh.rings = 32
	ring_mesh.ring_segments = 6

	var ring := MeshInstance3D.new()
	ring.mesh = ring_mesh
	ring.material_override = frame_mat
	ring.position = Vector3(0, mat_height, 0)
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(ring)

	for i: int in 6:
		var angle: float = TAU * float(i) / 6.0
		var leg := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.08
		cyl.bottom_radius = 0.08
		cyl.height = mat_height
		leg.mesh = cyl
		leg.material_override = frame_mat
		leg.position = Vector3(cos(angle) * (radius - 0.1), mat_height * 0.5, sin(angle) * (radius - 0.1))
		leg.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(leg)

	var mat_geo := CylinderMesh.new()
	mat_geo.top_radius = radius - 0.18
	mat_geo.bottom_radius = radius - 0.18
	mat_geo.height = 0.12
	mat_geo.radial_segments = 24
	_mat_mesh = MeshInstance3D.new()
	_mat_mesh.mesh = mat_geo
	_mat_mesh.material_override = Look.surface(Color("#ffd75e"), Look.Kind.RUBBER)
	_mat_mesh.position = Vector3(0, mat_height, 0)
	add_child(_mat_mesh)


## Feste Matte (inklusive Rahmen), Oberkante auf mat_height.
func _build_body() -> void:
	_mat_body = StaticBody3D.new()
	_mat_body.name = "MatBody"
	_mat_body.position = Vector3(0, mat_height * 0.5, 0)
	var shape := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = radius + 0.2
	cyl.height = mat_height
	shape.shape = cyl
	_mat_body.add_child(shape)
	add_child(_mat_body)


func _build_trigger() -> void:
	var area := Area3D.new()
	area.name = "Trigger"
	area.collision_mask = 1 # Players
	add_child(area)
	var shape := CollisionShape3D.new()
	var cyl_shape := CylinderShape3D.new()
	cyl_shape.radius = radius + 0.4
	cyl_shape.height = 1.2
	shape.shape = cyl_shape
	shape.position = Vector3(0, mat_height + 0.6, 0)
	area.add_child(shape)
	area.body_entered.connect(func(body: Node3D) -> void:
		if body is Player and not _inside.has(body):
			_inside.append(body as Player))
	area.body_exited.connect(func(body: Node3D) -> void:
		if body is Player:
			_inside.erase(body as Player))
