extends Node
## Rendert Bildvarianten für Haltepunkt 1 (WP 5 & WP 5a):
## 1. Figuren-Ausdrücke & Partyhut
## 2. Drei Blaster-Varianten (A, E, K)
##
## Aufruf:
##   .\Godot_v4.7.2-stable_win64_console.exe --path . --resolution 1280x720 -- --smoke-haltepunkt1

const SHOT_DIR: String = "docs/screenshots/v0_5/haltepunkt1"
const PLAYER_SCENE: PackedScene = preload("res://player/player.tscn")
const BLASTER_SCRIPT: GDScript = preload("res://core/weapons/blaster.gd")
const BLASTER_A: PackedScene = preload("res://core/weapons/blaster_a.tscn")
const BLASTER_E: PackedScene = preload("res://core/weapons/blaster_e.tscn")
const BLASTER_K: PackedScene = preload("res://core/weapons/blaster_k.tscn")

var _root: Node3D
var _camera: Camera3D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_run.call_deferred()


func _run() -> void:
	await _frames(3)
	DirAccess.make_dir_recursive_absolute(SHOT_DIR)
	var host: Node = get_tree().current_scene
	host.process_mode = Node.PROCESS_MODE_DISABLED
	for child: Node in host.get_children():
		child.queue_free()

	Settings.graphics_quality = 2
	Settings.apply_graphics()
	Look.use_mood(Look.Mood.NOON)

	# --- 1. Figuren mit Ausdrücken & Hütchen ---
	_build_figure_scene(host)
	await _frames(15)
	await _shot("figuren_ausdruecke")
	_root.queue_free()
	await _frames(3)

	# --- 2. Blaster Variante A (Kompakt) ---
	_build_weapon_scene(host, BLASTER_A, "Kompakt-Blaster (Variante A)")
	await _frames(15)
	await _shot("blaster_variante_a")
	_root.queue_free()
	await _frames(3)

	# --- 3. Blaster Variante E (Doppelrohr) ---
	_build_weapon_scene(host, BLASTER_E, "Doppel-Blaster (Variante B)")
	await _frames(15)
	await _shot("blaster_variante_e")
	_root.queue_free()
	await _frames(3)

	# --- 4. Blaster Variante K (Karabiner) ---
	_build_weapon_scene(host, BLASTER_K, "Karabiner-Blaster (Variante C)")
	await _frames(15)
	await _shot("blaster_variante_k")
	_root.queue_free()
	await _frames(3)

	print("HALTEPUNKT 1 SCREENSHOTS FERTIG in %s" % SHOT_DIR)
	get_tree().quit()


func _build_figure_scene(host: Node) -> void:
	_root = Node3D.new()
	host.add_child(_root)
	Look.add_environment(_root)
	_build_podest(_root)

	var colors: Array[Color] = [
		Color("#2a75d3"), # Blau (Normal)
		Color("#e67e22"), # Orange (Happy + Partyhut)
		Color("#27ae60"), # Grün (Shocked)
		Color("#e84393"), # Pink (Sad)
	]
	var expressions: Array[int] = [
		PlayerVisual.FaceExpression.NORMAL,
		PlayerVisual.FaceExpression.HAPPY,
		PlayerVisual.FaceExpression.SHOCKED,
		PlayerVisual.FaceExpression.SAD,
	]
	var labels: Array[String] = ["Normal", "Glücklich (mit Partyhut)", "Erschrocken", "Geschlagen"]

	for i: int in 4:
		var p: Player = PLAYER_SCENE.instantiate()
		_root.add_child(p)
		p.position = Vector3((i - 1.5) * 1.5, 0.0, 0.0)
		p.rotation_degrees.y = 180.0 + (10.0 - i * 6.0)
		p.visual.set_color(colors[i])
		p.tag_label.visible = false
		p.visual.set_expression(expressions[i])
		if i == 1:
			p.visual.show_hat(true)

	_camera = Camera3D.new()
	_camera.fov = 42.0
	_root.add_child(_camera)
	_camera.position = Vector3(0.0, 0.95, 3.5)
	_camera.look_at(Vector3(0.0, 0.75, 0.0), Vector3.UP)
	_camera.current = true


func _build_weapon_scene(host: Node, weapon_scene: PackedScene, title: String) -> void:
	_root = Node3D.new()
	host.add_child(_root)
	Look.add_environment(_root)
	_build_podest(_root)

	# Figur hält die Waffe (Blick schräg zur Kamera)
	var p: Player = PLAYER_SCENE.instantiate()
	_root.add_child(p)
	p.position = Vector3(-0.55, 0.0, 0.0)
	p.rotation_degrees.y = 150.0
	p.visual.set_color(Color("#2a75d3"))
	p.tag_label.visible = false
	p.visual.set_expression(PlayerVisual.FaceExpression.SMUG)

	# Blaster an Figur befestigen (in die Hände/Flanke)
	var weapon: Blaster = weapon_scene.instantiate()
	_root.add_child(weapon)
	weapon.position = Vector3(-0.15, 0.68, 0.2)
	weapon.rotation_degrees = Vector3(5.0, 140.0, -5.0)
	weapon.scale = Vector3.ONE * 1.4

	# Zusätzliche Nahansicht des Blasters auf einem kleinen Deko-Podest
	var showcase_weapon: Blaster = weapon_scene.instantiate()
	_root.add_child(showcase_weapon)
	showcase_weapon.position = Vector3(0.75, 0.92, 0.15)
	showcase_weapon.rotation_degrees = Vector3(12.0, -135.0, 5.0)
	showcase_weapon.scale = Vector3.ONE * 1.7

	var pedestal := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.45
	cyl.bottom_radius = 0.5
	cyl.height = 0.6
	pedestal.mesh = cyl
	pedestal.position = Vector3(0.75, 0.3, 0.15)
	pedestal.material_override = Look.surface(Color("#f0e6d2"), Look.Kind.STONE)
	_root.add_child(pedestal)

	_camera = Camera3D.new()
	_camera.fov = 40.0
	_root.add_child(_camera)
	_camera.position = Vector3(0.1, 1.05, 2.8)
	_camera.look_at(Vector3(0.1, 0.75, 0.1), Vector3.UP)
	_camera.current = true


func _build_podest(root: Node3D) -> void:
	var floor_mesh := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 6.0
	cyl.bottom_radius = 6.0
	cyl.height = 0.4
	cyl.radial_segments = 48
	floor_mesh.mesh = cyl
	floor_mesh.position.y = -0.2
	floor_mesh.material_override = Look.surface(Color("#dfc299"), Look.Kind.WOOD)
	root.add_child(floor_mesh)


func _shot(file_name: String) -> void:
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	var path: String = SHOT_DIR.path_join(file_name + ".png")
	img.save_png(path)
	print("SHOT: %s" % path)


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().process_frame
