class_name HubProps
extends RefCounted
## Park-Baukasten für das Lobby-Gelände (D99, D100, D101, D102).
## Erzeugt Festplatz (Plaza), Sternwege zu den vier Zonen, Randbegrenzungen
## sowie Kulissenelemente (Riesenrad, Achterbahn, Zelte, Laternen, Bäume, Buden).

const TREE_SCENE: PackedScene = preload("res://assets/third_party/kenney_coaster-kit/tree.glb")
const TREE_LARGE_SCENE: PackedScene = preload("res://assets/third_party/kenney_coaster-kit/tree-large.glb")
const STALL_FOOD_SCENE: PackedScene = preload("res://assets/third_party/kenney_coaster-kit/stall-food.glb")
const STALL_DRINKS_SCENE: PackedScene = preload("res://assets/third_party/kenney_coaster-kit/stall-drinks.glb")
const STALL_INFO_SCENE: PackedScene = preload("res://assets/third_party/kenney_coaster-kit/stall-information.glb")


## Baut das gesamte Basis-Gelände des Hubs auf.
static func build_hub_world(root: Node3D) -> void:
	var terrain := Node3D.new()
	terrain.name = "Terrain"
	root.add_child(terrain)

	var scenery := Node3D.new()
	scenery.name = "Scenery"
	root.add_child(scenery)

	_build_ground_and_plaza(terrain)
	_build_radial_paths(terrain)
	_build_zone_grounds(terrain)
	_build_perimeter_walls(terrain)
	_build_park_props(scenery)
	_build_foliage_and_stalls(scenery)
	_build_playground(terrain)


# --- 1. Boden & Zentraler Festplatz (Plaza) ---

static func _build_ground_and_plaza(parent: Node3D) -> void:
	# Haupt-Grasfläche (105 m x 105 m)
	var grass_green := Color("#62ab4c")
	StageKit.add_box(parent, Vector3(105, 1.0, 105), Vector3(0, -0.5, 0), grass_green, Vector3.ZERO, Look.Kind.GRASS)

	# Zentraler Festplatz (Plaza, Radius 12 m, leicht erhaben auf Y = 0.08)
	var plaza_stone := Color("#ebd8b0")
	var plaza_kerb := Color("#8a7258")
	var plaza_body := StageKit.add_cylinder(parent, 12.0, 0.2, Vector3(0, 0.1, 0), plaza_stone, Look.Kind.STONE)
	plaza_body.name = "CentralPlaza"

	# Äußerer Randstein / Zierring um die Plaza
	var kerb_ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 11.8
	torus.outer_radius = 12.3
	torus.rings = 36
	torus.ring_segments = 6
	kerb_ring.mesh = torus
	kerb_ring.material_override = Look.surface(plaza_kerb, Look.Kind.STONE)
	kerb_ring.position = Vector3(0, 0.22, 0)
	kerb_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(kerb_ring)

	# Dekorativer Park-Brunnen im Zentrum der Plaza
	_build_fountain(parent, Vector3(0, 0, 0))


