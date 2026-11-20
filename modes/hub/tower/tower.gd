class_name HubTower
extends Node3D
## Kletterturm als Außenspirale (D122, ersetzt die Bauform aus D107).
##
## Aufbau wie eine umgedrehte Stufentorte: Um einen schlanken Mast liegen Netz-Etagen bei 6, 12 und 18 m,
## jede kleiner als die darunter. Der Weg einer Passage läuft außen um die Etage darunter, auf der
## Kameraseite (Süden, +Z) als Halbkreis. Wer fällt, landet so auf dem Netz der zuletzt erreichten Etage
## (bzw. am Boden), ohne Teleport. Keine Etage liegt als Decke über einem Weg.
##
## Sprungphysik der Figur (Stand v0.7): Sprunghöhe ca. 1,67 m, Lauftempo 7 m/s. Stufen steigen um
## 0,67 m (höher als die Stufenhilfe im Park, also echte Sprünge), Lücken 0,7 bis 1,9 m.
## Prüfung: tests/smoke/hub_smoke.gd springt jede Stufe mit echter Eingabe und Physik nach.

## Höhe einer Etage über der vorigen (m).
const LEVEL_HEIGHT: float = 6.0
## Stufen je Passage (inklusive der letzten auf Etagenhöhe).
const STEPS_PER_PASSAGE: int = 9
## Radius des Wegs je Passage (m, um die Turmmitte).
const PATH_RADII: Array[float] = [10.5, 7.0, 4.6]
## Radius der Netz-Etagen bei 6, 12 und 18 m (die letzte ist die Spitze).
const LEVEL_RADII: Array[float] = [8.6, 5.8, 3.5]

const WOOD := Color("#c29057")
const STEEL := Color("#8fa3b5")
const POLE := Color("#f1c40f")
const NET := Color("#2c3e50")
const RIM := Color("#ffd75e")

var crown: HubCrown
var buzzer: HubConfettiBuzzer
## Alle Trittflächen in Kletterreihenfolge (für Tests und KI): Mittelpunkt der Oberseite, lokal.
var route: Array[Vector3] = []


func _ready() -> void:
	_build_mast()
	_build_passage(0, Vector2(2.2, 2.2), false)
	_build_level(0)
	_build_passage(1, Vector2(1.6, 1.6), true)
	_build_level(1)
	_build_passage(2, Vector2.ZERO, false)
	_build_summit()
	_build_start_sign()


## Winkel der i-ten Stufe einer Passage. Passage 0 und 2 laufen von West über Süd nach Ost, Passage 1 zurück.
static func step_angle(passage: int, index: int) -> float:
	var t: float = float(index) / float(STEPS_PER_PASSAGE - 1)
	return lerpf(PI, 0.0, t) if passage % 2 == 0 else lerpf(0.0, PI, t)


## Oberkante der i-ten Stufe (lokal, m).
static func step_top(passage: int, index: int) -> float:
	return float(passage) * LEVEL_HEIGHT + float(index + 1) * LEVEL_HEIGHT / float(STEPS_PER_PASSAGE)


## Mittelpunkt der Oberseite einer Stufe (lokal).
static func step_position(passage: int, index: int) -> Vector3:
	var angle: float = step_angle(passage, index)
	var r: float = PATH_RADII[passage]
	return Vector3(cos(angle) * r, step_top(passage, index), sin(angle) * r)


func _build_mast() -> void:
	var mast := StageKit.add_cylinder(self, 0.8, LEVEL_HEIGHT * 3.0, Vector3(0, LEVEL_HEIGHT * 1.5, 0), Color("#4a5568"), Look.Kind.METAL)
	mast.name = "TowerMast"


