class_name StageKit
extends RefCounted
## Baukasten für Platzhalter-Level aus Grundformen (bis echte Assets kommen, siehe D17).


## Himmel, Umgebungslicht und Sonne mit Schatten.
static func add_environment(parent: Node) -> void:
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("#5aa6f0")
	sky_material.sky_horizon_color = Color("#cfe8ff")
	sky_material.ground_horizon_color = Color("#cfe8ff")
	sky_material.ground_bottom_color = Color("#6b8fb5")
	var sky := Sky.new()
	sky.sky_material = sky_material
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.5
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	var world := WorldEnvironment.new()
	world.environment = env
	parent.add_child(world)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55.0, -35.0, 0.0)
	sun.light_energy = 1.1
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 60.0
	parent.add_child(sun)


static func make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	return material


## Statischer Quader; `position` ist der Mittelpunkt.
static func add_box(parent: Node, size: Vector3, position: Vector3, color: Color, rotation_deg: Vector3 = Vector3.ZERO) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = position
	body.rotation_degrees = rotation_deg
	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh.mesh = box_mesh
	mesh.material_override = make_material(color)
	body.add_child(mesh)
	var shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = size
	shape.shape = box_shape
	body.add_child(shape)
	parent.add_child(body)
	return body


## Statischer Zylinder; `position` ist der Mittelpunkt.
static func add_cylinder(parent: Node, radius: float, height: float, position: Vector3, color: Color) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = position
	var mesh := MeshInstance3D.new()
	var cylinder_mesh := CylinderMesh.new()
	cylinder_mesh.top_radius = radius
	cylinder_mesh.bottom_radius = radius
	cylinder_mesh.height = height
	mesh.mesh = cylinder_mesh
	mesh.material_override = make_material(color)
	body.add_child(mesh)
	var shape := CollisionShape3D.new()
	var cylinder_shape := CylinderShape3D.new()
	cylinder_shape.radius = radius
	cylinder_shape.height = height
	shape.shape = cylinder_shape
	body.add_child(shape)
	parent.add_child(body)
	return body
