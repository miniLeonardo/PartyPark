class_name StageKit
extends RefCounted
## Baukasten für Level aus Grundformen (Kollision und einfache Optik). Aussehen kommt seit v0.5 aus `Look` (D87).


## Himmel, Umgebungslicht und Sonne der aktuellen Stimmung (seit v0.5 aus `Look`, D87).
static func add_environment(parent: Node) -> void:
	Look.add_environment(parent)


## Eigenes (veränderbares) Material im Partypark-Stil (D85); `kind` siehe `Look.Kind`.
## Für unveränderliche Flächen besser `Look.surface()` (geteilt, weniger Materialwechsel).
static func make_material(color: Color, kind: int = Look.Kind.PLASTIC) -> StandardMaterial3D:
	return (Look.surface(color, kind) as StandardMaterial3D).duplicate()


## Statischer Quader; `position` ist der Mittelpunkt.
static func add_box(parent: Node, size: Vector3, position: Vector3, color: Color, rotation_deg: Vector3 = Vector3.ZERO, kind: int = Look.Kind.PLASTIC) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = position
	body.rotation_degrees = rotation_deg
	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh.mesh = box_mesh
	mesh.material_override = Look.surface(color, kind)
	body.add_child(mesh)
	var shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = size
	shape.shape = box_shape
	body.add_child(shape)
	parent.add_child(body)
	return body


## Statischer Zylinder; `position` ist der Mittelpunkt.
static func add_cylinder(parent: Node, radius: float, height: float, position: Vector3, color: Color, kind: int = Look.Kind.PLASTIC) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = position
	var mesh := MeshInstance3D.new()
	var cylinder_mesh := CylinderMesh.new()
	cylinder_mesh.top_radius = radius
	cylinder_mesh.bottom_radius = radius
	cylinder_mesh.height = height
	cylinder_mesh.radial_segments = clampi(int(radius * 8.0), 16, 64)
	mesh.mesh = cylinder_mesh
	mesh.material_override = Look.surface(color, kind)
	body.add_child(mesh)
	var shape := CollisionShape3D.new()
	var cylinder_shape := CylinderShape3D.new()
	cylinder_shape.radius = radius
	cylinder_shape.height = height
	shape.shape = cylinder_shape
	body.add_child(shape)
	parent.add_child(body)
	return body
