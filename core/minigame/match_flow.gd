class_name MatchFlow
extends Node
## Steuert genau einen Minispiel-Durchlauf (D33): Ankündigung → Regeln mit Bereit-Anzeige → Countdown
## → Spiel → kurze Zeitlupe → Ergebnis. Jede Spielart (Turnier, Freies Spiel) nutzt denselben Ablauf.

signal completed(result: MinigameResult, points: Dictionary)

enum Phase { IDLE, ANNOUNCE, RULES, COUNTDOWN, PLAY, SLOWMO, RESULT, DONE }

## Dauer der Ankündigung (Sekunden, A überspringt).
@export var announce_time: float = 2.5
## Dauer je Countdown-Schritt (3, 2, 1, Los).
@export var countdown_step: float = 0.75
## Zeitlupe am Ende: Dauer in echten Sekunden und Tempo.
@export var slowmo_time: float = 1.4
@export var slowmo_scale: float = 0.3
## Ergebnis schließt sich spätestens nach dieser Zeit.
@export var result_auto_time: float = 12.0

var phase: Phase = Phase.IDLE
var info: MinigameInfo
var context: MinigameContext
var minigame: Minigame
var result: MinigameResult
var points: Dictionary = {}
var award_points: bool = false
var round_label: String = ""

var _timer: float = 0.0
var _last_countdown_step: int = -1
var _ready_state: Dictionary = {}
var _started_round: bool = false
var _ui: CanvasLayer
var _dim: ColorRect
var _announce: Control
var _rules: Control
var _ready_labels: Dictionary = {}
var _countdown: Label
var _banner: Label
var _result_panel: Control


## Lädt das Minispiel, baut es auf und beginnt mit der Ankündigung.
func start(p_info: MinigameInfo, p_context: MinigameContext, p_round_label: String = "", p_award_points: bool = false) -> void:
	info = p_info
	context = p_context
	round_label = p_round_label
	award_points = p_award_points
	var scene := load(info.scene_path) as PackedScene
	minigame = scene.instantiate() as Minigame
	add_child(minigame)
	minigame.setup(context, info)
	minigame.finished.connect(_on_minigame_finished)
	_build_ui()
	_enter(Phase.ANNOUNCE)
	Announcer.say(&"round_start", {"game": info.display_name})


func _exit_tree() -> void:
	Engine.time_scale = 1.0


func _physics_process(delta: float) -> void:
	var real_delta: float = delta / maxf(Engine.time_scale, 0.01)
	_timer += real_delta
	match phase:
		Phase.ANNOUNCE:
			if _timer >= announce_time or (_timer > 0.4 and _any_human_pressed(InputBindings.CONFIRM)):
				_enter(Phase.RULES)
		Phase.RULES:
			_update_ready()
		Phase.COUNTDOWN:
			_update_countdown()
		Phase.SLOWMO:
			if _timer >= slowmo_time:
				Engine.time_scale = 1.0
				_enter(Phase.RESULT)
		Phase.RESULT:
			if _timer >= result_auto_time or (_timer > 0.8 and _any_human_pressed(InputBindings.CONFIRM)):
				_enter(Phase.DONE)
				completed.emit(result, points)


func _enter(new_phase: Phase) -> void:
	phase = new_phase
	_timer = 0.0
	_announce.visible = phase == Phase.ANNOUNCE
	_rules.visible = phase == Phase.RULES
	_dim.visible = phase in [Phase.ANNOUNCE, Phase.RULES, Phase.RESULT]
	_countdown.visible = phase == Phase.COUNTDOWN
	_banner.visible = phase == Phase.SLOWMO
	_result_panel.visible = phase == Phase.RESULT
	match phase:
		Phase.RULES:
			_ready_state.clear()
			for slot: PlayerSlot in context.slots:
				_ready_state[slot.index] = slot.is_cpu
			_refresh_ready()
			if _all_ready():
				_enter(Phase.COUNTDOWN)
		Phase.COUNTDOWN:
			_started_round = false
			_last_countdown_step = -1
			_countdown.text = "3"
		Phase.RESULT:
			_build_result()


func _update_ready() -> void:
	for slot: PlayerSlot in context.slots:
		if slot.is_human() and not slot.disconnected and not _ready_state.get(slot.index, false):
			if slot.source.just_pressed(InputBindings.CONFIRM):
				_ready_state[slot.index] = true
				Sfx.play_ui(&"ui_confirm", 0.0, 0.9 + 0.08 * float(slot.index))
				slot.source.rumble(0.3, 0.0, 0.1)
				_refresh_ready()
	if _all_ready():
		_enter(Phase.COUNTDOWN)


func _all_ready() -> bool:
	for slot: PlayerSlot in context.slots:
		if not _ready_state.get(slot.index, false):
			return false
	return true


