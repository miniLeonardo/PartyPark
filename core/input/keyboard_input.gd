class_name KeyboardInput
extends InputSource
## Debug-Spieler auf der Tastatur (D22). Nur in Debug-Builds aktiv, siehe InputRouter.

var bindings: Dictionary = {}
var label: String = ""
var move_label: String = ""


func _init(p_key: String, p_label: String, p_bindings: Dictionary, p_move_label: String) -> void:
	key = p_key
	label = p_label
	bindings = p_bindings
	move_label = p_move_label


func _read_buttons() -> Dictionary[StringName, bool]:
	var result: Dictionary[StringName, bool] = {}
	for action: StringName in InputBindings.BUTTON_ACTIONS:
		result[action] = _any_key(action)
	return result


func _actions_for_event(event: InputEvent) -> Array[StringName]:
	var result: Array[StringName] = []
	var key_event := event as InputEventKey
	if key_event == null:
		return result
	for action: StringName in InputBindings.BUTTON_ACTIONS:
		if (bindings.get(action, []) as Array).has(key_event.physical_keycode):
			result.append(action)
	return result


func _read_move() -> Vector2:
	var move := Vector2(
		float(_any_key(&"right")) - float(_any_key(&"left")),
		float(_any_key(&"down")) - float(_any_key(&"up")))
	return move.normalized()


func get_display_name() -> String:
	return label


func get_action_label(action: StringName) -> String:
	var keys: Array = bindings.get(action, [])
	if keys.is_empty():
		return String(action)
	return key_label(keys[0])


func get_move_label() -> String:
	return move_label


## Lesbarer Name einer physischen Taste im aktuellen Tastaturlayout.
static func key_label(physical: int) -> String:
	if InputBindings.KEY_LABELS.has(physical):
		return InputBindings.KEY_LABELS[physical]
	var keycode: Key = KEY_NONE
	if DisplayServer.get_name() != "headless":
		keycode = DisplayServer.keyboard_get_keycode_from_physical(physical as Key)
	if keycode == KEY_NONE:
		keycode = physical as Key
	return OS.get_keycode_string(keycode)


func _any_key(action: StringName) -> bool:
	for keycode: int in bindings.get(action, []):
		if Input.is_physical_key_pressed(keycode as Key):
			return true
	return false
