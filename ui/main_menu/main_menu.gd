extends Node
## Hauptmenü (D29): Schnellturnier (Rundenzahl mit links/rechts), Freies Spiel, Testarena, Optionen, Beenden.
## Jeder beigetretene Spieler kann navigieren; B führt zurück zum Beitritt.

enum Item { TOURNAMENT, FREE_PLAY, TEST_ARENA, OPTIONS, QUIT }

var menu: MenuList
var _hint: Label
var _rounds: int = 5


func _ready() -> void:
	Game.match_running = false
	if PlayerRoster.human_count() == 0:
		Game.goto_join.call_deferred()
		return
	_rounds = Game.tournament_rounds
	var backdrop := MenuBackdrop.new()
	backdrop.show_joined_only = true
	add_child(backdrop)
	var ui := CanvasLayer.new()
	add_child(ui)
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(root)
	var title: Label = UiStyle.make_label("PARTYPARK", 96, Color(1, 0.9, 0.35))
	title.custom_minimum_size = Vector2(0, 170)
	root.add_child(title)
	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(center)
	var panel: PanelContainer = UiStyle.make_panel(UiStyle.PANEL_COLOR)
	panel.custom_minimum_size = Vector2(820, 0)
	center.add_child(panel)
	menu = MenuList.new()
	panel.add_child(menu)
	menu.activated.connect(_on_activated)
	menu.value_changed.connect(_on_value_changed)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(spacer)
	_hint = UiStyle.make_label("", 28)
	_hint.custom_minimum_size = Vector2(0, 110)
	root.add_child(_hint)
	_build_items()
	PlayerRoster.roster_changed.connect(_on_roster_changed)


func _exit_tree() -> void:
	if PlayerRoster.roster_changed.is_connected(_on_roster_changed):
		PlayerRoster.roster_changed.disconnect(_on_roster_changed)


func _build_items() -> void:
	var items: Array[Dictionary] = [
		{"text": "Schnellturnier", "value": "%d Runden" % _rounds},
		{"text": "Freies Spiel"},
		{"text": "Testarena"},
		{"text": "Optionen"},
		{"text": "Beenden"},
	]
	menu.set_items(items)
	_update_hint()


func _update_hint() -> void:
	var humans: Array[InputSource] = InputHints.human_sources()
	var names: PackedStringArray = []
	for slot: PlayerSlot in PlayerRoster.get_human_slots():
		names.append(slot.display_name)
	var cpu_count: int = PlayerRoster.MAX_PLAYERS - names.size() if PlayerRoster.cpu_fill_enabled else 0
	var players_text: String = ", ".join(names)
	if cpu_count > 0:
		players_text += " und %d Computer" % cpu_count
	_hint.text = "Dabei: %s\nAuswählen: %s    Zurück zum Beitritt: %s" % [
		players_text,
		InputHints.for_sources(humans, InputBindings.CONFIRM),
		InputHints.for_sources(humans, InputBindings.BACK)]


func _physics_process(_delta: float) -> void:
	if menu == null:
		return
	var sources: Array[InputSource] = InputHints.human_sources()
	for source: InputSource in sources:
		if source.just_pressed(InputBindings.BACK):
			set_physics_process(false)
			Game.goto_join()
			return
	menu.handle_input(sources)


func _on_value_changed(index: int, direction: int) -> void:
	if index == Item.TOURNAMENT:
		var choices: Array[int] = Settings.ROUND_CHOICES
		var i: int = wrapi(choices.find(_rounds) + direction, 0, choices.size())
		_rounds = choices[i]
		Game.tournament_rounds = _rounds
		menu.set_value(index, "%d Runden" % _rounds)


func _on_activated(index: int) -> void:
	set_physics_process(false)
	match index:
		Item.TOURNAMENT:
			Game.start_tournament(_rounds)
		Item.FREE_PLAY:
			Game.start_free_play()
		Item.TEST_ARENA:
			Game.start_test_arena()
		Item.OPTIONS:
			Game.goto_options()
		Item.QUIT:
			Game.quit_game()


func _on_roster_changed() -> void:
	if PlayerRoster.human_count() == 0:
		Game.goto_join()
	else:
		_update_hint()