func _update_countdown() -> void:
	var step: int = int(_timer / countdown_step)
	if step != _last_countdown_step and step <= 3:
		_last_countdown_step = step
		Sfx.play_ui(&"countdown_go" if step == 3 else &"countdown_tick")
		if step == 3:
			Announcer.say(&"countdown", {}, 0.35)
	if step < 3:
		_countdown.text = str(3 - step)
	else:
		_countdown.text = "Los!"
		if not _started_round:
			_started_round = true
			minigame.start_round()
			_enter_play_soon()
	if step >= 4:
		_countdown.visible = false


func _enter_play_soon() -> void:
	# Countdown-Text „Los!“ bleibt noch einen Schritt sichtbar, die Phase ist aber schon PLAY.
	phase = Phase.PLAY
	_countdown.visible = true
	var tween: Tween = create_tween()
	tween.tween_interval(countdown_step)
	tween.tween_callback(func() -> void: _countdown.visible = false)


func _on_minigame_finished(p_result: MinigameResult) -> void:
	result = p_result
	if award_points:
		points = Scoring.points_for(result, context.format)
	if result.headline.is_empty():
		result.headline = _default_headline()
	_banner.text = result.headline
	_celebrate()
	var lost: bool = context.format == TeamFormat.Format.COOP_VS_CPU and not result.coop_won
	Sfx.play_ui(&"lose" if lost else &"win")
	_comment_result(lost)
	Engine.time_scale = slowmo_scale
	_enter(Phase.SLOWMO)


## Ansager zum Ergebnis: knappe Entscheidung, Sieg, Unentschieden oder Koop-Niederlage.
func _comment_result(lost: bool) -> void:
	if result.is_draw:
		Announcer.say(&"draw")
	elif lost:
		Announcer.say(&"coop_lost")
	elif minigame.has_method("was_close") and bool(minigame.call("was_close")):
		Announcer.say(&"close_call")
	else:
		var winners: Array[int] = result.get_winners()
		if winners.is_empty():
			return
		if context.format == TeamFormat.Format.FFA:
			if winners.size() > 1:
				Announcer.say(&"close_call")
				return
			Announcer.say(&"win", {"winner": context.get_slot(winners[0]).display_name})
		else:
			Announcer.say(&"win", {"winner": context.team_name(context.team_of(winners[0]), info)})


## Konfetti über den Siegern (bei Koop nur bei Erfolg, bei Unentschieden nicht).
func _celebrate() -> void:
	if result.is_draw or (context.format == TeamFormat.Format.COOP_VS_CPU and not result.coop_won):
		return
	for index: int in result.get_winners():
		var player: Player = minigame.get_player(index)
		if player != null and player.visible:
			Fx.burst(&"confetti", player.global_position + Vector3.UP * 1.2 * player.body_scale)


func _default_headline() -> String:
	if result.is_draw:
		return "Unentschieden!"
	match context.format:
		TeamFormat.Format.COOP_VS_CPU:
			return "Geschafft!" if result.coop_won else "Leider verloren!"
		TeamFormat.Format.FFA:
			var winners: Array[int] = result.get_winners()
			if winners.size() == 1:
				return "%s gewinnt!" % context.get_slot(winners[0]).display_name
			return "Gleichstand!"
	var winners: Array[int] = result.get_winners()
	if winners.is_empty():
		return "Unentschieden!"
	var team_name: String = context.team_name(context.team_of(winners[0]), info)
	if context.format == TeamFormat.Format.ONE_VS_THREE and winners.size() > 1:
		return "Die %s gewinnen!" % team_name
	return "%s gewinnt!" % team_name


func _any_human_pressed(action: StringName) -> bool:
	for slot: PlayerSlot in context.slots:
		if slot.is_human() and not slot.disconnected and slot.source.just_pressed(action):
			return true
	return false


# --- Oberfläche ---

func _build_ui() -> void:
	_ui = CanvasLayer.new()
	_ui.layer = 20
	add_child(_ui)
	_dim = ColorRect.new()
	_dim.color = Color(0, 0, 0, 0.5)
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.add_child(_dim)
	_announce = _build_announce()
	_rules = _build_rules()
	var center: CenterContainer = UiStyle.make_center_root()
	_ui.add_child(center)
	_countdown = UiStyle.make_label("", 220, Color(1, 0.9, 0.3))
	center.add_child(_countdown)
	var banner_center: CenterContainer = UiStyle.make_center_root()
	_ui.add_child(banner_center)
	_banner = UiStyle.make_label("", 110, Color(1, 0.92, 0.4))
	banner_center.add_child(_banner)
	_result_panel = UiStyle.make_center_root()
	_ui.add_child(_result_panel)


