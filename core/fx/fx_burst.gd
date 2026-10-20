@tool
class_name FxBurst
extends GPUParticles3D
## Partikel-Vorlage für einen einmaligen Stoß (Staub, Platscher, Konfetti, Sterne, Schlamm).
## Alle Werte im Editor einstellbar; Material und Form entstehen aus den Werten unten.
## Wird von Fx in einem Objekt-Pool wiederverwendet: emit_at() setzt Position und Farbe und startet neu.

enum Shape { BLOB, CHIP, SPARK }

@export var burst_amount: int = 12:
	set(value):
		burst_amount = value
		_rebuild()
@export var burst_lifetime: float = 0.6:
	set(value):
		burst_lifetime = value
		_rebuild()
@export var base_color: Color = Color(0.85, 0.8, 0.72):
	set(value):
		base_color = value
		_rebuild()
## Zufällige Farbtonstreuung (0 = keine, 1 = alle Farben, z. B. Konfetti).
@export_range(0.0, 1.0) var hue_spread: float = 0.0:
	set(value):
		hue_spread = value
		_rebuild()
@export var shape: Shape = Shape.BLOB:
	set(value):
		shape = value
		_rebuild()
@export var particle_size: float = 0.25:
	set(value):
		particle_size = value
		_rebuild()
## Richtung und Streuwinkel des Ausstoßes.
@export var emit_direction: Vector3 = Vector3.UP:
	set(value):
		emit_direction = value
		_rebuild()
@export_range(0.0, 180.0) var spread_deg: float = 60.0:
	set(value):
		spread_deg = value
		_rebuild()
@export var speed_min: float = 2.0:
	set(value):
		speed_min = value
		_rebuild()
@export var speed_max: float = 4.0:
	set(value):
		speed_max = value
		_rebuild()
## Zusätzliche Geschwindigkeit weg vom Entstehungsmittelpunkt (m/s), z. B. Staubring.
@export var radial_speed: float = 0.0:
	set(value):
		radial_speed = value
		_rebuild()
@export var gravity_strength: float = 9.0:
	set(value):
		gravity_strength = value
		_rebuild()
@export var drag: float = 2.0:
	set(value):
		drag = value
		_rebuild()
## Radius, in dem die Partikel entstehen.
@export var emit_radius: float = 0.3:
	set(value):
		emit_radius = value
		_rebuild()
## Entstehen auf einem flachen Ring statt in einer Kugel (z. B. Stampfwelle).
@export var flat_ring: bool = false:
	set(value):
		flat_ring = value
		_rebuild()
## Partikel schrumpfen zum Ende hin (deckend, billiger als Ausblenden).
@export var shrink_out: bool = true:
	set(value):
		shrink_out = value
		_rebuild()
@export var spin: float = 0.0:
	set(value):
		spin = value
		_rebuild()
@export var glow: bool = false:
	set(value):
		glow = value
		_rebuild()

var _process_material: ParticleProcessMaterial


func _ready() -> void:
	one_shot = true
	explosiveness = 1.0
	emitting = false
	local_coords = false
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_rebuild()


## Startet den Stoß an einer Weltposition. Transparente Farbe = Grundfarbe der Vorlage.
func emit_at(world_position: Vector3, color: Color = Color(0, 0, 0, 0), size_factor: float = 1.0) -> void:
	global_position = world_position
	visible = true
	if _process_material != null:
		_process_material.color = color if color.a > 0.0 else base_color
		_process_material.scale_min = particle_size * 0.7 * size_factor
		_process_material.scale_max = particle_size * 1.2 * size_factor
	restart()


func _rebuild() -> void:
	# Beim Laden der Szene feuern alle Setter vor _ready; dann einmal in _ready aufbauen
	if not is_node_ready():
		return
	amount = maxi(1, burst_amount)
	lifetime = maxf(0.05, burst_lifetime)
	var pm := ParticleProcessMaterial.new()
	pm.direction = emit_direction.normalized() if emit_direction.length_squared() > 0.0 else Vector3.UP
	pm.spread = spread_deg
	pm.initial_velocity_min = speed_min
	pm.initial_velocity_max = speed_max
	pm.gravity = Vector3.DOWN * gravity_strength
	if radial_speed != 0.0:
		pm.radial_velocity_min = radial_speed * 0.8
		pm.radial_velocity_max = radial_speed * 1.2
	pm.damping_min = drag
	pm.damping_max = drag * 1.3
	pm.scale_min = particle_size * 0.7
	pm.scale_max = particle_size * 1.2
	pm.color = base_color
	pm.hue_variation_min = -hue_spread
	pm.hue_variation_max = hue_spread
	if flat_ring:
		pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
		pm.emission_ring_axis = Vector3.UP
		pm.emission_ring_radius = emit_radius
		pm.emission_ring_inner_radius = emit_radius * 0.8
		pm.emission_ring_height = 0.05
	else:
		pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		pm.emission_sphere_radius = maxf(0.01, emit_radius)
	if spin != 0.0:
		pm.angular_velocity_min = -spin
		pm.angular_velocity_max = spin
		pm.angle_min = 0.0
		pm.angle_max = 360.0
	if shrink_out:
		var curve := Curve.new()
		curve.add_point(Vector2(0.0, 1.0))
		curve.add_point(Vector2(0.6, 0.85))
		curve.add_point(Vector2(1.0, 0.0))
		var curve_texture := CurveTexture.new()
		curve_texture.curve = curve
		pm.scale_curve = curve_texture
	process_material = pm
	_process_material = pm
	draw_pass_1 = _make_mesh()
	visibility_aabb = AABB(Vector3(-6, -3, -6), Vector3(12, 9, 12))


func _make_mesh() -> Mesh:
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.roughness = 0.8
	if glow:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var mesh: PrimitiveMesh
	match shape:
		Shape.CHIP:
			var box := BoxMesh.new()
			box.size = Vector3(1.0, 0.15, 0.6)
			mesh = box
			material.cull_mode = BaseMaterial3D.CULL_DISABLED
		Shape.SPARK:
			var spark := SphereMesh.new()
			spark.radius = 0.5
			spark.height = 1.0
			spark.radial_segments = 4
			spark.rings = 1
			mesh = spark
		_:
			var blob := SphereMesh.new()
			blob.radius = 0.5
			blob.height = 1.0
			blob.radial_segments = 6
			blob.rings = 3
			mesh = blob
	mesh.material = material
	return mesh
