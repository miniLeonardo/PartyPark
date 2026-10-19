class_name DisconnectOverlay
extends CanvasLayer
## Hinweis bei Verbindungsabbruch: Spiel ist pausiert, bis ein Controller den Platz übernimmt.

var _list: Label
var _panel: PanelContainer
var _pause_hint: Label


func _ready() -> void:
	layer = 40
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.45)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	var center: CenterContainer = UiStyle.make_center_root()
	add_child(center)
	_panel = UiStyle.make_panel(UiStyle.PANEL_COLOR, Color(1, 0.4, 0.3), 6)
	_panel.custom_minimum_size = Vector2(900, 0)
	center.add_child(_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	_panel.add_child(box)
	box.add_child(UiStyle.make_label("Controller getrennt", 56, Color(1, 0.55, 0.45)))
	_list = UiStyle.make_label("", 40)
	box.add_child(_list)
	box.add_child(UiStyle.make_label("Drücke A auf einem Controller, um den Platz zu übernehmen.", 30))
	_pause_hint = UiStyle.make_label("", 24, UiStyle.MUTED_COLOR)
	box.add_child(_pause_hint)


func set_waiting(waiting: bool) -> void:
	visible = waiting
	if not waiting:
		return
	var names: PackedStringArray = []
	for slot: PlayerSlot in PlayerRoster.get_disconnected_slots():
		names.append(slot.display_name)
	_list.text = ", ".join(names)
	var pause_keys: String = InputHints.for_humans(InputBindings.PAUSE)
	_pause_hint.text = "" if pause_keys.is_empty() else "Pause-Menü: " + pause_keys