static func _build_fountain(parent: Node3D, pos: Vector3) -> void:
	var fountain := Node3D.new()
	fountain.name = "PlazaFountain"
	fountain.position = pos
	parent.add_child(fountain)

	var stone_mat: Material = Look.surface(Color("#9aa3ad"), Look.Kind.STONE)
	var marble_mat: Material = Look.surface(Color("#f0ede6"), Look.Kind.GLOSSY)
	var water_mat: Material = Look.water_material()

	# Äußeres Becken (Cylinder mit Collision)
	StageKit.add_cylinder(fountain, 3.2, 0.7, Vector3(0, 0.35, 0), Color("#8a95a1"), Look.Kind.STONE)

	# Wasserfläche im Becken
	var water_mesh := MeshInstance3D.new()
	var water_cyl := CylinderMesh.new()
	water_cyl.top_radius = 2.9
	water_cyl.bottom_radius = 2.9
	water_cyl.height = 0.1
	water_mesh.mesh = water_cyl
	water_mesh.material_override = water_mat
	water_mesh.position = Vector3(0, 0.65, 0)
	fountain.add_child(water_mesh)

	# Mittelsäule mit oberer Schale
	var pillar := MeshInstance3D.new()
	var pillar_mesh := CylinderMesh.new()
	pillar_mesh.top_radius = 0.6
	pillar_mesh.bottom_radius = 0.8
	pillar_mesh.height = 1.4
	pillar.mesh = pillar_mesh
	pillar.material_override = marble_mat
	pillar.position = Vector3(0, 1.0, 0)
	pillar.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	fountain.add_child(pillar)

	var top_bowl := MeshInstance3D.new()
	var bowl_mesh := CylinderMesh.new()
	bowl_mesh.top_radius = 1.3
	bowl_mesh.bottom_radius = 0.5
	bowl_mesh.height = 0.4
	top_bowl.mesh = bowl_mesh
	top_bowl.material_override = marble_mat
	top_bowl.position = Vector3(0, 1.8, 0)
	top_bowl.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	fountain.add_child(top_bowl)

	# Zierkugel mit Fontänen-Spitze
	var top_orb := MeshInstance3D.new()
	var orb_mesh := SphereMesh.new()
	orb_mesh.radius = 0.4
	orb_mesh.height = 0.8
	top_orb.mesh = orb_mesh
	top_orb.material_override = Look.surface(Color("#ffd75e"), Look.Kind.METAL)
	top_orb.position = Vector3(0, 2.2, 0)
	top_orb.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	fountain.add_child(top_orb)


# --- 2. Sternwege (Radial Paths, D99) ---

static func _build_radial_paths(parent: Node3D) -> void:
	# 1. Nord-Weg: Zum Kletterturm & Parkour (Z: -12 bis -32, Breite 4.5 m)
	var wood_color := Color("#bf9d70")
	StageKit.add_box(parent, Vector3(4.5, 0.2, 22.0), Vector3(0, 0.1, -22.5), wood_color, Vector3.ZERO, Look.Kind.WOOD)
	_build_path_arch(parent, Vector3(0, 0, -12.5), 0.0, "PARKOUR & TURM", Color("#ff5d73"))

	# 2. Ost-Weg: Zum Rummelplatz & Karussells (X: 12 bis 32, Breite 4.5 m)
	var brick_red := Color("#c76f57")
	StageKit.add_box(parent, Vector3(22.0, 0.2, 4.5), Vector3(22.5, 0.1, 0), brick_red, Vector3.ZERO, Look.Kind.STONE)
	_build_path_arch(parent, Vector3(12.5, 0, 0), -90.0, "RUMMELPLATZ", Color("#ffb340"))

	# 3. Süd-Weg: Zum Attraktions-Boulevard / Minispiele (Z: 12 bis 32, Breite 5.5 m)
	var stone_gray := Color("#b5a084")
	StageKit.add_box(parent, Vector3(5.5, 0.2, 22.0), Vector3(0, 0.1, 22.5), stone_gray, Vector3.ZERO, Look.Kind.STONE)
	_build_path_arch(parent, Vector3(0, 0, 12.5), 180.0, "ATTRAKTIONEN", Color("#42a5f5"))

	# 4. West-Weg: Zur Spielzeug-Wiese & Wasserbereich (X: -12 bis -32, Breite 4.5 m)
	var boardwalk_color := Color("#a87d4f")
	StageKit.add_box(parent, Vector3(22.0, 0.2, 4.5), Vector3(-22.5, 0.1, 0), boardwalk_color, Vector3.ZERO, Look.Kind.WOOD)
	_build_path_arch(parent, Vector3(-12.5, 0, 0), 90.0, "SPIELZEUG-WIESE", Color("#66bb6a"))


