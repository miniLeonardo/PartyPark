extends Node
## Freies Spiel (D40): Minispiel aus Liste wählen, dann Teams bzw. Solo-Spieler selbst festlegen,
## spielen, danach zurück zur Liste. Keine Gesamtpunkte.

enum State { LIST, TEAMS, PLAYING }

var state: State = State.LIST
var participants: Array[PlayerSlot] = []
var flow: MatchFlow
var selected_info: MinigameInfo
var selected_format: int = TeamFormat.Format.FFA
## 2 gegen 2: Platzindex → Team (0 oder 1).
var team_choice: Dictionary = {}
## 1 gegen 3: Platzindex des Solo-Spielers.
var solo_choice: int = -1

var _backdrop: MenuBackdrop
var _ui: CanvasLayer
var _list_box: Control
var _menu: MenuList
var _description: Label
var _teams_box: Control
var _teams_title: Label
var _teams_body: Label
var _teams_hint: Label
var _infos: Array[MinigameInfo] = []


func _ready() -> void:
	Game.match_running = true
	participants = PlayerRoster.get_active_slots()
	_infos = MinigameRegistry.infos
	_build_ui()
	_enter_list()


func _physics_process(_delta: float) -> void:
	var humans: Array[InputSource] = _human_sources()
	match state:
		State.LIST:
			for source: InputSource in humans:
				if source.just_pressed(InputBindings.BACK):
					Sfx.play_ui(&"ui_back")
					set_physics_process(false)
					Game.goto_main_menu()
					return
			_menu.handle_input(humans)
		State.TEAMS:
			_update_teams(humans)


# --- Liste ---

func _enter_list() -> void:
	state = State.LIST
	if _backdrop == null:
		_backdrop = MenuBackdrop.new()
		_backdrop.show_joined_only = true
		add_child(_backdrop)
	_ui.visible = true
	_list_box.visible = true
	_teams_box.visible = false
	var items: Array[Dictionary] = []
	for info: MinigameInfo in _infos:
		var format: int = _first_supported_format(info)
		var item: Dictionary = {"text": "%s  ·  %s" % [info.display_name, TeamFormat.display_name(info.formats[0])]}
		if format < 0:
			item["enabled"] = false
		items.append(item)
	var keep: int = _menu.selected
	_menu.set_items(items)
	_menu.selected = clampi(keep, 0, maxi(0, items.size() - 1))
	_menu.refresh()
	_update_description()


func _first_supported_format(info: MinigameInfo) -> int:
	for format: int in info.formats:
		if info.supports(format, participants.size()):
			return format
	return -1


func _update_description() -> void:
	if _infos.is_empty():
		_description.text = "Keine Minispiele gefunden."
		return
	var info: MinigameInfo = _infos[_menu.selected]
	var text: String = info.goal_text
	if _first_supported_format(info) < 0:
		text += "\n(braucht %d Spieler; Computer auffüllen im Beitritt einschalten)" % maxi(info.min_players, TeamFormat.min_participants(info.formats[0]))
	_description.text = text


func _on_list_activated(index: int) -> void:
	selected_info = _infos[index]
	selected_format = _first_supported_format(selected_info)
	if selected_format < 0:
		return
	if TeamFormat.is_team_format(selected_format):
		_enter_teams()
	else:
		_start_game()


# --- Teams ---

func _enter_teams() -> void:
	state = State.TEAMS
	_list_box.visible = false
	_teams_box.visible = true
	team_choice.clear()
	for i: int in participants.size():
		team_choice[participants[i].index] = i % 2
	solo_choice = participants[0].index
	_rebalance_cpus()
	_refresh_teams()


func _update_teams(_humans: Array[InputSource]) -> void:
	for slot: PlayerSlot in participants:
		if not slot.is_human() or slot.disconnected:
			continue
		var source: InputSource = slot.source
		if source.just_pressed(InputBindings.BACK):
			Sfx.play_ui(&"ui_back")
			_enter_list()
			return
		if source.just_pressed(InputBindings.CONFIRM):
			if _teams_valid():
				_start_game()
				return
		var direction: int = 0
		if source.just_pressed(InputBindings.NAV_LEFT):
			direction = -1
		elif source.just_pressed(InputBindings.NAV_RIGHT):
			direction = 1
		if direction == 0:
			continue
		if selected_format == TeamFormat.Format.TWO_VS_TWO:
			# Jeder Mensch setzt sich selbst links (Team Orange) oder rechts (Team Lila).
			team_choice[slot.index] = 0 if direction < 0 else 1
			_rebalance_cpus()
		else:
			# Jeder Mensch kann den Solo-Spieler weiterschalten.
			var order: Array[int] = []
			for p: PlayerSlot in participants:
				order.append(p.index)
			solo_choice = order[wrapi(order.find(solo_choice) + direction, 0, order.size())]
		_refresh_teams()


## Computer füllen das kleinere Team auf, damit möglichst 2 gegen 2 entsteht.
func _rebalance_cpus() -> void:
	var counts: Array[int] = [0, 0]
	for slot: PlayerSlot in participants:
		if slot.is_human():
			counts[team_choice[slot.index]] += 1
	for slot: PlayerSlot in participants:
		if slot.is_cpu:
			var team: int = 0 if counts[0] <= counts[1] else 1
			team_choice[slot.index] = team
			counts[team] += 1


func _teams_valid() -> bool:
	if selected_format != TeamFormat.Format.TWO_VS_TWO:
		return solo_choice >= 0
	var counts: Array[int] = [0, 0]
	for index: int in team_choice:
		counts[team_choice[index]] += 1
	return counts[0] == 2 and counts[1] == 2


