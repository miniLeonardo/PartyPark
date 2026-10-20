class_name MenuList
extends VBoxContainer
## Senkrechte Menüliste mit eigener Navigation über InputSource (D26).
## Einträge: {"text": String, "value": String (optional, mit ◀ ▶), "enabled": bool, "hint": String}.

signal activated(index: int)
## Links/rechts auf einem Eintrag mit Wert: direction -1 oder 1.
signal value_changed(index: int, direction: int)

@export var font_size: int = 48

var items: Array[Dictionary] = []
var selected: int = 0

var _labels: Array[Label] = []


func _ready() -> void:
	add_theme_constant_override("separation", 12)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_items(new_items: Array[Dictionary]) -> void:
	items = new_items
	for label: Label in _labels:
		label.queue_free()
	_labels.clear()
	for item: Dictionary in items:
		var label: Label = UiStyle.make_label("", font_size)
		add_child(label)
		_labels.append(label)
	selected = clampi(selected, 0, maxi(0, items.size() - 1))
	_skip_disabled(1)
	refresh()


func set_value(index: int, value: String) -> void:
	items[index]["value"] = value
	refresh()


func current_item() -> Dictionary:
	return items[selected] if selected < items.size() else {}


## Eingaben der übergebenen Quellen auswerten; einmal pro Physik-Frame aufrufen.
func handle_input(sources: Array[InputSource]) -> void:
	if items.is_empty():
		return
	for source: InputSource in sources:
		if source.just_pressed(InputBindings.NAV_UP):
			Sfx.play_ui(&"ui_move")
			_move(-1)
			return
		if source.just_pressed(InputBindings.NAV_DOWN):
			Sfx.play_ui(&"ui_move")
			_move(1)
			return
		if source.just_pressed(InputBindings.NAV_LEFT) and items[selected].has("value"):
			Sfx.play_ui(&"ui_move", 0.0, 0.9)
			value_changed.emit(selected, -1)
			return
		if source.just_pressed(InputBindings.NAV_RIGHT) and items[selected].has("value"):
			Sfx.play_ui(&"ui_move", 0.0, 1.1)
			value_changed.emit(selected, 1)
			return
		if source.just_pressed(InputBindings.CONFIRM) and items[selected].get("enabled", true):
			Sfx.play_ui(&"ui_confirm")
			source.rumble(0.25, 0.0, 0.06)
			activated.emit(selected)
			return


func refresh() -> void:
	for i: int in _labels.size():
		var item: Dictionary = items[i]
		var label: Label = _labels[i]
		var text: String = item.get("text", "")
		if item.has("value"):
			text += ("   ◀ %s ▶" if i == selected else "   %s") % item["value"]
		var enabled: bool = item.get("enabled", true)
		if i == selected:
			label.text = "▶  %s  ◀" % text
			label.add_theme_color_override("font_color", Color(1, 0.85, 0.3) if enabled else Color(0.8, 0.7, 0.5))
		else:
			label.text = text
			label.add_theme_color_override("font_color", UiStyle.TEXT_COLOR if enabled else Color(1, 1, 1, 0.35))


func _move(direction: int) -> void:
	selected = wrapi(selected + direction, 0, items.size())
	_skip_disabled(direction)
	refresh()


func _skip_disabled(direction: int) -> void:
	for i: int in items.size():
		if items[selected].get("selectable", true):
			return
		selected = wrapi(selected + direction, 0, items.size())