static func _build_path_arch(parent: Node3D, pos: Vector3, rot_y_deg: float, title_text: String, banner_color: Color) -> void:
	var arch := Node3D.new()
	arch.name = "Arch_" + title_text.replace(" ", "_")
	arch.position = pos
	arch.rotation_degrees = Vector3(0, rot_y_deg, 0)
	parent.add_child(arch)

	var frame_mat: Material = Look.surface(Color("#f0ede6"), Look.Kind.WOOD)
	var banner_mat: Material = Look.surface(banner_color, Look.Kind.FABRIC)
	var gold_mat: Material = Look.surface(Color("#ffd75e"), Look.Kind.METAL)

	# Zwei Pfeiler (Höhe 4.2 m, Abstand 5.2 m)
	for side: float in [-2.5, 2.5]:
		var post := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.2
		cyl.bottom_radius = 0.25
		cyl.height = 4.2
		post.mesh = cyl
		post.material_override = frame_mat
		post.position = Vector3(side, 2.1, 0)
		post.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		arch.add_child(post)

		# Goldene Kugel oben
		var knob := MeshInstance3D.new()
		knob.mesh = SphereMesh.new()
		knob.scale = Vector3.ONE * 0.35
		knob.material_override = gold_mat
		knob.position = Vector3(side, 4.3, 0)
		knob.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		arch.add_child(knob)

	# Querbalken
	var beam := MeshInstance3D.new()
	var beam_mesh := BoxMesh.new()
	beam_mesh.size = Vector3(5.4, 0.35, 0.4)
	beam.mesh = beam_mesh
	beam.material_override = frame_mat
	beam.position = Vector3(0, 4.0, 0)
	beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	arch.add_child(beam)

	# Banner-Schild
	var sign_mesh := MeshInstance3D.new()
	var sign_box := BoxMesh.new()
	sign_box.size = Vector3(4.2, 0.9, 0.12)
	sign_mesh.mesh = sign_box
	sign_mesh.material_override = banner_mat
	sign_mesh.position = Vector3(0, 3.4, 0)
	sign_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	arch.add_child(sign_mesh)

	# 3D Text / Beschriftung
	var label := Label3D.new()
	label.text = title_text
	label.font_size = 46
	label.outline_size = 8
	label.modulate = Color.WHITE
	label.outline_modulate = Color("#222222")
	label.position = Vector3(0, 3.4, 0.08)
	arch.add_child(label)


# --- 3. Themen-Zonen Plattformen ---

static func _build_zone_grounds(parent: Node3D) -> void:
	# Nord-Zone: Turm-Fundament (Z = -36, 16 m x 16 m, feste Steinplattform)
	StageKit.add_box(parent, Vector3(16, 0.3, 16), Vector3(0, 0.15, -36), Color("#d0be9b"), Vector3.ZERO, Look.Kind.STONE)

	# Ost-Zone: Rummel-Plaza (X = 35, runde Kirmesfläche Radius 11 m)
	var rummel_ground := StageKit.add_cylinder(parent, 11.0, 0.25, Vector3(35, 0.12, 0), Color("#db7b67"), Look.Kind.STONE)
	rummel_ground.name = "RummelPlaza"

	# Süd-Zone: Attraktions-Boulevard (Z = 35, 20 m x 14 m Pflasterfläche)
	StageKit.add_box(parent, Vector3(20, 0.25, 14), Vector3(0, 0.12, 35), Color("#c9b596"), Vector3.ZERO, Look.Kind.STONE)

	# West-Zone: Spielzeug-Wiese & Wasserbassin (X = -35, 18 m x 18 m Holzsteg mit Teich)
	StageKit.add_box(parent, Vector3(18, 0.25, 18), Vector3(-35, 0.12, 0), Color("#74be59"), Vector3.ZERO, Look.Kind.GRASS)
	# Wasserteich neben der Spielzeug-Wiese
	_build_park_pond(parent, Vector3(-35, 0, -14))


