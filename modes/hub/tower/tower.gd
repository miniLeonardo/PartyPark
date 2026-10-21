class_name HubTower
extends Node3D
## Der fordernde Kletterturm & Parkour im Park (D100, D107, D108).
## 20 Meter hoher, vertikaler Platforming-Turm mit 3 fordernden Passagen,
## Auffangnetzen alle 6 Meter, schwebender Siegerkrone und Konfetti-Buzzer.

var crown: HubCrown
var buzzer: HubConfettiBuzzer
var _spinners: Array[Node3D] = []


func _ready() -> void:
	_build_main_structure()
	_build_passage_1()
	_build_passage_2()
	_build_passage_3()
	_build_summit()


func _physics_process(delta: float) -> void:
	# Rotierende Balken in Passage 2 antreiben
	for spinner: Node3D in _spinners:
		spinner.rotate_y(1.2 * delta)


func _build_main_structure() -> void:
	var steel_mat: Material = Look.surface(Color("#5d6d7e"), Look.Kind.METAL)
	var half_w: float = 4.5
	var height: float = 20.5

	# 4 massive Eckpfeiler des Gitterturms
	for x: float in [-half_w, half_w]:
		for z: float in [-half_w, half_w]:
			var pillar := StageKit.add_cylinder(self, 0.28, height, Vector3(x, height * 0.5, z), Color("#4a5568"), Look.Kind.METAL)
			pillar.name = "TowerPillar"


# --- Passage 1: 0 bis 6 Meter (Balken & Trampolin-Sprung) ---

func _build_passage_1() -> void:
	var wood_col := Color("#c29057")

	# Start-Stufe
	StageKit.add_box(self, Vector3(3.0, 0.4, 1.8), Vector3(0, 0.2, 5.0), wood_col, Vector3.ZERO, Look.Kind.WOOD)

	# Spiraliger Anstieg aus 5 Balken
	var beam_coords: Array[Vector3] = [
		Vector3(-2.0, 1.0, 4.0),
		Vector3(-3.5, 2.0, 2.0),
		Vector3(-3.5, 3.0, -1.0),
		Vector3(-2.0, 4.0, -3.5),
		Vector3(1.0, 4.8, -3.5),
	]
	for i: int in beam_coords.size():
		var b := StageKit.add_box(self, Vector3(1.5, 0.25, 1.5), beam_coords[i], wood_col, Vector3.ZERO, Look.Kind.WOOD)
		b.name = "P1_Beam_%d" % i

	# Passage-1-Trampolin zum Erreichen von Plattform 1
	var tramp := HubTrampoline.new()
	tramp.name = "P1_Trampoline"
	tramp.position = Vector3(3.0, 4.8, -1.5)
	tramp.radius = 1.6
	tramp.base_bounce_speed = 12.0
	add_child(tramp)

	# Plattform 1 (Y = 6.2 m)
	StageKit.add_box(self, Vector3(9.5, 0.35, 9.5), Vector3(0, 6.2, 0), Color("#d4b886"), Vector3.ZERO, Look.Kind.WOOD)
	_build_safety_net(Vector3(0, 6.0, 0), 12.5)


# --- Passage 2: 6 bis 12 Meter (Rotierende Drehkreuze & Schwebeladung) ---

func _build_passage_2() -> void:
	var steel_col := Color("#7f8c8d")
	var red_mat: Material = Look.surface(Color("#e74c3c"), Look.Kind.PLASTIC)

	# 2 rotierende Drehkreuze (Spinners)
	for i: int in 2:
		var spin_y: float = 7.5 + float(i) * 2.2
		var spin_root := Node3D.new()
		spin_root.name = "Spinner_%d" % i
		spin_root.position = Vector3(0, spin_y, 0)
		add_child(spin_root)
		_spinners.append(spin_root)

		# Zwei kreuzförmige Holzbalken
		for rot: float in [0.0, 90.0]:
			var arm := StageKit.add_box(spin_root, Vector3(7.2, 0.24, 0.9), Vector3(0, 0, 0), Color("#ff7675"), Vector3(0, rot, 0), Look.Kind.PLASTIC)
			arm.name = "SpinnerArm"

	# Schwebende Trittstufen
	StageKit.add_box(self, Vector3(1.6, 0.25, 1.6), Vector3(-3.2, 9.5, 3.2), steel_col, Vector3.ZERO, Look.Kind.METAL)
	StageKit.add_box(self, Vector3(1.6, 0.25, 1.6), Vector3(3.2, 11.0, 3.2), steel_col, Vector3.ZERO, Look.Kind.METAL)

	# Plattform 2 (Y = 12.4 m)
	StageKit.add_box(self, Vector3(8.5, 0.35, 8.5), Vector3(0, 12.4, 0), Color("#bdc3c7"), Vector3.ZERO, Look.Kind.STONE)
	_build_safety_net(Vector3(0, 12.2, 0), 11.5)


