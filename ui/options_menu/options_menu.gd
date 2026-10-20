extends Node
## Optionen (D39): Computer-Stärke, Vibration, Bildschirmwackeln (D55), Lautstärken (D61), Grafik und
## Leistungsanzeige (D69), Vollbild,
## Standard-Turnierlänge.
## Links/rechts ändert, B zurück.

enum Item { DIFFICULTY, VIBRATION, SCREEN_SHAKE, MUSIC, SFX, VOICE, GRAPHICS, PERFORMANCE, FULLSCREEN, ROUNDS, BACK }

var menu: MenuList
var _hint: Label


func _ready() -> void:
	Game.match_running = false
	add_child(MenuBackdrop.new())
	var ui := CanvasLayer.new()
	add_child(ui)
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(root)
	var title: Label = UiStyle.make_label("Optionen", 96, Color(1, 0.9, 0.35))
	title.custom_minimum_size = Vector2(0, 200)
	root.add_child(title)
	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(center)
	var panel: PanelContainer = UiStyle.make_panel(UiStyle.PANEL_COLOR)
	panel.custom_minimum_size = Vector2(1000, 0)
	center.add_child(panel)
	menu = MenuList.new()
	menu.font_size = 44
	panel.add_child(menu)
	menu.activated.connect(_on_activated)
	menu.value_changed.connect(_on_value_changed)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(spacer)
	_hint = UiStyle.make_label("", 28)
	_hint.custom_minimum_size = Vector2(0, 90)
	root.add_child(_hint)
	_build_items()


func _build_items() -> void:
	var items: Array[Dictionary] = [
		{"text": "Computer-Stärke", "value": Settings.DIFFICULTY_NAMES[Settings.cpu_difficulty]},
		{"text": "Vibration", "value": "An" if Settings.vibration_enabled else "Aus"},
		{"text": "Bildschirmwackeln", "value": "An" if Settings.screen_shake else "Aus"},
		{"text": "Musik", "value": "%d %%" % roundi(Settings.volume_music * 100.0)},
		{"text": "Effekte", "value": "%d %%" % roundi(Settings.volume_sfx * 100.0)},
		{"text": "Stimme", "value": "%d %%" % roundi(Settings.volume_voice * 100.0)},
		{"text": "Grafik", "value": Settings.QUALITY_NAMES[Settings.graphics_quality]},
		{"text": "Leistungsanzeige", "value": "An" if Settings.show_performance else "Aus"},
		{"text": "Vollbild", "value": "An" if Settings.fullscreen else "Aus"},
		{"text": "Turnierlänge", "value": "%d Runden" % Settings.tournament_rounds},
		{"text": "Zurück"},
	]
	var keep: int = menu.selected
	menu.set_items(items)
	menu.selected = keep
	menu.refresh()
	var humans: Array[InputSource] = InputHints.human_sources()
	_hint.text = "Ändern: %s    Zurück: %s" % [
		"links/rechts",
		InputHints.for_sources(humans, InputBindings.BACK)]


func _physics_process(_delta: float) -> void:
	var sources: Array[InputSource] = InputHints.human_sources()
	for source: InputSource in sources:
		if source.just_pressed(InputBindings.BACK):
			Sfx.play_ui(&"ui_back")
			_leave()
			return
	menu.handle_input(sources)


func _on_value_changed(index: int, direction: int) -> void:
	match index:
		Item.DIFFICULTY:
			Settings.cpu_difficulty = clampi(Settings.cpu_difficulty + direction, 0, 2)
		Item.VIBRATION:
			Settings.vibration_enabled = not Settings.vibration_enabled
			if Settings.vibration_enabled:
				for source: InputSource in InputHints.human_sources():
					source.rumble(0.5, 0.3, 0.2)
		Item.SCREEN_SHAKE:
			Settings.screen_shake = not Settings.screen_shake
		Item.MUSIC:
			Settings.volume_music = Settings.step_volume(Settings.volume_music, direction)
			Settings.apply_audio()
		Item.SFX:
			Settings.volume_sfx = Settings.step_volume(Settings.volume_sfx, direction)
			Settings.apply_audio()
			Sfx.play_ui(&"bump")
		Item.VOICE:
			Settings.volume_voice = Settings.step_volume(Settings.volume_voice, direction)
			Settings.apply_audio()
			Sfx.play_voice(&"voice_1", 1.2)
		Item.GRAPHICS:
			Settings.graphics_quality = clampi(Settings.graphics_quality + direction, 0, 2)
			Settings.apply_graphics()
		Item.PERFORMANCE:
			Settings.show_performance = not Settings.show_performance
		Item.FULLSCREEN:
			Settings.fullscreen = not Settings.fullscreen
			Settings.apply_display()
		Item.ROUNDS:
			var choices: Array[int] = Settings.ROUND_CHOICES
			Settings.tournament_rounds = choices[wrapi(choices.find(Settings.tournament_rounds) + direction, 0, choices.size())]
			Game.tournament_rounds = Settings.tournament_rounds
	Settings.save_settings()
	_build_items()


func _on_activated(index: int) -> void:
	if index == Item.BACK:
		_leave()
	elif index in [Item.MUSIC, Item.SFX, Item.VOICE]:
		# Bestätigen bei Lautstärken: eine Stufe lauter, über 100 % wieder bei 0
		var values: Array[float] = [Settings.volume_music, Settings.volume_sfx, Settings.volume_voice]
		var value: float = values[index - Item.MUSIC]
		_on_value_changed(index, 1 if value < 0.999 else -10)
	else:
		_on_value_changed(index, 1)


func _leave() -> void:
	set_physics_process(false)
	Game.goto_main_menu()