static func _build_park_pond(parent: Node3D, pos: Vector3) -> void:
	var pond := Node3D.new()
	pond.name = "ParkPond"
	pond.position = pos
	parent.add_child(pond)

	# Stein-Uferrand
	StageKit.add_cylinder(pond, 7.5, 0.4, Vector3(0, 0.1, 0), Color("#8e98a3"), Look.Kind.STONE)

	# Wasserfläche
	var water := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 6.9
	cyl.bottom_radius = 6.9
	cyl.height = 0.1
	water.mesh = cyl
	water.material_override = Look.water_material()
	water.position = Vector3(0, 0.25, 0)
	pond.add_child(water)


# --- 4. Randbegrenzung & Zäune (Perimeter) ---

static func _build_perimeter_walls(parent: Node3D) -> void:
	var wall_color := Color("#9da6b0")
	var hedge_color := Color("#4a8c39")
	var radius: float = 49.0
	var segments: int = 24

	var perimeter := Node3D.new()
	perimeter.name = "Perimeter"
	parent.add_child(perimeter)

	for i: int in segments:
		var angle: float = TAU * float(i) / float(segments)
		var next_angle: float = TAU * float(i + 1) / float(segments)
		var p1 := Vector3(cos(angle) * radius, 0, sin(angle) * radius)
		var p2 := Vector3(cos(next_angle) * radius, 0, sin(next_angle) * radius)
		var mid := (p1 + p2) * 0.5
		var length: float = p1.distance_to(p2)
		var dir := (p2 - p1).normalized()
		var rot_y: float = rad_to_deg(atan2(dir.x, dir.z))

		# Steinmauer unten (Höhe 1.4 m)
		StageKit.add_box(perimeter, Vector3(0.5, 1.4, length + 0.1), Vector3(mid.x, 0.7, mid.z), wall_color, Vector3(0, rot_y, 0), Look.Kind.STONE)

		# Grüne Hecke oben drauf (Höhe 1.0 m)
		var hedge := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.7, 1.0, length + 0.1)
		hedge.mesh = box
		hedge.material_override = Look.surface(hedge_color, Look.Kind.GRASS)
		hedge.position = Vector3(mid.x, 1.9, mid.z)
		hedge.rotation_degrees = Vector3(0, rot_y, 0)
		hedge.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		perimeter.add_child(hedge)

		# Ziersäule an den Ecken
		var pillar := MeshInstance3D.new()
		var pcyl := CylinderMesh.new()
		pcyl.top_radius = 0.4
		pcyl.bottom_radius = 0.45
		pcyl.height = 2.6
		pillar.mesh = pcyl
		pillar.material_override = Look.surface(Color("#f0ede6"), Look.Kind.STONE)
		pillar.position = Vector3(p1.x, 1.3, p1.z)
		pillar.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		perimeter.add_child(pillar)


# --- 5. Park-Props & Kulisse (ParkProps Integration) ---

