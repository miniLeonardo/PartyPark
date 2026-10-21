class_name ParkProps
extends RefCounted
## Selbst gebaute Park-Bauteile aus Grundformen (kein fremdes Asset nötig): Riesenrad, Zirkuszelt,
## Lichterkette, Fahnenmast, Laterne. Alle nutzen die Materialien aus `Look`. Für Kulisse und Arenen.

const BULB_COLORS: Array[Color] = [Color("#ffd75e"), Color("#ff8f5e"), Color("#ff6fa8"), Color("#8fe3ff"), Color("#b6ff7a")]


static func _mesh(parent: Node3D, mesh: Mesh, material: Material, position: Vector3, rotation_deg: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = position
	instance.rotation_degrees = rotation_deg
	parent.add_child(instance)
	return instance


static func _cylinder(radius_top: float, radius_bottom: float, height: float, segments: int = 12) -> CylinderMesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius_top
	mesh.bottom_radius = radius_bottom
	mesh.height = height
	mesh.radial_segments = segments
	mesh.rings = 1
	return mesh


## Riesenrad mit Speichen und Gondeln. `wheel` dreht sich, wenn ein Skript `rotation.z` ändert;
## die Gondeln hängen über `ParkWheel` immer senkrecht.
static func ferris_wheel(radius: float = 9.0, gondolas: int = 10) -> Node3D:
	var root := Node3D.new()
	root.name = "FerrisWheel"
	var frame_mat: Material = Look.surface(Color("#f4f1ff"), Look.Kind.METAL)
	var support_mat: Material = Look.surface(Color("#6c63c7"), Look.Kind.METAL)
	var hub_height: float = radius + 1.5
	# Zwei schräge Stützen je Seite
	for side: float in [-1.0, 1.0]:
		for lean: float in [-1.0, 1.0]:
			var leg_len: float = hub_height / cos(deg_to_rad(18.0))
			var leg := _mesh(root, _cylinder(0.22, 0.32, leg_len, 8), support_mat, Vector3(lean * hub_height * 0.16, hub_height * 0.5, side * 0.9), Vector3(0, 0, -lean * 18.0))
			leg.name = "Leg"
	var wheel := Node3D.new()
	wheel.name = "Wheel"
	wheel.position = Vector3(0, hub_height, 0)
	root.add_child(wheel)
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = radius - 0.18
	ring_mesh.outer_radius = radius + 0.18
	ring_mesh.rings = 48
	ring_mesh.ring_segments = 6
	for side: float in [-0.55, 0.55]:
		_mesh(wheel, ring_mesh, frame_mat, Vector3(0, 0, side), Vector3(90, 0, 0))
	var inner := TorusMesh.new()
	inner.inner_radius = radius * 0.35 - 0.1
	inner.outer_radius = radius * 0.35 + 0.1
	inner.rings = 24
	inner.ring_segments = 6
	_mesh(wheel, inner, frame_mat, Vector3.ZERO, Vector3(90, 0, 0))
	_mesh(wheel, _cylinder(0.6, 0.6, 1.6, 12), Look.surface(Color("#ffcf3f"), Look.Kind.METAL), Vector3.ZERO, Vector3(90, 0, 0))
	var spoke := _cylinder(0.07, 0.07, radius, 6)
	var gondola_colors: Array[Color] = [Color("#ff5d73"), Color("#ffcf3f"), Color("#41c7a9"), Color("#5aa8ff"), Color("#b47cff")]
	for i: int in gondolas:
		var angle: float = TAU * float(i) / float(gondolas)
		var dir := Vector3(cos(angle), sin(angle), 0.0)
		for side: float in [-0.55, 0.55]:
			var s := _mesh(wheel, spoke, frame_mat, dir * radius * 0.5 + Vector3(0, 0, side))
			s.rotation.z = angle - PI * 0.5
		# Glühbirnen außen
		for b: int in 2:
			var bulb_angle: float = angle + TAU / float(gondolas) * 0.5 * float(b)
			var bulb := SphereMesh.new()
			bulb.radius = 0.16
			bulb.height = 0.32
			bulb.radial_segments = 8
			bulb.rings = 4
			_mesh(wheel, bulb, Look.bulb_material(BULB_COLORS[(i * 2 + b) % BULB_COLORS.size()]), Vector3(cos(bulb_angle), sin(bulb_angle), 0) * (radius + 0.3) + Vector3(0, 0, 0.6))
		var pivot := Node3D.new()
		pivot.name = "Gondola%d" % i
		pivot.position = dir * radius
		wheel.add_child(pivot)
		var cabin := _cylinder(0.75, 0.6, 0.9, 10)
		_mesh(pivot, cabin, Look.surface(gondola_colors[i % gondola_colors.size()], Look.Kind.PLASTIC), Vector3(0, -1.1, 0))
		_mesh(pivot, _cylinder(0.85, 0.85, 0.12, 10), Look.surface(Color("#f4f1ff"), Look.Kind.METAL), Vector3(0, -0.55, 0))
		_mesh(pivot, _cylinder(0.05, 0.05, 0.6, 4), frame_mat, Vector3(0, -0.3, 0))
	var script_node := ParkWheel.new()
	script_node.name = "Spin"
	script_node.wheel = wheel
	root.add_child(script_node)
	return root


## Rundes Zirkuszelt mit gestreiftem Dach und Wimpel.
static func tent(radius: float = 3.5, stripe_a: Color = Color("#ff5d73"), stripe_b: Color = Color("#fff6e8")) -> Node3D:
	var root := Node3D.new()
	root.name = "Tent"
	var stripes: int = 12
	var wall_h: float = radius * 0.55
	for i: int in stripes:
		var angle: float = TAU * float(i) / float(stripes)
		var color: Color = stripe_a if i % 2 == 0 else stripe_b
		var wall := BoxMesh.new()
		wall.size = Vector3(TAU * radius / float(stripes) + 0.02, wall_h, 0.12)
		var w := _mesh(root, wall, Look.surface(color, Look.Kind.FABRIC), Vector3(sin(angle) * radius, wall_h * 0.5, cos(angle) * radius))
		w.rotation.y = angle
		var roof := PrismMesh.new()
		roof.left_to_right = 0.5
		roof.size = Vector3(TAU * (radius + 0.4) / float(stripes) + 0.05, radius * 0.95, 0.08)
		var panel := Node3D.new()
		panel.rotation.y = angle
		root.add_child(panel)
		var r := _mesh(panel, roof, Look.surface(color, Look.Kind.FABRIC), Vector3(0, 0, radius * 0.5))
		r.position.y = wall_h + radius * 0.42
		r.rotation_degrees = Vector3(-62.0, 0, 0)
	_mesh(root, _cylinder(radius * 0.18, radius * 0.18, 0.3, 12), Look.surface(stripe_a, Look.Kind.FABRIC), Vector3(0, wall_h + radius * 0.87, 0))
	_mesh(root, _cylinder(0.05, 0.05, 1.4, 4), Look.surface(Color("#6b4a3a"), Look.Kind.WOOD), Vector3(0, wall_h + radius * 0.95 + 0.6, 0))
	var pennant := PrismMesh.new()
	pennant.size = Vector3(0.7, 0.45, 0.04)
	_mesh(root, pennant, Look.surface(Color("#ffcf3f"), Look.Kind.FABRIC), Vector3(0.35, wall_h + radius * 0.95 + 1.1, 0), Vector3(0, 0, -90))
	# Eingang dunkel
	var door := BoxMesh.new()
	door.size = Vector3(radius * 0.5, wall_h * 0.8, 0.14)
	_mesh(root, door, Look.surface(Color("#3a2a4a"), Look.Kind.FABRIC), Vector3(0, wall_h * 0.4, radius + 0.03))
	return root


## Lichterkette zwischen zwei Punkten mit Durchhang.
static func string_lights(from: Vector3, to: Vector3, bulbs: int = 12, sag: float = 0.8) -> Node3D:
	var root := Node3D.new()
	root.name = "StringLights"
	var wire_mat: Material = Look.surface(Color("#2b2333"), Look.Kind.RUBBER)
	var points: Array[Vector3] = []
	var steps: int = bulbs * 2
	for i: int in steps + 1:
		var t: float = float(i) / float(steps)
		var p: Vector3 = from.lerp(to, t)
		p.y -= sin(t * PI) * sag
		points.append(p)
	for i: int in steps:
		var a: Vector3 = points[i]
		var b: Vector3 = points[i + 1]
		var seg := _cylinder(0.025, 0.025, a.distance_to(b), 4)
		var inst := MeshInstance3D.new()
		inst.mesh = seg
		inst.material_override = wire_mat
		root.add_child(inst)
		inst.look_at_from_position((a + b) * 0.5, b, Vector3.UP if absf((b - a).normalized().y) < 0.95 else Vector3.RIGHT)
		inst.rotate_object_local(Vector3.RIGHT, PI * 0.5)
		inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var bulb := SphereMesh.new()
	bulb.radius = 0.15
	bulb.height = 0.3
	bulb.radial_segments = 8
	bulb.rings = 4
	for i: int in bulbs:
		var p: Vector3 = points[i * 2 + 1] + Vector3(0, -0.12, 0)
		var b := _mesh(root, bulb, Look.bulb_material(BULB_COLORS[i % BULB_COLORS.size()]), p)
		b.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return root


## Holzmast mit Wimpelfahne.
static func flag_pole(height: float = 5.0, color: Color = Color("#ff5d73")) -> Node3D:
	var root := Node3D.new()
	root.name = "FlagPole"
	_mesh(root, _cylinder(0.08, 0.1, height, 6), Look.surface(Color("#f4f1ff"), Look.Kind.METAL), Vector3(0, height * 0.5, 0))
	_mesh(root, SphereMesh.new(), Look.surface(Color("#ffcf3f"), Look.Kind.METAL), Vector3(0, height + 0.1, 0)).scale = Vector3.ONE * 0.2
	var flag := PrismMesh.new()
	flag.size = Vector3(1.0, 1.6, 0.05)
	_mesh(root, flag, Look.surface(color, Look.Kind.FABRIC), Vector3(0.5, height - 0.6, 0), Vector3(0, 0, -90))
	return root


## Laterne mit leuchtender Kugel.
static func lamp_post(height: float = 3.2) -> Node3D:
	var root := Node3D.new()
	root.name = "Lamp"
	_mesh(root, _cylinder(0.07, 0.12, height, 8), Look.surface(Color("#3d3a5c"), Look.Kind.METAL), Vector3(0, height * 0.5, 0))
	var globe := SphereMesh.new()
	globe.radius = 0.3
	globe.height = 0.6
	_mesh(root, globe, Look.bulb_material(Color("#ffe6a3")), Vector3(0, height + 0.2, 0))
	# Echtes Licht nur in der Abendstimmung (Budget: ohne Schatten, kleine Reichweite)
	if Look.lamp_lights_enabled():
		var light := OmniLight3D.new()
		light.light_color = Color("#ffcf8a")
		light.light_energy = 2.0
		light.omni_range = 9.0
		light.shadow_enabled = false
		light.position = Vector3(0, height + 0.2, 0)
		root.add_child(light)
	return root


## Rohr entlang einer Punktliste (für Schienen, Seile, Geländer). Querschnitt mit `sides` Ecken.
static func tube_mesh(points: PackedVector3Array, radius: float, sides: int = 6, closed: bool = false) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var count: int = points.size()
	var rings: Array[PackedVector3Array] = []
	var normals_list: Array[PackedVector3Array] = []
	for i: int in count:
		var prev: Vector3 = points[(i - 1 + count) % count] if (closed or i > 0) else points[i]
		var next: Vector3 = points[(i + 1) % count] if (closed or i < count - 1) else points[i]
		var tangent: Vector3 = (next - prev).normalized()
		var side: Vector3 = tangent.cross(Vector3.UP)
		if side.length() < 0.01:
			side = tangent.cross(Vector3.RIGHT)
		side = side.normalized()
		var up: Vector3 = side.cross(tangent).normalized()
		var ring := PackedVector3Array()
		var ring_n := PackedVector3Array()
		for s: int in sides:
			var a: float = TAU * float(s) / float(sides)
			var n: Vector3 = side * cos(a) + up * sin(a)
			ring.append(points[i] + n * radius)
			ring_n.append(n)
		rings.append(ring)
		normals_list.append(ring_n)
	var segs: int = count if closed else count - 1
	for i: int in segs:
		var j: int = (i + 1) % count
		for s: int in sides:
			var s2: int = (s + 1) % sides
			for v: Array in [[i, s], [j, s], [j, s2], [i, s], [j, s2], [i, s2]]:
				st.set_normal(normals_list[v[0]][v[1]])
				st.add_vertex(rings[v[0]][v[1]])
	return st.commit()


## Achterbahn aus einer geschlossenen Kontrollpunktliste: zwei Schienen, Schwellen, Stützen bis zum Boden.
## `ground_y` ist die Bodenhöhe im lokalen Raum.
static func coaster(control: Array[Vector3], ground_y: float = 0.0, rail_color: Color = Color("#ff5d73"), support_color: Color = Color("#f4f1ff")) -> Node3D:
	var root := Node3D.new()
	root.name = "Coaster"
	var curve := Curve3D.new()
	var n: int = control.size()
	for i: int in n:
		var p0: Vector3 = control[(i - 1 + n) % n]
		var p2: Vector3 = control[(i + 1) % n]
		var handle: Vector3 = (p2 - p0) * 0.22
		curve.add_point(control[i], -handle, handle)
	curve.add_point(control[0], -(control[1] - control[n - 1]) * 0.22, (control[1] - control[n - 1]) * 0.22)
	curve.bake_interval = 0.6
	var baked: PackedVector3Array = curve.get_baked_points()
	var left := PackedVector3Array()
	var right := PackedVector3Array()
	var spine := PackedVector3Array()
	for i: int in baked.size():
		var a: Vector3 = baked[i]
		var b: Vector3 = baked[(i + 1) % baked.size()]
		var side: Vector3 = (b - a).cross(Vector3.UP).normalized()
		left.append(a + side * 0.55)
		right.append(a - side * 0.55)
		spine.append(a + Vector3(0, -0.35, 0))
	var rail_mat: Material = Look.surface(rail_color, Look.Kind.METAL)
	var support_mat: Material = Look.surface(support_color, Look.Kind.METAL)
	for rail: PackedVector3Array in [left, right]:
		_mesh(root, tube_mesh(rail, 0.1, 6, true), rail_mat, Vector3.ZERO)
	_mesh(root, tube_mesh(spine, 0.16, 6, true), rail_mat, Vector3.ZERO)
	# Schwellen als MultiMesh
	var tie := BoxMesh.new()
	tie.size = Vector3(1.4, 0.1, 0.22)
	var ties := MultiMesh.new()
	ties.transform_format = MultiMesh.TRANSFORM_3D
	ties.mesh = tie
	var step: int = 2
	ties.instance_count = baked.size() / step
	for k: int in ties.instance_count:
		var i: int = k * step
		var a: Vector3 = baked[i]
		var b: Vector3 = baked[(i + 1) % baked.size()]
		var basis := Basis.looking_at((b - a).normalized(), Vector3.UP)
		ties.set_instance_transform(k, Transform3D(basis, a + Vector3(0, -0.08, 0)))
	var ties_node := MultiMeshInstance3D.new()
	ties_node.multimesh = ties
	ties_node.material_override = Look.surface(Color("#3d3a5c"), Look.Kind.METAL)
	root.add_child(ties_node)
	# Stützen
	var pillar_every: int = 7
	for i: int in range(0, baked.size(), pillar_every):
		var p: Vector3 = baked[i]
		var h: float = p.y - ground_y - 0.4
		if h < 0.8:
			continue
		_mesh(root, _cylinder(0.14, 0.2, h, 6), support_mat, Vector3(p.x, ground_y + h * 0.5, p.z))
	# Ein Wagenzug als Akzent
	var car := BoxMesh.new()
	car.size = Vector3(1.3, 0.7, 1.6)
	var start: int = int(baked.size() * 0.1)
	for c: int in 3:
		var i: int = (start + c * 4) % baked.size()
		var a: Vector3 = baked[i]
		var b: Vector3 = baked[(i + 1) % baked.size()]
		var inst := MeshInstance3D.new()
		inst.mesh = car
		inst.material_override = Look.surface(Color("#ffcf3f") if c % 2 == 0 else Color("#41c7a9"), Look.Kind.PLASTIC)
		root.add_child(inst)
		inst.look_at_from_position(a + Vector3(0, 0.45, 0), b + Vector3(0, 0.45, 0), Vector3.UP)
	return root
