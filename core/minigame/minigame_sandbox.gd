class_name MinigameSandbox
extends Node
## Spielt ein Minispiel ohne Menüs und ohne MatchFlow mit Computergegnern auf allen vier Plätzen.
## Genutzt vom Smoke-Test `--smoke-games` und vom Messmodus `--bench`. Eigene Spielerplätze,
## PlayerRoster bleibt unberührt.

signal round_done(result: MinigameResult)

var minigame: Minigame
var slots: Array[PlayerSlot] = []
var result: MinigameResult
var running: bool = false


## Baut das Minispiel auf und startet die Runde sofort (ohne Regeln und Countdown).
## time_limit_override > 0 ersetzt das Zeitlimit des Spiels.
func start(info: MinigameInfo, format: int, difficulty: int = 1, time_limit_override: float = -1.0, seed_value: int = 0) -> void:
	stop()
	result = null
	slots = _make_cpu_slots(PlayerRoster.MAX_PLAYERS)
	var rng := RandomNumberGenerator.new()
	if seed_value != 0:
		rng.seed = seed_value
	else:
		rng.randomize()
	var indices: Array[int] = []
	for slot: PlayerSlot in slots:
		indices.append(slot.index)
	var assignment: TeamAssigner.Assignment = TeamAssigner.assign(rng, format, indices)
	var context: MinigameContext = MinigameContext.from_assignment(assignment, slots, difficulty)
	minigame = (load(info.scene_path) as PackedScene).instantiate() as Minigame
	add_child(minigame)
	minigame.setup(context, info)
	if time_limit_override > 0.0:
		minigame.time_limit = time_limit_override
	minigame.finished.connect(_on_finished)
	running = true
	minigame.start_round()


## Räumt Minispiel und Computer-Eingaben wieder ab.
func stop() -> void:
	running = false
	if minigame != null and is_instance_valid(minigame):
		minigame.queue_free()
	minigame = null
	for slot: PlayerSlot in slots:
		if slot.source != null:
			InputRouter.unregister_source(slot.source)
	slots.clear()


func _exit_tree() -> void:
	stop()


func _on_finished(p_result: MinigameResult) -> void:
	result = p_result
	running = false
	round_done.emit(p_result)


func _make_cpu_slots(count: int) -> Array[PlayerSlot]:
	var list: Array[PlayerSlot] = []
	for i: int in count:
		var slot := PlayerSlot.new(i, PlayerRoster.PLAYER_COLORS[i], "Computer %d" % (i + 1))
		var ai := AIInput.new(100 + i)
		InputRouter.register_source(ai)
		slot.source = ai
		slot.is_cpu = true
		list.append(slot)
	return list