static func _build_park_props(parent: Node3D) -> void:
	# 1. Riesenrad in der Nord-Ost-Kulisse (dreht sich kontinuierlich)
	var ferris := ParkProps.ferris_wheel(11.0, 12)
	ferris.position = Vector3(42.0, 0.0, -32.0)
	ferris.rotation_degrees = Vector3(0, -35.0, 0)
	parent.add_child(ferris)

	# 2. Achterbahn-Kulisse am nördlichen Horizont
	var coaster_points: Array[Vector3] = [
		Vector3(-44, 6, -42),
		Vector3(-22, 16, -46),
		Vector3(0, 10, -45),
		Vector3(25, 20, -44),
		Vector3(45, 8, -40),
		Vector3(44, 4, -20),
		Vector3(38, 12, 12),
		Vector3(15, 6, 44),
		Vector3(-15, 8, 44),
		Vector3(-42, 14, 18),
		Vector3(-45, 7, -15),
	]
	var coaster := ParkProps.coaster(coaster_points, 0.0, Color("#ff5d73"), Color("#f4f1ff"))
	parent.add_child(coaster)

	# 3. Zirkuszelte
	var tent_east := ParkProps.tent(4.0, Color("#ff5d73"), Color("#fff6e8"))
	tent_east.position = Vector3(36.0, 0.0, 18.0)
	parent.add_child(tent_east)

	var tent_west := ParkProps.tent(3.5, Color("#8e44ad"), Color("#ffd75e"))
	tent_west.position = Vector3(-36.0, 0.0, -26.0)
	parent.add_child(tent_west)

	# 4. Lichterketten über dem zentralen Festplatz
	parent.add_child(ParkProps.string_lights(Vector3(-10, 4.5, -10), Vector3(10, 4.5, 10), 14, 1.0))
	parent.add_child(ParkProps.string_lights(Vector3(10, 4.5, -10), Vector3(-10, 4.5, 10), 14, 1.0))

	# 5. Park-Laternen entlang der Wege und um die Plaza
	var lamp_positions: Array[Vector3] = [
		Vector3(-8, 0, -8), Vector3(8, 0, -8),
		Vector3(-8, 0, 8), Vector3(8, 0, 8),
		Vector3(-3, 0, -20), Vector3(3, 0, -20),
		Vector3(-3, 0, 20), Vector3(3, 0, 20),
		Vector3(20, 0, -3), Vector3(20, 0, 3),
		Vector3(-20, 0, -3), Vector3(-20, 0, 3),
		Vector3(35, 0, -12), Vector3(35, 0, 12),
		Vector3(-35, 0, 12), Vector3(-35, 0, -6),
	]
	for pos: Vector3 in lamp_positions:
		var lamp := ParkProps.lamp_post(3.4)
		lamp.position = pos
		parent.add_child(lamp)

	# 6. Wimpelmasten mit bunten Flaggen
	var flag_positions: Array[Vector3] = [
		Vector3(-12, 0, -12), Vector3(12, 0, -12),
		Vector3(12, 0, 12), Vector3(-12, 0, 12),
		Vector3(0, 0, -36), Vector3(0, 0, 36),
	]
	var flag_colors: Array[Color] = [Color("#ff5d73"), Color("#ffcf3f"), Color("#41c7a9"), Color("#5aa8ff")]
	for i: int in flag_positions.size():
		var pole := ParkProps.flag_pole(5.2, flag_colors[i % flag_colors.size()])
		pole.position = flag_positions[i]
		parent.add_child(pole)


# --- 6. Bäume & Buden (Assets aus Kenney Coaster Kit) ---

static func _build_foliage_and_stalls(parent: Node3D) -> void:
	# Bäume an den Rasenflächen
	var tree_data: Array[Dictionary] = [
		{"pos": Vector3(-18, 0, -18), "large": true},
		{"pos": Vector3(-24, 0, -14), "large": false},
		{"pos": Vector3(-16, 0, -25), "large": false},
		{"pos": Vector3(18, 0, -18), "large": true},
		{"pos": Vector3(25, 0, -20), "large": false},
		{"pos": Vector3(-18, 0, 18), "large": true},
		{"pos": Vector3(-22, 0, 24), "large": false},
		{"pos": Vector3(18, 0, 18), "large": true},
		{"pos": Vector3(22, 0, 24), "large": false},
		{"pos": Vector3(14, 0, 28), "large": false},
		{"pos": Vector3(-28, 0, 10), "large": true},
		{"pos": Vector3(28, 0, -10), "large": true},
	]
	for t: Dictionary in tree_data:
		var scene: PackedScene = TREE_LARGE_SCENE if t["large"] else TREE_SCENE
		var tree_node: Node3D = scene.instantiate() as Node3D
		tree_node.position = t["pos"]
		Look.restyle(tree_node, Look.Kind.WOOD)
		parent.add_child(tree_node)

	# Kirmes- und Verpflegungs-Buden im Rummel- und Boulevard-Bereich
	if STALL_FOOD_SCENE != null:
		var stall_food: Node3D = STALL_FOOD_SCENE.instantiate() as Node3D
		stall_food.position = Vector3(28.0, 0.12, 8.0)
		stall_food.rotation_degrees = Vector3(0, -70.0, 0)
		Look.restyle(stall_food, Look.Kind.WOOD)
		parent.add_child(stall_food)

	if STALL_DRINKS_SCENE != null:
		var stall_drinks: Node3D = STALL_DRINKS_SCENE.instantiate() as Node3D
		stall_drinks.position = Vector3(28.0, 0.12, -8.0)
		stall_drinks.rotation_degrees = Vector3(0, -110.0, 0)
		Look.restyle(stall_drinks, Look.Kind.WOOD)
		parent.add_child(stall_drinks)

	if STALL_INFO_SCENE != null:
		var stall_info: Node3D = STALL_INFO_SCENE.instantiate() as Node3D
		stall_info.position = Vector3(-8.0, 0.1, 10.0)
		stall_info.rotation_degrees = Vector3(0, 30.0, 0)
		Look.restyle(stall_info, Look.Kind.WOOD)
		parent.add_child(stall_info)


