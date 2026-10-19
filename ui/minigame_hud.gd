class_name MinigameHud
extends CanvasLayer
## Gemeinsames HUD für Minispiele: Zeit oben mittig, Statuszeile pro Spieler oben, Meldungen in der Mitte.

var _timer_label: Label
var _status_row: HBoxContainer
var _status_labels: Dictionary = {}
var _message: Label
var _message_time: float = 0.0


func _ready() -> void:
	layer = 10
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_timer_label = UiStyle.make_label("", 56)
	_timer_label.custom_minimum_size = Vector2(0, 80)
	root.add_child(_timer_label)
	_status_row = HBoxContainer.new()
	_status_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_status_row.add_theme_constant_override("separation", 24)
	_status_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_status_row)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(spacer)
	# Meldungen im unteren Drittel, damit sie das Geschehen in der Mitte nicht verdecken
	var center: CenterContainer = UiStyle.make_center_root()
	center.anchor_top = 0.62
	center.anchor_bottom = 0.85
	add_child(center)
	_message = UiStyle.make_label("", 60, Color(1, 0.92, 0.4))
	center.add_child(_message)


func _process(delta: float) -> void:
	if _message_time > 0.0:
		_message_time -= delta
		if _message_time <= 0.0:
			_message.text = ""


func set_timer(seconds: float) -> void:
	_timer_label.text = "%d" % ceili(seconds)


func hide_timer() -> void:
	_timer_label.text = ""


## Statustext pro Spielerplatz, z. B. „P1  3 Leben“.
func set_status(slot: PlayerSlot, text: String) -> void:
	var panel: PanelContainer = _status_labels.get(slot.index)
	if panel == null:
		panel = UiStyle.make_panel(Color(0.08, 0.09, 0.14, 0.8), slot.color, 4)
		var style := panel.get_theme_stylebox("panel") as StyleBoxFlat
		style.set_content_margin_all(12.0)
		panel.add_child(UiStyle.make_label("", 28))
		_status_row.add_child(panel)
		_status_labels[slot.index] = panel
	(panel.get_child(0) as Label).text = text


## Freier Text in der Statuszeile (z. B. Seile 2/5), Schlüssel frei wählbar.
func set_info(key: String, text: String, color: Color = Color.WHITE) -> void:
	var panel: PanelContainer = _status_labels.get(key)
	if panel == null:
		panel = UiStyle.make_panel(Color(0.08, 0.09, 0.14, 0.8), color, 4)
		var style := panel.get_theme_stylebox("panel") as StyleBoxFlat
		style.set_content_margin_all(12.0)
		panel.add_child(UiStyle.make_label("", 28))
		_status_row.add_child(panel)
		_status_labels[key] = panel
	(panel.get_child(0) as Label).text = text


func show_message(text: String, duration: float = 1.5) -> void:
	_message.text = text
	_message_time = duration