# --- Passage 3: 12 bis 18 Meter (Schmale Rohr-Balancierstege & Präzisionssprünge) ---

func _build_passage_3() -> void:
	var yellow_col := Color("#f1c40f")

	# Runde Balancier-Pfähle im Zickzack
	var poles: Array[Vector3] = [
		Vector3(-2.5, 13.5, -2.5),
		Vector3(-1.0, 14.5, -3.2),
		Vector3(1.5, 15.5, -2.8),
		Vector3(2.8, 16.5, -0.5),
		Vector3(1.8, 17.5, 2.2),
		Vector3(-1.2, 18.2, 2.2),
	]
	for i: int in poles.size():
		var p := StageKit.add_cylinder(self, 0.5, 0.3, poles[i], yellow_col, Look.Kind.METAL)
		p.name = "P3_Pole_%d" % i

	# Schlusssprung-Pad
	var launch_pad := HubTrampoline.new()
	launch_pad.name = "P3_LaunchPad"
	launch_pad.position = Vector3(-2.8, 18.2, 0.5)
	launch_pad.radius = 1.3
	launch_pad.base_bounce_speed = 10.0
	add_child(launch_pad)


# --- Passage 4: Die Turmspitze (19 bis 22 Meter) ---

func _build_summit() -> void:
	var gold_col := Color("#ffd75e")
	var marble_col := Color("#f0ede6")

	# Haupt-Aussichtsplattform (Y = 19.5 m)
	var summit_deck := StageKit.add_cylinder(self, 5.2, 0.4, Vector3(0, 19.5, 0), marble_col, Look.Kind.STONE)
	summit_deck.name = "SummitDeck"

	# Schutzgeländer um die Plattform
	var railing := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 5.0
	torus.outer_radius = 5.3
	torus.rings = 36
	torus.ring_segments = 6
	railing.mesh = torus
	railing.material_override = Look.surface(gold_col, Look.Kind.METAL)
	railing.position = Vector3(0, 20.4, 0)
	railing.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(railing)

	# Baldachin-Dach über der Spitze
	var roof := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.1
	cone.bottom_radius = 5.6
	cone.height = 2.4
	roof.mesh = cone
	roof.material_override = Look.surface(Color("#8e44ad"), Look.Kind.FABRIC)
	roof.position = Vector3(0, 23.5, 0)
	add_child(roof)

	# Goldene Spitze
	var finial := MeshInstance3D.new()
	var f_cone := CylinderMesh.new()
	f_cone.top_radius = 0.05
	f_cone.bottom_radius = 0.4
	f_cone.height = 1.6
	finial.mesh = f_cone
	finial.material_override = Look.surface(gold_col, Look.Kind.METAL)
	finial.position = Vector3(0, 25.2, 0)
	add_child(finial)

	# 1. Goldener Altar & Siegerkrone (D100, D108)
	var altar := StageKit.add_cylinder(self, 0.9, 0.8, Vector3(0, 20.0, 0), Color("#d4ac0d"), Look.Kind.METAL)
	altar.name = "CrownAltar"

	crown = HubCrown.new()
	crown.name = "SummitCrown"
	crown.summit_home_position = global_position + Vector3(0, 21.0, 0)
	add_child(crown)

	# 2. Konfetti-Buzzer am vorderen Aussichtspunkt (Süd-Balkon)
	buzzer = HubConfettiBuzzer.new()
	buzzer.name = "SummitBuzzer"
	buzzer.position = Vector3(0, 19.7, 3.2)
	add_child(buzzer)


## Auffang- und Sicherheitsnetz (D107: Rückfall-Sicherung)
func _build_safety_net(pos: Vector3, size: float) -> void:
	var net_mat: Material = Look.surface(Color("#2c3e50"), Look.Kind.RUBBER)

	var net_mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(size, 0.1, size)
	net_mesh.mesh = box
	net_mesh.material_override = net_mat
	net_mesh.position = pos + Vector3(0, -0.2, 0)
	net_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(net_mesh)