func _build_passage(passage: int, step_size: Vector2, with_lift: bool) -> void:
	var base_y: float = float(passage) * LEVEL_HEIGHT
	for i: int in STEPS_PER_PASSAGE:
		var top: Vector3 = step_position(passage, i)
		var yaw_deg: float = -rad_to_deg(step_angle(passage, i))
		route.append(top)
		if passage == 2:
			# Passage 3: runde Balancierpfähle (Präzision)
			var pole := StageKit.add_cylinder(self, 0.55, 0.3, top - Vector3(0, 0.15, 0), POLE, Look.Kind.METAL)
			pole.name = "P3_Pole_%d" % i
		elif with_lift and i == STEPS_PER_PASSAGE / 2:
			# Passage 2, Mitte: Plattform fährt auf und ab (Timing)
			var lift := HubMovingPlatform.new()
			lift.name = "P2_Lift"
			lift.platform_size = Vector3(step_size.x, 0.35, step_size.y)
			lift.platform_color = Color("#7ed6df")
			lift.travel_offset = Vector3(0.0, 1.4, 0.0)
			lift.travel_duration = 1.6
			lift.pause_time = 0.6
			lift.position = top - Vector3(0, 0.175 + 0.7, 0)
			add_child(lift)
		else:
			var color: Color = WOOD if passage == 0 else STEEL
			var kind: int = Look.Kind.WOOD if passage == 0 else Look.Kind.METAL
			var step := StageKit.add_box(self, Vector3(step_size.x, 0.4, step_size.y), top - Vector3(0, 0.2, 0), color, Vector3(0, yaw_deg, 0), kind)
			step.name = "P%d_Step_%d" % [passage + 1, i]
		# Stütze bis zur Ebene darunter (nur Optik, damit nichts schwebt)
		var support_height: float = top.y - 0.4 - base_y
		if support_height > 0.3 and not (with_lift and i == STEPS_PER_PASSAGE / 2):
			_add_visual_cylinder(0.1, support_height, Vector3(top.x, base_y + support_height * 0.5, top.z), Color("#6b5b4b"))


## Netz-Etage: runde, begehbare Scheibe. Fängt Stürze aus der Passage darüber auf.
func _build_level(level: int) -> void:
	var y: float = float(level + 1) * LEVEL_HEIGHT
	var radius: float = LEVEL_RADII[level]
	var net := StageKit.add_cylinder(self, radius, 0.2, Vector3(0, y - 0.1, 0), NET, Look.Kind.RUBBER)
	net.name = "Level_%d" % (level + 1)
	var rim := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = radius - 0.12
	torus.outer_radius = radius + 0.08
	torus.rings = 48
	torus.ring_segments = 6
	rim.mesh = torus
	rim.material_override = Look.surface(RIM, Look.Kind.METAL)
	rim.position = Vector3(0, y, 0)
	rim.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(rim)
	var label := Label3D.new()
	label.text = "%d m" % int(y)
	label.font_size = 64
	label.outline_size = 10
	label.modulate = RIM
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, y + 1.6, 0)
	add_child(label)


func _build_summit() -> void:
	var y: float = LEVEL_HEIGHT * 3.0
	var radius: float = LEVEL_RADII[2]
	var deck := StageKit.add_cylinder(self, radius, 0.3, Vector3(0, y - 0.15, 0), Color("#f0ede6"), Look.Kind.STONE)
	deck.name = "SummitDeck"

	var railing := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = radius - 0.1
	torus.outer_radius = radius + 0.1
	torus.rings = 36
	torus.ring_segments = 6
	railing.mesh = torus
	railing.material_override = Look.surface(RIM, Look.Kind.METAL)
	railing.position = Vector3(0, y + 0.05, 0)
	railing.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(railing)

	# Kein Dach über der Spitze: Aus der Kamera-Neigung verdeckte es die Figuren oben.
	# Stattdessen ein Fahnenmast als Wegmarke, von überall im Park zu sehen.
	var flag := ParkProps.flag_pole(5.0, Color("#ff5d73"))
	flag.position = Vector3(radius - 0.6, y, -radius * 0.5)
	add_child(flag)

	# Siegerkrone schwebt über der Spitze (D100, D108)
	crown = HubCrown.new()
	crown.name = "SummitCrown"
	crown.summit_home_position = to_global(Vector3(0, y + 1.3, -1.2))
	add_child(crown)

	# Konfetti-Buzzer am vorderen Rand (zur Kamera)
	buzzer = HubConfettiBuzzer.new()
	buzzer.name = "SummitBuzzer"
	buzzer.position = Vector3(0, y, 1.8)
	add_child(buzzer)


func _build_start_sign() -> void:
	var start: Vector3 = step_position(0, 0)
	var label := Label3D.new()
	label.text = "START\nKletterturm"
	label.font_size = 56
	label.outline_size = 10
	label.modulate = Color("#ff5d73")
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(start.x - 1.5, 3.0, start.z + 1.5)
	add_child(label)


func _add_visual_cylinder(radius: float, height: float, pos: Vector3, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	cyl.height = height
	cyl.radial_segments = 8
	mesh.mesh = cyl
	mesh.material_override = Look.surface(color, Look.Kind.WOOD)
	mesh.position = pos
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mesh)
