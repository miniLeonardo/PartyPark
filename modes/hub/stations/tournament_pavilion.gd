class_name HubTournamentPavilion
extends Node3D
## Prachtvoller Turnier-Pavillon am Kopf des Süd-Boulevards (D110).
## Erlaubt das direkte Starten eines 5- oder 10-Runden-Schnellturniers im Park.

signal tournament_requested(rounds: int)

@export var rounds: int = 5

var activation_pad: HubActivationPad
var _rounds_label: Label3D
var _switcher_cooldown: float = 0.0


func _ready() -> void:
	_build_pavilion()


func _physics_process(delta: float) -> void:
	if _switcher_cooldown > 0.0:
		_switcher_cooldown -= delta


func _build_pavilion() -> void:
	var marble_mat: Material = Look.surface(Color("#f0ede6"), Look.Kind.GLOSSY)
	var gold_mat: Material = Look.surface(Color("#ffd75e"), Look.Kind.METAL)
	var dome_mat: Material = Look.surface(Color("#e67e22"), Look.Kind.FABRIC)

	# 1. Großes achteckiges Podest
	var base := StageKit.add_cylinder(self, 6.2, 0.4, Vector3(0, 0.2, 0), Color("#ebd8b0"), Look.Kind.STONE)
	base.name = "PavilionBase"

	# 2. 8 Marmorsäulen im Kreis
	var col_count: int = 8
	var col_radius: float = 5.2
	for i: int in col_count:
		var angle: float = TAU * float(i) / float(col_count)
		var pos := Vector3(cos(angle) * col_radius, 2.2, sin(angle) * col_radius)

		var pillar := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.25
		cyl.bottom_radius = 0.3
		cyl.height = 4.0
		pillar.mesh = cyl
		pillar.material_override = marble_mat
		pillar.position = pos
		pillar.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(pillar)

	# 3. Kuppel-Dach
	var dome := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 5.8
	sphere.height = 3.6
	dome.mesh = sphere
	dome.material_override = dome_mat
	dome.position = Vector3(0, 5.4, 0)
	add_child(dome)

	# Goldene Turnierspitze / Krone auf der Kuppel
	var finial := MeshInstance3D.new()
	var f_cone := CylinderMesh.new()
	f_cone.top_radius = 0.05
	f_cone.bottom_radius = 0.5
	f_cone.height = 1.8
	finial.mesh = f_cone
	finial.material_override = gold_mat
	finial.position = Vector3(0, 7.8, 0)
	add_child(finial)

	# 4. Banner-Schild
	var sign_mesh := MeshInstance3D.new()
	var s_box := BoxMesh.new()
	s_box.size = Vector3(4.8, 1.2, 0.2)
	sign_mesh.mesh = s_box
	sign_mesh.material_override = Look.surface(Color("#2c3e50"), Look.Kind.WOOD)
	sign_mesh.position = Vector3(0, 4.4, -col_radius + 0.4)
	add_child(sign_mesh)

	var title_lbl := Label3D.new()
	title_lbl.text = "SCHNELLTURNIER"
	title_lbl.font_size = 42
	title_lbl.outline_size = 8
	title_lbl.modulate = Color("#ffd75e")
	title_lbl.position = Vector3(0, 4.6, -col_radius + 0.52)
	add_child(title_lbl)

	_rounds_label = Label3D.new()
	_rounds_label.text = "%d Runden" % rounds
	_rounds_label.font_size = 32
	_rounds_label.outline_size = 6
	_rounds_label.modulate = Color.WHITE
	_rounds_label.position = Vector3(0, 4.1, -col_radius + 0.52)
	add_child(_rounds_label)

	# 5. Rundenzahl-Umschaltplatte (links neben dem Eingang)
	_build_round_switcher(Vector3(-3.4, 0.25, -2.5))

	# 6. Zentrales Aktivierungs-Pad
	activation_pad = HubActivationPad.new()
	activation_pad.name = "TournamentPad"
	activation_pad.position = Vector3(0, 0.22, 0)
	activation_pad.pad_radius = 2.6
	activation_pad.activated.connect(_on_pad_activated)
	add_child(activation_pad)


func _build_round_switcher(pos: Vector3) -> void:
	var switch_base := StageKit.add_cylinder(self, 1.1, 0.15, pos, Color("#9b59b6"), Look.Kind.PLASTIC)
	switch_base.name = "RoundSwitcher"

	var lbl := Label3D.new()
	lbl.text = "5 / 10\nRunden"
	lbl.font_size = 24
	lbl.outline_size = 6
	lbl.modulate = Color.WHITE
	lbl.position = pos + Vector3(0, 1.2, 0)
	lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(lbl)

	var area := Area3D.new()
	area.collision_mask = 1
	var col := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = 1.0
	cyl.height = 0.8
	col.shape = cyl
	col.position = pos + Vector3(0, 0.4, 0)
	area.add_child(col)
	add_child(area)

	area.body_entered.connect(_on_switcher_entered)


func _on_switcher_entered(body: Node3D) -> void:
	var player := body as Player
	if player == null or _switcher_cooldown > 0.0:
		return

	_switcher_cooldown = 0.8
	rounds = 10 if rounds == 5 else 5
	_rounds_label.text = "%d Runden" % rounds

	Sfx.play(&"ui_confirm", global_position, 0.0, 1.2)
	Fx.burst(&"stars", global_position + Vector3(0, 1.0, 0), Color("#ffd75e"), 0.6)

	var source: InputSource = player.get_input()
	if source != null:
		source.rumble(0.2, 0.4, 0.15)


func _on_pad_activated() -> void:
	tournament_requested.emit(rounds)
