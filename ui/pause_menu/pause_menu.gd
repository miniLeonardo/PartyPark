class_name PauseMenu
extends CanvasLayer
## Pause-Menü (D21): jeder Spieler kann es öffnen, jeder kann navigieren und auswählen.
## Eigene Navigation über InputSource statt Godot-Fokus, damit jede Eingabe einem Spieler zugeordnet bleibt.

const ITEMS: Array[String] = ["Weiter", "Zum Hauptmenü", "Spiel beenden"]

var is_open: bool = false
var selected: int = 0

var _opened_frame: int = -1
var _title: Label
var _controls: Label
var _item_labels: Array[Label] = []


func _ready() -> void:
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.45)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	var center: CenterContainer = UiStyle.make_center_root()
	add_child(center)
	var panel: PanelContainer = UiStyle.make_panel(UiStyle.PANEL_COLOR)
	panel.custom_minimum_size = Vector2(640, 0)
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	panel.add_child(box)
	_title = UiStyle.make_label("Pause", 64)
	box.add_child(_title)
	for item: String in ITEMS:
		var label: Label = UiStyle.make_label(item, 44)
		_item_labels.append(label)
		box.add_child(label)
	_controls = UiStyle.make_label("", 24, UiStyle.MUTED_COLOR)
	box.add_child(_controls)


func open(by: PlayerSlot) -> void:
	is_open = true
	visible = true
	selected = 0
	_opened_frame = Engine.get_physics_frames()
	_title.text = "Pause" if by == null else "Pause – %s" % by.display_name
	_title.add_theme_color_override("font_color", UiStyle.TEXT_COLOR if by == null else by.color.lightened(0.25))
	_update_controls(by)
	_refresh()


func close() -> void:
	is_open = false
	visible = false


func _physics_process(_delta: float) -> void:
	if not is_open or Engine.get_physics_frames() == _opened_frame:
		return
	for slot: PlayerSlot in PlayerRoster.get_human_slots():
		if slot.disconnected:
			continue
		var source: InputSource = slot.source
		if source.just_pressed(InputBindings.BACK) or source.just_pressed(InputBindings.PAUSE):
			Sfx.play_ui(&"ui_back")
			Game.resume()
			return
		if source.just_pressed(InputBindings.NAV_UP):
			selected = wrapi(selected - 1, 0, ITEMS.size())
			Sfx.play_ui(&"ui_move")
			_refresh()
		elif source.just_pressed(InputBindings.NAV_DOWN):
			selected = wrapi(selected + 1, 0, ITEMS.size())
			Sfx.play_ui(&"ui_move")
			_refresh()
		elif source.just_pressed(InputBindings.CONFIRM):
			Sfx.play_ui(&"ui_confirm")
			_activate(selected)
			return


## Bedienhinweis in den Tasten des Geräts, das die Pause geöffnet hat (D28).
func _update_controls(by: PlayerSlot) -> void:
	if by == null or by.source == null:
		_controls.text = ""
		return
	var source: InputSource = by.source
	_controls.text = "%s: Auswahl   %s: Bestätigen   %s oder %s: Weiter" % [
		source.get_move_label(),
		source.get_action_label(InputBindings.CONFIRM),
		source.get_action_label(InputBindings.BACK),
		source.get_action_label(InputBindings.PAUSE)]


func _activate(index: int) -> void:
	match index:
		0:
			Game.resume()
		1:
			Game.return_to_main_menu()
		2:
			Game.quit_game()


func _refresh() -> void:
	for i: int in _item_labels.size():
		var label: Label = _item_labels[i]
		var active: bool = i == selected
		label.text = ("▶  %s  ◀" % ITEMS[i]) if active else ITEMS[i]
		label.add_theme_color_override("font_color", Color(1, 0.85, 0.3) if active else UiStyle.MUTED_COLOR)
