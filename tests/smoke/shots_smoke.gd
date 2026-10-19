extends Node
## Bildschirmfotos aller Minispiele und der Siegerehrung, ohne komplettes Turnier (für langsame Renderer).
## Start: xvfb-run … godot --path . --rendering-driver vulkan --fixed-fps 60 -- --smoke-shots --shots=<ordner>

var _shot_dir: String = ""
## --only=<id>: nur dieses Minispiel fotografieren.
var _only: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--shots="):
			_shot_dir = arg.trim_prefix("--shots=")
		if arg.begins_with("--only="):
			_only = arg.trim_prefix("--only=")
	_run.call_deferred()


func _run() -> void:
	await _frames(5)
	PlayerRoster.join(InputRouter.get_sources()[0])
	PlayerRoster.fill_with_cpu()
	Game.match_running = true
	var host: Node = get_tree().current_scene
	for child: Node in host.get_children():
		child.queue_free()
	for info: MinigameInfo in MinigameRegistry.infos:
		if not _only.is_empty() and String(info.id) != _only:
			continue
		var format: int = info.formats[0]
		var players: Array[int] = [0, 1, 2, 3]
		var assignment: TeamAssigner.Assignment = TeamAssigner.assign(RandomNumberGenerator.new(), format, players, {0: 0, 1: 5, 2: 5, 3: 5})
		var context: MinigameContext = MinigameContext.from_assignment(assignment, PlayerRoster.get_active_slots(), 1)
		var flow := MatchFlow.new()
		host.add_child(flow)
		flow.start(info, context, "Runde 1 von 5", true)
		await _frames(60)
		await _shot("%s_1_ankuendigung" % info.id)
		await _wait(func() -> bool: return flow.phase == MatchFlow.Phase.RULES, 300)
		await _shot("%s_2_regeln" % info.id)
		flow._ready_state[0] = true
		await _wait(func() -> bool: return flow.phase == MatchFlow.Phase.PLAY, 400)
		await _frames(420)
		await _shot("%s_3_spiel" % info.id)
		var result: MinigameResult
		match format:
			TeamFormat.Format.FFA:
				result = MinigameResult.from_ranking([[1], [0], [2], [3]])
			TeamFormat.Format.COOP_VS_CPU:
				result = MinigameResult.coop(context.indices(), true)
			_:
				result = MinigameResult.team_win(context.team_members(0), context.team_members(1))
		flow.minigame.finish(result)
		await _wait(func() -> bool: return flow.phase == MatchFlow.Phase.RESULT, 300)
		await _frames(5)
		await _shot("%s_4_ergebnis" % info.id)
		flow.queue_free()
		await _frames(3)
	if not _only.is_empty():
		get_tree().quit()
		return
	var ceremony := TournamentCeremony.new()
	ceremony.setup(PlayerRoster.get_active_slots(), {0: 9, 1: 12, 2: 5, 3: 7})
	host.add_child(ceremony)
	await _frames(120)
	await _shot("siegerehrung")
	get_tree().quit()


func _shot(file_name: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(_shot_dir.path_join(file_name + ".png"))
	print("SHOT %s" % file_name)


func _wait(condition: Callable, max_frames: int) -> void:
	for i: int in max_frames:
		if condition.call():
			return
		await _frames(1)


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().process_frame