# --- 7. Bewegungs- & Platforming-Spielplatz (D103, D104, D105, D106) ---

static func _build_playground(parent: Node3D) -> void:
	var playground := Node3D.new()
	playground.name = "Playground"
	parent.add_child(playground)

	# 1. Rummelplatz-Karussell (D105: rotierende Zentrifugalkraft)
	var carousel := HubCarousel.new()
	carousel.name = "Carousel"
	carousel.position = Vector3(35.0, 0.25, 0.0)
	playground.add_child(carousel)

	# 2. Großes Trampolin im Rummel-Bereich (D103: dynamisches Federn)
	var tramp_east := HubTrampoline.new()
	tramp_east.name = "TrampolineEast"
	tramp_east.position = Vector3(35.0, 0.15, -13.0)
	tramp_east.radius = 2.6
	playground.add_child(tramp_east)

	# 3. Spielplatz-Rutsche in der West-Zone (D104: Null-Reibungs-Gleitfläche)
	var slide := HubSlide.new()
	slide.name = "Slide"
	slide.position = Vector3(-32.0, 0.15, 14.0)
	slide.rotation_degrees = Vector3(0, 90.0, 0) # Rutscht nach Osten Richtung Weg
	playground.add_child(slide)

	# 4. Physikalische Wippe (D106: Gewichts-Reaktion)
	var seesaw := HubSeesaw.new()
	seesaw.name = "Seesaw"
	seesaw.position = Vector3(-34.0, 0.15, 0.0)
	playground.add_child(seesaw)

	# 5. Zwillings-Trampoline in der West-Zone
	var tramp_west1 := HubTrampoline.new()
	tramp_west1.name = "TrampolineWest1"
	tramp_west1.position = Vector3(-25.0, 0.15, -8.0)
	tramp_west1.radius = 2.0
	playground.add_child(tramp_west1)

	var tramp_west2 := HubTrampoline.new()
	tramp_west2.name = "TrampolineWest2"
	tramp_west2.position = Vector3(-19.0, 0.15, -8.0)
	tramp_west2.radius = 2.0
	playground.add_child(tramp_west2)

	# 6. Schwebeladende Plattform über dem Teich (D106: horizontales Pendel)
	var pond_ferry := HubMovingPlatform.new()
	pond_ferry.name = "PondFerry"
	pond_ferry.position = Vector3(-40.0, 0.4, -14.0)
	pond_ferry.travel_offset = Vector3(10.0, 0.0, 0.0)
	pond_ferry.travel_duration = 4.0
	pond_ferry.platform_size = Vector3(3.4, 0.3, 3.4)
	pond_ferry.platform_color = Color("#bf9d70")
	playground.add_child(pond_ferry)

	# 7. Vertikaler Schwebelift nahe Nord-Weg (D106: Vertikallift)
	var tower_lift := HubMovingPlatform.new()
	tower_lift.name = "TowerLift"
	tower_lift.position = Vector3(-5.0, 0.2, -26.0)
	tower_lift.travel_offset = Vector3(0.0, 6.0, 0.0)
	tower_lift.travel_duration = 3.2
	tower_lift.platform_size = Vector3(2.8, 0.35, 2.8)
	tower_lift.platform_color = Color("#ebd8b0")
	playground.add_child(tower_lift)