func _refresh_teams() -> void:
	var humans: Array[InputSource] = _human_sources()
	_teams_title.text = selected_info.display_name
	if selected_format == TeamFormat.Format.TWO_VS_TWO:
		var columns: Array[PackedStringArray] = [PackedStringArray(), PackedStringArray()]
		for slot: PlayerSlot in participants:
			columns[team_choice[slot.index]].append(slot.display_name)
		_teams_body.text = "Team Orange: %s\nTeam Lila: %s" % [", ".join(columns[0]), ", ".join(columns[1])]
		var status: String = "" if _teams_valid() else "\nDie Teams müssen 2 gegen 2 sein."
		_teams_hint.text = "Links/rechts: eigenes Team wählen    Start: %s    Zurück: %s%s" % [
			InputHints.for_sources(humans, InputBindings.CONFIRM), InputHints.for_sources(humans, InputBindings.BACK), status]
	else:
		var solo_slot: PlayerSlot = _slot(solo_choice)
		var others: PackedStringArray = []
		for slot: PlayerSlot in participants:
			if slot.index != solo_choice:
				others.append(slot.display_name)
		_teams_body.text = "%s: %s\n%s: %s" % [
			_role(true), solo_slot.display_name, _role(false), ", ".join(others)]
		_teams_hint.text = "Links/rechts: %s wählen    Start: %s    Zurück: %s" % [
			_role(true), InputHints.for_sources(humans, InputBindings.CONFIRM), InputHints.for_sources(humans, InputBindings.BACK)]


func _role(solo: bool) -> String:
	var role: String = selected_info.solo_role_name if solo else selected_info.team_role_name
	if role.is_empty():
		return "Solo" if solo else "Team"
	return role


# --- Spielen ---

func _start_game() -> void:
	var assignment := TeamAssigner.Assignment.new()
	assignment.format = selected_format
	var indices: Array[int] = []
	for slot: PlayerSlot in participants:
		indices.append(slot.index)
	match selected_format:
		TeamFormat.Format.FFA:
			for index: int in indices:
				assignment.teams.append([index])
		TeamFormat.Format.COOP_VS_CPU:
			assignment.teams = [indices]
		TeamFormat.Format.TWO_VS_TWO:
			var a: Array = []
			var b: Array = []
			for index: int in indices:
				if team_choice[index] == 0:
					a.append(index)
				else:
					b.append(index)
			assignment.teams = [a, b]
		TeamFormat.Format.ONE_VS_THREE:
			assignment.solo = solo_choice
			var rest: Array = []
			for index: int in indices:
				if index != solo_choice:
					rest.append(index)
			assignment.teams = [[solo_choice], rest]
	var context: MinigameContext = MinigameContext.from_assignment(assignment, participants, Settings.cpu_difficulty)
	state = State.PLAYING
	_ui.visible = false
	_backdrop.queue_free()
	_backdrop = null
	flow = MatchFlow.new()
	add_child(flow)
	flow.completed.connect(_on_game_completed)
	flow.start(selected_info, context, "Freies Spiel", false)


func _on_game_completed(_result: MinigameResult, _points: Dictionary) -> void:
	flow.queue_free()
	flow = null
	_enter_list()


# --- Hilfen ---

func _slot(index: int) -> PlayerSlot:
	for slot: PlayerSlot in participants:
		if slot.index == index:
			return slot
	return null


func _human_sources() -> Array[InputSource]:
	var result: Array[InputSource] = []
	for slot: PlayerSlot in participants:
		if slot.is_human() and not slot.disconnected:
			result.append(slot.source)
	return result


func _build_ui() -> void:
	_ui = CanvasLayer.new()
	add_child(_ui)
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.add_child(root)
	var title: Label = UiStyle.make_label("Freies Spiel", 90, Color(1, 0.9, 0.35))
	title.custom_minimum_size = Vector2(0, 170)
	root.add_child(title)
	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(center)
	var panel: PanelContainer = UiStyle.make_panel(UiStyle.PANEL_COLOR)
	panel.custom_minimum_size = Vector2(1200, 0)
	center.add_child(panel)
	var stack := VBoxContainer.new()
	panel.add_child(stack)
	# Liste
	var list_box := VBoxContainer.new()
	list_box.add_theme_constant_override("separation", 20)
	stack.add_child(list_box)
	_list_box = list_box
	_menu = MenuList.new()
	_menu.font_size = 42
	list_box.add_child(_menu)
	_menu.activated.connect(_on_list_activated)
	_menu.value_changed.connect(func(_i: int, _d: int) -> void: pass)
	_description = UiStyle.make_label("", 30, UiStyle.MUTED_COLOR)
	_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_description.custom_minimum_size = Vector2(1100, 90)
	list_box.add_child(_description)
	var list_hint: Label = UiStyle.make_label("Spielen: %s    Zum Hauptmenü: %s" % [
		InputHints.for_humans(InputBindings.CONFIRM), InputHints.for_humans(InputBindings.BACK)], 26, UiStyle.MUTED_COLOR)
	list_box.add_child(list_hint)
	# Teams
	var teams_box := VBoxContainer.new()
	teams_box.add_theme_constant_override("separation", 24)
	stack.add_child(teams_box)
	_teams_box = teams_box
	_teams_title = UiStyle.make_label("", 60, Color(1, 0.9, 0.35))
	teams_box.add_child(_teams_title)
	_teams_body = UiStyle.make_label("", 42)
	teams_box.add_child(_teams_body)
	_teams_hint = UiStyle.make_label("", 26, UiStyle.MUTED_COLOR)
	teams_box.add_child(_teams_hint)


func _process(_delta: float) -> void:
	if state == State.LIST and _description != null and not _infos.is_empty():
		_update_description()
