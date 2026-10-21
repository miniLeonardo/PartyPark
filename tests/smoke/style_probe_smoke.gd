extends Node
## Stilproben (WP 2, v0.5): dieselbe Szene (Autoscooter-Arena mit vier Figuren und Park-Kulisse)
## in den drei Stimmungen, je aus Spiel- und Heldenkamera. Die Stilentscheidung (D85) fiel anhand der
## Bilder in docs/screenshots/v0_5/stilproben/; seitdem gibt es nur noch den Plastik-Stil.
## Start (mit Renderer):
##   xvfb-run … godot --path . --rendering-driver vulkan --resolution 1280x720 -- --smoke-style_probe --shots=<ordner>
##   [--moods=noon,golden,evening] [--cams=spiel,held]

const MOOD_NAMES: Dictionary = {"noon": Look.Mood.NOON, "golden": Look.Mood.GOLDEN, "evening": Look.Mood.EVENING}
const KENNEY: String = "res://assets/third_party/kenney_coaster-kit/"

var _shot_dir: String = ""
var _moods: Array[String] = ["noon"]
var _cams: Array[String] = ["spiel", "held"]
var _root: Node3D
var _camera: Camera3D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--shots="):
			_shot_dir = arg.trim_prefix("--shots=")
		elif arg.begins_with("--moods="):
			_moods.assign(arg.trim_prefix("--moods=").split(","))
		elif arg.begins_with("--cams="):
			_cams.assign(arg.trim_prefix("--cams=").split(","))
	_run.call_deferred()


func _run() -> void:
	await _frames(3)
	var host: Node = get_tree().current_scene
	host.process_mode = Node.PROCESS_MODE_DISABLED
	for child: Node in host.get_children():
		child.queue_free()
	Settings.graphics_quality = 2
	Settings.apply_graphics()
	for mood_name: String in _moods:
		Look.use_mood(MOOD_NAMES[mood_name])
		_root = Node3D.new()
		host.add_child(_root)
		_build_scene()
		for cam: String in _cams:
			_set_camera(cam)
			await _frames(12)
			await _shot("plastic_%s_%s" % [mood_name, cam])
		_root.queue_free()
		await _frames(3)
	print("STYLE PROBE fertig")
	get_tree().quit()


