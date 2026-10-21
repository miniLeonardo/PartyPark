class_name HubTrampoline
extends Node3D
## Trampolin für den Freizeitpark (D103).
## Katapultiert Figuren dynamisch empor: je höher der Einstiegsfall,
## desto gewaltiger der Rückprall (Basis 14 m/s, bis zu 28 m/s).

@export var base_bounce_speed: float = 14.0
@export var max_bounce_speed: float = 28.0
@export var radius: float = 2.4

var _mat_mesh: MeshInstance3D
var _cooldown: Dictionary = {}


func _ready() -> void:
	_build_visuals()
	_build_trigger()


func _physics_process(delta: float) -> void:
	for player: Player in _cooldown.keys():
		_cooldown[player] -= delta
		if _cooldown[player] <= 0.0:
			_cooldown.erase(player)


func _build_visuals() -> void:
	# Metallgestell mit Standfüßen
	var frame_mat: Material = Look.surface(Color("#7a728a"), Look.Kind.METAL)
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = radius - 0.2
	ring_mesh.outer_radius = radius + 0.2
	ring_mesh.rings = 32
	ring_mesh.ring_segments = 6

	var ring := MeshInstance3D.new()
	ring.mesh = ring_mesh
	ring.material_override = frame_mat
	ring.position = Vector3(0, 0.7, 0)
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(ring)

	# 6 Beine
	for i: int in 6:
		var angle: float = TAU * float(i) / 6.0
		var leg := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.08
		cyl.bottom_radius = 0.08
		cyl.height = 0.7
		leg.mesh = cyl
		leg.material_override = frame_mat
		leg.position = Vector3(cos(angle) * (radius - 0.1), 0.35, sin(angle) * (radius - 0.1))
		leg.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(leg)

	# Elastische Sprungmatte (gelb/cyan Gummi)
	var mat_geo := CylinderMesh.new()
	mat_geo.top_radius = radius - 0.18
	mat_geo.bottom_radius = radius - 0.18
	mat_geo.height = 0.12
	mat_geo.radial_segments = 24

	_mat_mesh = MeshInstance3D.new()
	_mat_mesh.mesh = mat_geo
	_mat_mesh.material_override = Look.surface(Color("#ffd75e"), Look.Kind.RUBBER)
	_mat_mesh.position = Vector3(0, 0.7, 0)
	add_child(_mat_mesh)


func _build_trigger() -> void:
	var area := Area3D.new()
	area.name = "Trigger"
	area.collision_mask = 1 # Players
	add_child(area)

	var shape := CollisionShape3D.new()
	var cyl_shape := CylinderShape3D.new()
	cyl_shape.radius = radius * 0.95
	cyl_shape.height = 0.8
	shape.shape = cyl_shape
	shape.position = Vector3(0, 0.8, 0)
	area.add_child(shape)

	area.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	var player := body as Player
	if player == null or _cooldown.has(player):
		return

	_cooldown[player] = 0.25

	# Fallgeschwindigkeit auswerten (D103: dynamisches Federn)
	var fall_speed: float = maxf(0.0, -player.velocity.y)
	var bounce: float = clampf(base_bounce_speed + fall_speed * 0.85, base_bounce_speed, max_bounce_speed)

	player.launch(bounce)

	# Sound & Effekte
	Sfx.play(&"jump", global_position, 0.0, 0.9 + (bounce / max_bounce_speed) * 0.4)
	Fx.burst(&"dust", global_position + Vector3.UP * 0.7, Color("#ffd75e"), 1.0)

	var source: InputSource = player.get_input()
	if source != null:
		source.rumble(0.2, 0.7, 0.18)

	# Visuelles Federn der Matte
	var tween := create_tween()
	tween.tween_property(_mat_mesh, "position:y", 0.45, 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(_mat_mesh, "position:y", 0.82, 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_mat_mesh, "position:y", 0.7, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
