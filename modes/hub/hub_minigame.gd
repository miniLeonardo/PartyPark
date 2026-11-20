extends Node
## Spielt ein Minispiel, das im Freizeitpark an einer Bude gestartet wurde, in eigener Szene (D125).
## Danach geht es zurück in den Park neben die Bude. Vorher lief das Minispiel mitten in der Parkwelt,
## deren Kollisionen (Brunnen, Rasen) in die Arena ragten.

var flow: MatchFlow


func _ready() -> void:
	var info: MinigameInfo = Game.hub_pending_minigame
	if info == null:
		Game.return_to_hub.call_deferred()
		return
	Game.match_running = true
	var slots: Array[PlayerSlot] = PlayerRoster.get_active_slots()
	var format: int = info.formats[0]
	for candidate: int in info.formats:
		if info.supports(candidate, slots.size()):
			format = candidate
			break
	var indices: Array[int] = []
	for slot: PlayerSlot in slots:
		indices.append(slot.index)
	var assignment: TeamAssigner.Assignment = TeamAssigner.assign(RandomNumberGenerator.new(), format, indices, {})
	var context: MinigameContext = MinigameContext.from_assignment(assignment, slots, Settings.cpu_difficulty)
	Log.info("HUB", "Minispiel '%s' in eigener Szene gestartet" % info.display_name)
	flow = MatchFlow.new()
	add_child(flow)
	flow.completed.connect(_on_flow_completed)
	flow.start(info, context, info.display_name, false)


func _on_flow_completed(_result: MinigameResult, _points: Dictionary) -> void:
	Log.info("HUB", "Minispiel beendet -> zurück in den Park")
	Game.return_to_hub()