func _build_scene() -> void:
	Look.add_environment(_root)
	# Arena wie Autoscooter (Radius 11, vier Lücken)
	var platform := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 11.0
	cyl.bottom_radius = 10.6
	cyl.height = 1.0
	cyl.radial_segments = 64
	platform.mesh = cyl
	platform.position.y = -0.5
	platform.material_override = Look.surface(Color("#f2be86"), Look.Kind.STONE)
	_root.add_child(platform)
	var inner := MeshInstance3D.new()
	var inner_cyl := CylinderMesh.new()
	inner_cyl.top_radius = 10.3
	inner_cyl.bottom_radius = 10.3
	inner_cyl.height = 0.04
	inner_cyl.radial_segments = 64
	inner.mesh = inner_cyl
	inner.position.y = 0.02
	inner.material_override = Look.surface(Color("#e8a66e"), Look.Kind.RUBBER)
	_root.add_child(inner)
	# Mittelkreis
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 2.2
	torus.outer_radius = 2.6
	torus.rings = 48
	ring.mesh = torus
	ring.scale = Vector3(1, 0.05, 1)
	ring.position.y = 0.05
	ring.material_override = Look.surface(Color("#ffcf3f"), Look.Kind.RUBBER)
	_root.add_child(ring)
	var support := MeshInstance3D.new()
	var sup := CylinderMesh.new()
	sup.top_radius = 10.6
	sup.bottom_radius = 12.6
	sup.height = 5.0
	sup.radial_segments = 48
	support.mesh = sup
	support.position.y = -3.4
	support.material_override = Look.surface(Color("#9a8fd0"), Look.Kind.STONE)
	_root.add_child(support)
	for i: int in 36:
		var angle_deg: float = 10.0 * float(i)
		var gap := false
		for g: int in 4:
			if absf(wrapf(angle_deg - (45.0 + 90.0 * float(g)), -180.0, 180.0)) < 13.0:
				gap = true
		if gap:
			continue
		var angle: float = deg_to_rad(angle_deg)
		var wall := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(TAU * 10.8 / 36.0 + 0.05, 0.7, 0.4)
		wall.mesh = box
		wall.position = Vector3(sin(angle) * 10.8, 0.35, cos(angle) * 10.8)
		wall.rotation.y = angle
		wall.material_override = Look.surface(Color("#ffcf3f") if i % 2 == 0 else Color("#ff6b4a"), Look.Kind.PLASTIC)
		_root.add_child(wall)
	# Wasserbecken
	var water := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(56, 56)
	plane.subdivide_width = 40
	plane.subdivide_depth = 40
	water.mesh = plane
	water.position.y = -2.6
	water.material_override = Look.water_material()
	_root.add_child(water)
	var pool_floor := MeshInstance3D.new()
	var floor_box := BoxMesh.new()
	floor_box.size = Vector3(56, 0.5, 56)
	pool_floor.mesh = floor_box
	pool_floor.position.y = -6.0
	pool_floor.material_override = Look.surface(Color("#5aa0c8"), Look.Kind.STONE)
	_root.add_child(pool_floor)
	# Ufer und Wiese rundherum
	var grass_color := Color("#7cc96a")
	for side: Vector3 in [Vector3(0, 0, -1), Vector3(0, 0, 1), Vector3(-1, 0, 0), Vector3(1, 0, 0)]:
		var bank := MeshInstance3D.new()
		var bank_box := BoxMesh.new()
		var along: bool = side.x == 0.0
		bank_box.size = Vector3(200 if along else 72, 5.0, 72 if along else 56)
		bank.mesh = bank_box
		bank.position = side * 64.0 + Vector3(0, -3.6, 0)
		bank.material_override = Look.surface(grass_color, Look.Kind.GRASS)
		_root.add_child(bank)
		var edge := MeshInstance3D.new()
		var edge_box := BoxMesh.new()
		edge_box.size = Vector3(57.6 if along else 0.8, 0.5, 0.8 if along else 57.6)
		edge.mesh = edge_box
		edge.position = side * 28.4 + Vector3(0, -1.0, 0)
		edge.material_override = Look.surface(Color("#f3ead8"), Look.Kind.STONE)
		_root.add_child(edge)
	# Kulisse
	var wheel: Node3D = ParkProps.ferris_wheel(10.0, 12)
	wheel.position = Vector3(-26, -1.1, -42)
	wheel.rotation_degrees.y = 20.0
	_root.add_child(wheel)
	var tent: Node3D = ParkProps.tent(4.0)
	tent.position = Vector3(18, -1.1, -36)
	_root.add_child(tent)
	var tent2: Node3D = ParkProps.tent(3.0, Color("#5aa8ff"), Color("#fff6e8"))
	tent2.position = Vector3(31, -1.1, -24)
	_root.add_child(tent2)
	var track: Array[Vector3] = [Vector3(-8, 3, -46), Vector3(2, 3, -44), Vector3(10, 12, -46), Vector3(16, 5, -50), Vector3(22, 8, -56), Vector3(14, 3, -62), Vector3(2, 6, -60), Vector3(-6, 9, -58), Vector3(-12, 4, -52)]
	var coaster: Node3D = ParkProps.coaster(track, -1.1)
	_root.add_child(coaster)
	_place_model("stall-food.glb", Vector3(-12, -1.1, -33), 4.0, 15.0, Look.Kind.PLASTIC)
	_place_model("stall-drinks.glb", Vector3(-4, -1.1, -34), 4.0, -5.0, Look.Kind.PLASTIC)
	_place_model("stall-information.glb", Vector3(34, -1.1, -6), 4.0, -80.0, Look.Kind.PLASTIC)
	for tree_pos: Vector3 in [Vector3(-38, -1.1, -24), Vector3(-34, -1.1, -12), Vector3(36, -1.1, -40), Vector3(-40, -1.1, 4), Vector3(40, -1.1, 10), Vector3(24, -1.1, -46), Vector3(-16, -1.1, -46)]:
		_place_model("tree-large.glb" if int(tree_pos.x) % 2 == 0 else "tree.glb", tree_pos, 6.5, tree_pos.x * 7.0, Look.Kind.GRASS)
	for x: float in [-24.0, -12.0, 0.0, 12.0, 24.0]:
		var lamp: Node3D = ParkProps.lamp_post(3.6)
		lamp.position = Vector3(x, -0.75, -29.4)
		_root.add_child(lamp)
	for x: float in [-24.0, -12.0, 0.0, 12.0]:
		_root.add_child(ParkProps.string_lights(Vector3(x, 2.9, -29.4), Vector3(x + 12.0, 2.9, -29.4), 10, 0.9))
	for pos: Vector3 in [Vector3(-29, -0.75, -29), Vector3(29, -0.75, -29)]:
		var pole: Node3D = ParkProps.flag_pole(6.0, Color("#b47cff"))
		pole.position = pos
		_root.add_child(pole)
	for a: int in 4:
		var angle: float = deg_to_rad(45.0 + 90.0 * float(a))
		var lamp2: Node3D = ParkProps.lamp_post(4.2)
		lamp2.position = Vector3(sin(angle) * 11.6, -0.5, cos(angle) * 11.6)
		_root.add_child(lamp2)
	_root.add_child(ParkProps.string_lights(Vector3(-8.2, 3.9, -8.2), Vector3(8.2, 3.9, -8.2), 14, 1.2))
	_root.add_child(ParkProps.string_lights(Vector3(-8.2, 3.9, -8.2), Vector3(-8.2, 3.9, 8.2), 14, 1.2))
	_root.add_child(ParkProps.string_lights(Vector3(8.2, 3.9, -8.2), Vector3(8.2, 3.9, 8.2), 14, 1.2))
	# Vier Figuren
	var player_scene: PackedScene = load("res://player/player.tscn")
	var positions: Array[Vector3] = [Vector3(-3.2, 0, 4.0), Vector3(1.2, 0, 5.2), Vector3(4.6, 0, 2.6), Vector3(-0.8, 1.2, 1.2)]
	for i: int in 4:
		var slot := PlayerSlot.new(i, PlayerRoster.PLAYER_COLORS[i], "P%d" % (i + 1))
		var player := player_scene.instantiate() as Player
		player.setup(slot)
		_root.add_child(player)
		player.global_position = positions[i]
		player.face(Vector3(0.4, 0, 1.0).normalized())
		player.set_physics_process(false)
		player.tag_label.visible = false


