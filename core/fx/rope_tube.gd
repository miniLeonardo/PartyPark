class_name RopeTube
extends MeshInstance3D
## Dünner Schlauch entlang einer Punktliste (z. B. Seil), jeden Frame neu aufbaubar.
## Vierkantiger Querschnitt, damit er aus jeder Kamerahöhe sichtbar ist. Punkte in Weltkoordinaten.

@export var thickness: float = 0.09
@export var color: Color = Color("#d9b77a"):
	set(value):
		color = value
		if _material != null:
			_material.albedo_color = value

var _immediate := ImmediateMesh.new()
var _material := StandardMaterial3D.new()


func _init() -> void:
	mesh = _immediate
	_material.albedo_color = color
	_material.roughness = 0.9
	material_override = _material
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	top_level = true


## Baut den Schlauch neu. Weniger als zwei Punkte leeren ihn.
func set_points(points: PackedVector3Array) -> void:
	_immediate.clear_surfaces()
	if points.size() < 2:
		visible = false
		return
	visible = true
	global_transform = Transform3D.IDENTITY
	var half: float = thickness * 0.5
	var rings: Array[PackedVector3Array] = []
	var normals: Array[PackedVector3Array] = []
	for i: int in points.size():
		var tangent: Vector3
		if i == 0:
			tangent = points[1] - points[0]
		elif i == points.size() - 1:
			tangent = points[i] - points[i - 1]
		else:
			tangent = points[i + 1] - points[i - 1]
		tangent = tangent.normalized() if tangent.length_squared() > 0.000001 else Vector3.RIGHT
		var u: Vector3 = tangent.cross(Vector3.UP)
		if u.length_squared() < 0.0001:
			u = tangent.cross(Vector3.RIGHT)
		u = u.normalized()
		var v: Vector3 = u.cross(tangent).normalized()
		var ring := PackedVector3Array([points[i] + (u + v) * half, points[i] + (-u + v) * half, points[i] + (-u - v) * half, points[i] + (u - v) * half])
		rings.append(ring)
		normals.append(PackedVector3Array([v, -u, -v, u]))
	_immediate.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	for i: int in range(points.size() - 1):
		for side: int in 4:
			var next_side: int = (side + 1) % 4
			var normal: Vector3 = normals[i][side]
			var a: Vector3 = rings[i][side]
			var b: Vector3 = rings[i][next_side]
			var c: Vector3 = rings[i + 1][next_side]
			var d: Vector3 = rings[i + 1][side]
			for vertex: Vector3 in [a, b, c, a, c, d]:
				_immediate.surface_set_normal(normal)
				_immediate.surface_add_vertex(vertex)
	_immediate.surface_end()
