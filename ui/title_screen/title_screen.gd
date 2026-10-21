extends Node
## Titelbildschirm (D29): „Drücke A“. Wer drückt, tritt gleich bei und landet im Beitrittsbildschirm.

var _prompt: Label
var _pulse: float = 0.0


func _ready() -> void:
	Game.match_running = false
	add_child(MenuBackdrop.new())
	var ui := CanvasLayer.new()
	add_child(ui)
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(root)
	var title: Label = UiStyle.make_label("PARTYPARK", 170, Color(1, 0.9, 0.35))
	title.custom_minimum_size = Vector2(0, 330)
	root.add_child(title)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(spacer)
	_prompt = UiStyle.make_label("", 44)
	_prompt.custom_minimum_size = Vector2(0, 150)
	root.add_child(_prompt)
	var version: Label = UiStyle.make_label("Version %s (Prototyp)" % ProjectSettings.get_setting("application/config/version", ""), 22, UiStyle.MUTED_COLOR)
	version.custom_minimum_size = Vector2(0, 50)
	root.add_child(version)
	_update_prompt()
	InputRouter.source_connected.connect(_on_sources_changed)
	InputRouter.source_disconnected.connect(_on_sources_changed)


func _exit_tree() -> void:
	if InputRouter.source_connected.is_connected(_on_sources_changed):
		InputRouter.source_connected.disconnect(_on_sources_changed)
		InputRouter.source_disconnected.disconnect(_on_sources_changed)


func _on_sources_changed(_source: InputSource) -> void:
	_update_prompt()


func _update_prompt() -> void:
	var sources: Array[InputSource] = InputHints.joinable_sources()
	if sources.is_empty():
		_prompt.text = "Bitte einen Controller anschließen"
	else:
		_prompt.text = "Drücke " + InputHints.for_sources(sources, InputBindings.CONFIRM)


func _process(delta: float) -> void:
	if _prompt == null:
		return
	_pulse += delta
	_prompt.modulate.a = 0.65 + 0.35 * sin(_pulse * 3.0)


func _physics_process(_delta: float) -> void:
	var requests: Array[InputSource] = InputRouter.poll_join_requests()
	if requests.is_empty():
		return
	Sfx.play_ui(&"join")
	for source: InputSource in requests:
		PlayerRoster.join(source)
		source.rumble(0.4, 0.2, 0.15)
	set_physics_process(false)
	Game.goto_join()
