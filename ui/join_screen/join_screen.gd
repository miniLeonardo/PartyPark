extends Node3D
## Beitrittsbildschirm (D20): A tritt bei, B tritt aus, Y schaltet Computergegner um,
## Start startet, sobald mindestens ein Mensch beigetreten ist. Beigetretene können auf ihrem Podest hüpfen.

const PLAYER_SCENE: PackedScene = preload("res://player/player.tscn")

## Podestpositionen der Plätze 1 bis 4.
@export var pedestal_positions: Array[Vector3] = [
	Vector3(-4.2, 0.0, 0.0),
	Vector3(-1.4, 0.0, 0.0),
	Vector3(1.4, 0.0, 0.0),
	Vector3(4.2, 0.0, 0.0),
]
@export var pedestal_height: float = 0.6

var _figures: Array[Player] = [null, null, null, null]
var _cards: Array[PanelContainer] = []
var _card_titles: Array[Label] = []
var _card_status: Array[Label] = []
var _hint: Label

@onready var camera: Camera3D = $Camera3D


func _ready() -> void:
	Game.match_running = false
	camera.position = Vector3(0.0, 3.4, 9.5)
	camera.look_at(Vector3(0.0, 1.0, 0.0), Vector3.UP)
	StageKit.add_environment(self)
	StageKit.add_box(self, Vector3(40, 1, 20), Vector3(0, -0.5, -4), Color("#7cc66a"))
	for i: int in pedestal_positions.size():
		var color: Color = PlayerRoster.PLAYER_COLORS[i]
		StageKit.add_cylinder(self, 1.0, pedestal_height, pedestal_positions[i] + Vector3.UP * pedestal_height * 0.5, color.darkened(0.35))
	_build_ui()
	PlayerRoster.roster_changed.connect(_refresh)
	_refresh()


func _exit_tree() -> void:
	if PlayerRoster.roster_changed.is_connected(_refresh):
		PlayerRoster.roster_changed.disconnect(_refresh)


func _physics_process(_delta: float) -> void:
	for source: InputSource in InputRouter.poll_join_requests():
		var slot: PlayerSlot = PlayerRoster.join(source)
		if slot != null:
			source.rumble(0.4, 0.2, 0.15)
	var start_requested: bool = false
	for slot: PlayerSlot in PlayerRoster.get_human_slots():
		var source: InputSource = slot.source
		if source.just_pressed(InputBindings.BACK):
			source.rumble(0.2, 0.0, 0.08)
			PlayerRoster.leave(slot)
			continue
		if source.just_pressed(InputBindings.SPECIAL):
			PlayerRoster.cpu_fill_enabled = not PlayerRoster.cpu_fill_enabled
			_refresh()
		if source.just_pressed(InputBindings.PAUSE):
			start_requested = true
	if start_requested and PlayerRoster.human_count() > 0:
		set_physics_process(false)
		Game.start_match()


func _refresh() -> void:
	for slot: PlayerSlot in PlayerRoster.slots:
		var i: int = slot.index
		var show_cpu: bool = slot.is_empty() and PlayerRoster.cpu_fill_enabled
		var wants_figure: bool = slot.is_human() or show_cpu
		var figure: Player = _figures[i]
		if wants_figure and figure == null:
			figure = PLAYER_SCENE.instantiate() as Player
			figure.setup(slot)
			figure.movement_enabled = false
			add_child(figure)
			figure.push_ability.enabled = false
			figure.respawn(pedestal_positions[i] + Vector3.UP * (pedestal_height + 0.6))
			figure.face(Vector3.BACK)
			_figures[i] = figure
		elif not wants_figure and figure != null:
			figure.queue_free()
			_figures[i] = null
			figure = null
		if figure != null:
			figure.set_tag_text("CPU" if show_cpu else slot.get_tag())
			figure.visual.set_ghosted(show_cpu)
		_update_card(slot, show_cpu)
	var cpu_text: String = "an" if PlayerRoster.cpu_fill_enabled else "aus"
	var start_text: String = "Start: Los geht's" if PlayerRoster.human_count() > 0 else "Mindestens ein Spieler muss beitreten"
	_hint.text = "A: Beitreten   B: Austreten   Y: Computer auffüllen (%s)   %s" % [cpu_text, start_text]


func _update_card(slot: PlayerSlot, show_cpu: bool) -> void:
	var i: int = slot.index
	var title: Label = _card_titles[i]
	var status: Label = _card_status[i]
	title.text = slot.display_name
	if slot.is_human():
		status.text = slot.source.get_display_name()
		status.add_theme_color_override("font_color", UiStyle.TEXT_COLOR)
		_cards[i].add_theme_stylebox_override("panel", UiStyle.make_panel_style(slot.color.darkened(0.2), slot.color.lightened(0.4), 6))
	else:
		status.text = "Computer" if show_cpu else "A drücken"
		status.add_theme_color_override("font_color", UiStyle.MUTED_COLOR)
		_cards[i].add_theme_stylebox_override("panel", UiStyle.make_panel_style(UiStyle.PANEL_COLOR, slot.color.darkened(0.2), 4))


func _build_ui() -> void:
	var ui := CanvasLayer.new()
	ui.name = "Ui"
	add_child(ui)
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_theme_constant_override("separation", 0)
	ui.add_child(root)

	var title: Label = UiStyle.make_label("PARTYPARK", 110, Color(1, 0.9, 0.35))
	title.custom_minimum_size = Vector2(0, 200)
	root.add_child(title)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(spacer)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 28)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(row)
	for i: int in PlayerRoster.MAX_PLAYERS:
		var card: PanelContainer = UiStyle.make_panel(UiStyle.PANEL_COLOR)
		card.custom_minimum_size = Vector2(400, 150)
		var box := VBoxContainer.new()
		box.alignment = BoxContainer.ALIGNMENT_CENTER
		card.add_child(box)
		var card_title: Label = UiStyle.make_label("", 40)
		var card_status: Label = UiStyle.make_label("", 28)
		card_status.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		card_status.custom_minimum_size = Vector2(340, 0)
		box.add_child(card_title)
		box.add_child(card_status)
		row.add_child(card)
		_cards.append(card)
		_card_titles.append(card_title)
		_card_status.append(card_status)

	_hint = UiStyle.make_label("", 30)
	_hint.custom_minimum_size = Vector2(0, 110)
	root.add_child(_hint)
