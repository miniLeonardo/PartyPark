extends Node
## Schnellturnier (D12, D31, D32): pro Runde Format, Minispiel und Teams auslosen, MatchFlow starten,
## Punkte sammeln, Zwischenstand zeigen, am Ende Siegerehrung.

enum State { ROUND, STANDINGS, CEREMONY, EMPTY }

## Zwischenstand schließt sich spätestens nach dieser Zeit.
@export var standings_auto_time: float = 20.0

var rounds_total: int = 5
var round_number: int = 0
## Platzindex → Gesamtpunkte.
var totals: Dictionary = {}
var participants: Array[PlayerSlot] = []
var state: State = State.ROUND
var flow: MatchFlow
var rng := RandomNumberGenerator.new()
## Reihenfolge der gespielten Runden: [{format, game}] (für Tests und Anzeige).
var history: Array[Dictionary] = []

var _last_format: int = -1
var _last_game: StringName = &""
var _last_pairs: Array = []
var _timer: float = 0.0
var _screen: Node


func _ready() -> void:
	Game.match_running = true
	rng.randomize()
	rounds_total = Game.tournament_rounds
	participants = PlayerRoster.get_active_slots()
	for slot: PlayerSlot in participants:
		totals[slot.index] = 0
		slot.total_score = 0
	if MinigameRegistry.available_formats(participants.size()).is_empty():
		state = State.EMPTY
		_show_screen(_build_message("Für %d Spieler gibt es noch kein passendes Minispiel." % participants.size()))
		return
	_next_round()


func _physics_process(delta: float) -> void:
	_timer += delta
	match state:
		State.STANDINGS:
			if _timer >= standings_auto_time or (_timer > 0.6 and _any_human_confirm()):
				_next_round()
		State.CEREMONY, State.EMPTY:
			if _timer > 1.5 and _any_human_confirm():
				set_physics_process(false)
				Game.goto_main_menu()


func _next_round() -> void:
	_clear_screen()
	round_number += 1
	if round_number > rounds_total:
		_show_ceremony()
		return
	state = State.ROUND
	var count: int = participants.size()
	var format: int = TeamAssigner.pick_format(rng, MinigameRegistry.available_formats(count), _last_format)
	var candidates: Array[StringName] = []
	for info: MinigameInfo in MinigameRegistry.filter(format, count):
		candidates.append(info.id)
	var game_id: StringName = TeamAssigner.pick_game(rng, candidates, _last_game)
	var indices: Array[int] = []
	for slot: PlayerSlot in participants:
		indices.append(slot.index)
	var pairs: Array = _last_pairs if format == TeamFormat.Format.TWO_VS_TWO else []
	var assignment: TeamAssigner.Assignment = TeamAssigner.assign(rng, format, indices, totals, pairs)
	if format == TeamFormat.Format.TWO_VS_TWO:
		_last_pairs = assignment.teams
	_last_format = format
	_last_game = game_id
	history.append({"format": format, "game": game_id, "solo": assignment.solo})
	var context: MinigameContext = MinigameContext.from_assignment(assignment, participants, Settings.cpu_difficulty)
	flow = MatchFlow.new()
	add_child(flow)
	flow.completed.connect(_on_round_completed)
	flow.start(MinigameRegistry.get_info(game_id), context, "Runde %d von %d" % [round_number, rounds_total], true)


func _on_round_completed(_result: MinigameResult, points: Dictionary) -> void:
	for index: int in points:
		totals[index] = int(totals.get(index, 0)) + int(points[index])
		var slot: PlayerSlot = _slot(index)
		if slot != null:
			slot.total_score = totals[index]
	flow.queue_free()
	flow = null
	state = State.STANDINGS
	_timer = 0.0
	_show_screen(_build_standings(points))


func _show_ceremony() -> void:
	state = State.CEREMONY
	_timer = 0.0
	var ceremony := TournamentCeremony.new()
	ceremony.setup(participants, totals)
	_show_screen(ceremony)


func _slot(index: int) -> PlayerSlot:
	for slot: PlayerSlot in participants:
		if slot.index == index:
			return slot
	return null


func _any_human_confirm() -> bool:
	for slot: PlayerSlot in participants:
		if slot.is_human() and not slot.disconnected and slot.source.just_pressed(InputBindings.CONFIRM):
			return true
	return false


func _show_screen(node: Node) -> void:
	_clear_screen()
	_screen = node
	add_child(node)


func _clear_screen() -> void:
	if _screen != null:
		_screen.queue_free()
		_screen = null


func _build_standings(points: Dictionary) -> Node:
	var root := Node.new()
	var backdrop := MenuBackdrop.new()
	backdrop.show_joined_only = true
	root.add_child(backdrop)
	var ui := CanvasLayer.new()
	root.add_child(ui)
	var center: CenterContainer = UiStyle.make_center_root()
	ui.add_child(center)
	var panel: PanelContainer = UiStyle.make_panel(UiStyle.PANEL_COLOR)
	panel.custom_minimum_size = Vector2(1000, 0)
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	box.add_child(UiStyle.make_label("Zwischenstand", 72, Color(1, 0.9, 0.35)))
	box.add_child(UiStyle.make_label("nach Runde %d von %d" % [round_number, rounds_total], 32, UiStyle.MUTED_COLOR))
	var place: int = 1
	for group: Array in Scoring.standings(totals):
		for index: int in group:
			var slot: PlayerSlot = _slot(index)
			var text: String = "%d.  %s   %d Punkte   (+%d)" % [place, slot.display_name, totals[index], points.get(index, 0)]
			box.add_child(UiStyle.make_label(text, 42, slot.color.lightened(0.25)))
		place += group.size()
	var next_text: String = "Weiter zur Siegerehrung" if round_number >= rounds_total else "Weiter zur nächsten Runde"
	box.add_child(UiStyle.make_label("%s: %s" % [next_text, InputHints.for_humans(InputBindings.CONFIRM)], 26, UiStyle.MUTED_COLOR))
	return root


func _build_message(text: String) -> Node:
	var root := Node.new()
	root.add_child(MenuBackdrop.new())
	var ui := CanvasLayer.new()
	root.add_child(ui)
	var center: CenterContainer = UiStyle.make_center_root()
	ui.add_child(center)
	var panel: PanelContainer = UiStyle.make_panel(UiStyle.PANEL_COLOR)
	center.add_child(panel)
	var box := VBoxContainer.new()
	panel.add_child(box)
	box.add_child(UiStyle.make_label(text, 40))
	box.add_child(UiStyle.make_label("Zurück: " + InputHints.for_humans(InputBindings.CONFIRM), 26, UiStyle.MUTED_COLOR))
	return root