func _place_model(file: String, pos: Vector3, target_height: float, yaw_deg: float, kind: int) -> void:
	var scene: PackedScene = load(KENNEY + file)
	var model: Node3D = scene.instantiate()
	_root.add_child(model)
	var aabb: AABB = _aabb(model)
	var s: float = target_height / maxf(aabb.size.y, 0.01)
	pos.y -= aabb.position.y * s
	model.scale = Vector3.ONE * s
	model.position = pos
	model.rotation_degrees.y = yaw_deg
	Look.restyle(model, kind)


func _aabb(node: Node) -> AABB:
	var box := AABB()
	var first := true
	for mesh: MeshInstance3D in node.find_children("*", "MeshInstance3D", true, false):
		var rel: Transform3D = (node as Node3D).global_transform.affine_inverse() * mesh.global_transform
		var b: AABB = rel * mesh.get_aabb()
		if first:
			box = b
			first = false
		else:
			box = box.merge(b)
	return box


func _set_camera(cam: String) -> void:
	if _camera and is_instance_valid(_camera):
		_camera.queue_free()
	_camera = Camera3D.new()
	_root.add_child(_camera)
	if cam == "spiel":
		_camera.fov = 50.0
		_camera.position = Vector3(0, 24, 14)
		_camera.look_at(Vector3(0, 0, 1.5), Vector3.UP)
	else:
		_camera.fov = 46.0
		_camera.position = Vector3(3.6, 2.3, 10.5)
		_camera.look_at(Vector3(-1.5, 2.2, -8.0), Vector3.UP)
	_camera.current = true
	Settings.apply_graphics()


func _shot(file_name: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(_shot_dir.path_join(file_name + ".png"))
	print("SHOT %s" % file_name)


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().process_frame
