class_name TournamentCeremony
extends Node3D
## Siegerehrung: Podest mit den Figuren nach Gesamtpunkten, Konfetti, Rangliste.

const PLAYER_SCENE: PackedScene = preload("res://player/player.tscn")
## Podesthöhen für Platz 1, 2, 3 (Platz 4 steht daneben auf dem Boden).
const PODIUM_HEIGHTS: Array[float] = [1.8, 1.2, 0.7]
const PODIUM_X: Array[float] = [0.0, -2.4, 2.4]

var _participants: Array[PlayerSlot] = []
var _totals: Dictionary = {}
var _winners: Array[Player] = []
var _hop_timer: float = 0.0


func setup(participants: Array[PlayerSlot], totals: Dictionary) -> void:
	_participants = participants
	_totals = totals


func _ready() -> void:
	StageKit.add_environment(self)
	StageKit.add_box(self, Vector3(40, 1, 30), Vector3(0, -0.5, -6), Color("#7cc66a"))
	var camera := Camera3D.new()
	camera.fov = 45.0
	add_child(camera)
	camera.position = Vector3(0, 3.6, 10.5)
	camera.look_at(Vector3(0, 1.8, 0), Vector3.UP)
	camera.current = true
	var podium_colors: Array[Color] = [Color("#f2c230"), Color("#c9ced6"), Color("#cd7f32")]
	for i: int in 3:
		StageKit.add_box(self, Vector3(2.2, PODIUM_HEIGHTS[i], 2.2), Vector3(PODIUM_X[i], PODIUM_HEIGHTS[i] * 0.5, 0), podium_colors[i])
	var groups: Array = Scoring.standings(_totals)
	var place: int = 1
	var winner_names: PackedStringArray = []
	var used_on_step: Dictionary = {}
	var fourth_x: float = 5.0
	for group: Array in groups:
		for index: int in group:
			var slot: PlayerSlot = _slot(index)
			var figure := PLAYER_SCENE.instantiate() as Player
			figure.setup(slot)
			add_child(figure)
			figure.controls_enabled = false
			var spot := Vector3(fourth_x, 0.3, 0.5)
			if place <= 3:
				var step: int = place - 1
				var offset: float = 0.6 * float(used_on_step.get(step, 0))
				used_on_step[step] = int(used_on_step.get(step, 0)) + 1
				spot = Vector3(PODIUM_X[step] + offset - 0.3 * float(group.size() - 1), PODIUM_HEIGHTS[step] + 0.3, 0)
			else:
				fourth_x += 1.2
			figure.respawn(spot)
			figure.face(Vector3.BACK)
			if place == 1:
				_winners.append(figure)
				winner_names.append(slot.display_name)
		place += group.size()
	_add_confetti()
	_build_ui(groups, winner_names)


func _physics_process(delta: float) -> void:
	_hop_timer -= delta
	if _hop_timer > 0.0:
		return
	_hop_timer = 0.7
	for figure: Player in _winners:
		if figure.is_on_floor():
			figure.velocity.y = 7.0
			figure.visual.play_jump()


func _slot(index: int) -> PlayerSlot:
	for slot: PlayerSlot in _participants:
		if slot.index == index:
			return slot
	return null


func _add_confetti() -> void:
	var particles := CPUParticles3D.new()
	particles.amount = 160
	particles.lifetime = 4.0
	particles.position = Vector3(0, 7, 0)
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	particles.emission_box_extents = Vector3(7, 0.5, 2)
	particles.direction = Vector3.DOWN
	particles.spread = 25.0
	particles.initial_velocity_min = 0.5
	particles.initial_velocity_max = 2.0
	particles.gravity = Vector3(0, -2.0, 0)
	particles.angular_velocity_min = -360.0
	particles.angular_velocity_max = 360.0
	var quad := QuadMesh.new()
	quad.size = Vector2(0.14, 0.09)
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	quad.material = material
	particles.mesh = quad
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.33, 0.66, 1.0])
	gradient.colors = PackedColorArray([PlayerRoster.PLAYER_COLORS[0], PlayerRoster.PLAYER_COLORS[1], PlayerRoster.PLAYER_COLORS[2], PlayerRoster.PLAYER_COLORS[3]])
	particles.color_initial_ramp = gradient
	add_child(particles)


func _build_ui(groups: Array, winner_names: PackedStringArray) -> void:
	var ui := CanvasLayer.new()
	add_child(ui)
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(root)
	var title_text: String = "%s gewinnt!" % winner_names[0] if winner_names.size() == 1 else "Gleichstand: %s" % " und ".join(winner_names)
	var title: Label = UiStyle.make_label(title_text, 90, Color(1, 0.9, 0.35))
	title.custom_minimum_size = Vector2(0, 170)
	root.add_child(title)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(spacer)
	var place: int = 1
	var lines: PackedStringArray = []
	for group: Array in groups:
		for index: int in group:
			lines.append("%d. %s  %d" % [place, _slot(index).display_name, _totals[index]])
		place += group.size()
	root.add_child(UiStyle.make_label("    ".join(lines), 34))
	var hint: Label = UiStyle.make_label("Zum Hauptmenü: " + InputHints.for_humans(InputBindings.CONFIRM), 26, UiStyle.MUTED_COLOR)
	hint.custom_minimum_size = Vector2(0, 80)
	root.add_child(hint)
