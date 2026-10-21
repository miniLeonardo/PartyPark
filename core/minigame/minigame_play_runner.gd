class_name MinigamePlayRunner
extends Node
## Entwickler-Schnellstart für Minispiele über --play=<id> [--format=<format>] [--mood=<mood>] [--instant].
## Ermöglicht direktes Testen auf dem Desktop ohne Menü-Navigation.
## Bei Spielende: Bestätigen (A / Leertaste) startet neu, Zurück (B / Esc) führt ins Hauptmenü.

var play_id: String = ""
var format_name: String = ""
var mood_name: String = ""
var instant_mode: bool = false
var cpu_only: bool = false

var _info: MinigameInfo
var _format: int = -1
var _flow: MatchFlow
var _sandbox: MinigameSandbox
var _restart_overlay: CanvasLayer
var _waiting_for_restart: bool = false
var _restart_delay: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_parse_args()
	if play_id.is_empty():
		queue_free()
		return
	_run.call_deferred()


func _parse_args() -> void:
	var args: PackedStringArray = OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	for arg: String in args:
		if arg.begins_with("--play="):
			play_id = arg.trim_prefix("--play=").strip_edges()
		elif arg.begins_with("--format="):
			format_name = arg.trim_prefix("--format=").strip_edges().to_lower()
		elif arg.begins_with("--mood="):
			mood_name = arg.trim_prefix("--mood=").strip_edges().to_lower()
		elif arg == "--instant" or arg == "--sandbox":
			instant_mode = true
		elif arg == "--cpu-only" or arg == "--cpus":
			cpu_only = true
	if DisplayServer.get_name() == "headless":
		cpu_only = true


func _run() -> void:
	# Bisherige Menüszene (z. B. Titelbildschirm) entfernen
	if get_tree().current_scene != null:
		get_tree().current_scene.queue_free()
		await get_tree().process_frame

	_info = MinigameRegistry.get_info(StringName(play_id))
	if _info == null:
		var available: PackedStringArray = []
		for item: MinigameInfo in MinigameRegistry.infos:
			available.append(String(item.id))
		printerr("[Schnellstart] FEHLER: Minispiel '%s' nicht gefunden. Verfügbar: %s" % [play_id, ", ".join(available)])
		if DisplayServer.get_name() == "headless":
			get_tree().quit(1)
		else:
			Game.goto_main_menu()
		queue_free()
		return

	# Format bestimmen
	_format = _info.formats[0]
	if not format_name.is_empty():
		match format_name:
			"ffa", "1":
				_format = TeamFormat.Format.FFA
			"2v2", "two_vs_two", "2":
				_format = TeamFormat.Format.TWO_VS_TWO
			"1v3", "one_vs_three", "3":
				_format = TeamFormat.Format.ONE_VS_THREE
			"coop", "coop_vs_cpu", "4vcpu", "0":
				_format = TeamFormat.Format.COOP_VS_CPU
			_:
				print("[Schnellstart] Unbekanntes Format '%s', verwende Standard %s" % [format_name, TeamFormat.display_name(_format)])

	if not _info.supports(_format, 4):
		print("[Schnellstart] Format %s wird von '%s' nicht unterstützt. Verwende %s" % [
			TeamFormat.display_name(_format), _info.display_name, TeamFormat.display_name(_info.formats[0])
		])
		_format = _info.formats[0]

	# Stimmung setzen
	match mood_name:
		"golden":
			Look.use_mood(Look.Mood.GOLDEN)
		"evening":
			Look.use_mood(Look.Mood.EVENING)
		_:
			Look.use_mood(Look.Mood.NOON)

	print("[Schnellstart] Starte '%s' (%s, ID: %s)" % [_info.display_name, TeamFormat.display_name(_format), _info.id])

	if instant_mode:
		_start_sandbox()
	else:
		_setup_players()
		_start_match()


func _setup_players() -> void:
	PlayerRoster.clear_cpus()
	if not cpu_only:
		# Menschen beitreten lassen: zuerst verbundene Gamepads, sonst Tastatur links
		for source: InputSource in InputRouter.get_sources():
			if source is GamepadInput and source.is_available():
				PlayerRoster.join(source)
		if PlayerRoster.get_human_slots().is_empty():
			for source: InputSource in InputRouter.get_sources():
				if source is KeyboardInput and source.key == "kb:left":
					PlayerRoster.join(source)
					break
	PlayerRoster.fill_with_cpu()


func _start_sandbox() -> void:
	_sandbox = MinigameSandbox.new()
	add_child(_sandbox)
	_sandbox.round_done.connect(_on_sandbox_done)
	_sandbox.start(_info, _format, Settings.cpu_difficulty)


func _on_sandbox_done(result: MinigameResult) -> void:
	var summary: String = result.headline if not result.headline.is_empty() else ("Sieger: %s" % str(result.get_winners()))
	print("[Schnellstart Sandbox] Beendet: %s" % summary)
	if DisplayServer.get_name() == "headless":
		get_tree().quit(0)


func _start_match() -> void:
	_waiting_for_restart = false
	if _restart_overlay != null:
		_restart_overlay.queue_free()
		_restart_overlay = null

	var indices: Array[int] = []
	for slot: PlayerSlot in PlayerRoster.get_active_slots():
		indices.append(slot.index)
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var assignment: TeamAssigner.Assignment = TeamAssigner.assign(rng, _format, indices)
	var context: MinigameContext = MinigameContext.from_assignment(assignment, PlayerRoster.get_active_slots(), Settings.cpu_difficulty)

	Game.match_running = true
	get_tree().paused = false

	_flow = MatchFlow.new()
	add_child(_flow)
	_flow.completed.connect(_on_flow_completed)
	_flow.start(_info, context, "Schnellstart", false)


func _on_flow_completed(result: MinigameResult, _points: Dictionary) -> void:
	var summary: String = result.headline if not result.headline.is_empty() else ("Sieger: %s" % str(result.get_winners()))
	print("[Schnellstart] Spiel beendet: %s" % summary)
	if DisplayServer.get_name() == "headless":
		get_tree().quit(0)
		return
	_waiting_for_restart = true
	_restart_delay = 0.5
	_build_restart_overlay()


func _build_restart_overlay() -> void:
	_restart_overlay = CanvasLayer.new()
	_restart_overlay.layer = 60
	var label := Label.new()
	var humans: Array[InputSource] = []
	for slot: PlayerSlot in PlayerRoster.get_human_slots():
		if slot.source != null:
			humans.append(slot.source)
	var confirm_hint: String = InputHints.for_sources(humans, InputBindings.CONFIRM)
	var back_hint: String = InputHints.for_sources(humans, InputBindings.BACK)
	label.text = "%s: Nochmal spielen    %s: Hauptmenü" % [confirm_hint, back_hint]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	label.position.y -= 60
	_restart_overlay.add_child(label)
	add_child(_restart_overlay)


func _physics_process(delta: float) -> void:
	if not _waiting_for_restart:
		return
	if _restart_delay > 0.0:
		_restart_delay -= delta
		return

	for slot: PlayerSlot in PlayerRoster.get_human_slots():
		if slot.source == null or slot.disconnected:
			continue
		if slot.source.just_pressed(InputBindings.CONFIRM):
			if _flow != null:
				_flow.queue_free()
				_flow = null
			_start_match()
			return
		elif slot.source.just_pressed(InputBindings.BACK):
			if _flow != null:
				_flow.queue_free()
				_flow = null
			if _restart_overlay != null:
				_restart_overlay.queue_free()
				_restart_overlay = null
			_waiting_for_restart = false
			Game.goto_main_menu()
			queue_free()
			return