func _build_announce() -> Control:
	var center: CenterContainer = UiStyle.make_center_root()
	_ui.add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	center.add_child(box)
	if not round_label.is_empty():
		box.add_child(UiStyle.make_label(round_label, 40, UiStyle.MUTED_COLOR))
	box.add_child(UiStyle.make_label(info.display_name, 120, Color(1, 0.9, 0.35)))
	box.add_child(UiStyle.make_label(TeamFormat.display_name(context.format), 48))
	for t: int in context.teams.size():
		var names: PackedStringArray = []
		for index: int in context.team_members(t):
			names.append(context.get_slot(index).display_name)
		var text: String = ", ".join(names)
		if TeamFormat.is_team_format(context.format):
			text = "%s: %s" % [context.team_name(t, info), text]
		var color: Color = context.team_color(t)
		box.add_child(UiStyle.make_label(text, 40, color.lightened(0.2)))
	return center


func _build_rules() -> Control:
	var center: CenterContainer = UiStyle.make_center_root()
	_ui.add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 22)
	center.add_child(box)
	box.add_child(UiStyle.make_label(info.display_name, 72, Color(1, 0.9, 0.35)))
	var goal: Label = UiStyle.make_label(info.goal_text, 38)
	goal.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	goal.custom_minimum_size = Vector2(1500, 0)
	box.add_child(goal)
	if context.format == TeamFormat.Format.ONE_VS_THREE and not info.solo_goal_text.is_empty():
		var solo_goal: Label = UiStyle.make_label("%s: %s" % [info.solo_role_name, info.solo_goal_text], 32, TeamFormat.TEAM_COLORS[0].lightened(0.3))
		solo_goal.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		solo_goal.custom_minimum_size = Vector2(1500, 0)
		box.add_child(solo_goal)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 20)
	box.add_child(row)
	for slot: PlayerSlot in context.slots:
		var team: int = context.team_of(slot.index)
		var border: Color = context.team_color(team) if TeamFormat.is_team_format(context.format) else slot.color
		var card: PanelContainer = UiStyle.make_panel(UiStyle.PANEL_COLOR, border, 5)
		card.custom_minimum_size = Vector2(400, 260)
		var inner := VBoxContainer.new()
		inner.add_theme_constant_override("separation", 6)
		card.add_child(inner)
		inner.add_child(UiStyle.make_label(slot.display_name, 36, slot.color.lightened(0.25)))
		if TeamFormat.is_team_format(context.format):
			inner.add_child(UiStyle.make_label(context.team_name(team, info), 26, border.lightened(0.2)))
		var controls: Label = UiStyle.make_label(_controls_text(slot), 24)
		controls.size_flags_vertical = Control.SIZE_EXPAND_FILL
		inner.add_child(controls)
		var ready_label: Label = UiStyle.make_label("", 30)
		inner.add_child(ready_label)
		_ready_labels[slot.index] = ready_label
		row.add_child(card)
	return center


func _controls_text(slot: PlayerSlot) -> String:
	if slot.is_cpu:
		return "Computer"
	var controls: Dictionary = info.controls
	if context.is_solo(slot.index) and not info.solo_controls.is_empty():
		controls = info.solo_controls
	var lines: PackedStringArray = []
	for action: String in controls:
		var label: String
		match action:
			"move":
				label = slot.source.get_move_label()
			"aim":
				label = slot.source.get_aim_label()
			_:
				label = slot.source.get_action_label(StringName(action))
		lines.append("%s: %s" % [label, controls[action]])
	return "\n".join(lines)


func _refresh_ready() -> void:
	for slot: PlayerSlot in context.slots:
		var label: Label = _ready_labels.get(slot.index)
		if label == null:
			continue
		if _ready_state.get(slot.index, false):
			label.text = "Bereit!"
			label.add_theme_color_override("font_color", Color(0.5, 1, 0.55))
		else:
			label.text = "%s: Bereit" % slot.source.get_action_label(InputBindings.CONFIRM)
			label.add_theme_color_override("font_color", Color(1, 0.85, 0.3))


func _build_result() -> void:
	for child: Node in _result_panel.get_children():
		child.queue_free()
	var panel: PanelContainer = UiStyle.make_panel(UiStyle.PANEL_COLOR)
	panel.custom_minimum_size = Vector2(900, 0)
	_result_panel.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	box.add_child(UiStyle.make_label(result.headline, 64, Color(1, 0.9, 0.35)))
	var order: Array = context.indices()
	order.sort_custom(func(a: int, b: int) -> bool: return result.get_place(a) < result.get_place(b) or (result.get_place(a) == result.get_place(b) and a < b))
	for index: int in order:
		var slot: PlayerSlot = context.get_slot(index)
		var text: String = "%d.  %s" % [result.get_place(index), slot.display_name]
		if award_points:
			text += "   +%d" % points.get(index, 0)
		box.add_child(UiStyle.make_label(text, 40, slot.color.lightened(0.25)))
	box.add_child(UiStyle.make_label("Weiter: " + InputHints.for_sources(_human_sources(), InputBindings.CONFIRM), 26, UiStyle.MUTED_COLOR))


func _human_sources() -> Array[InputSource]:
	var sources: Array[InputSource] = []
	for slot: PlayerSlot in context.slots:
		if slot.is_human() and not slot.disconnected:
			sources.append(slot.source)
	return sources
