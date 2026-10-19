class_name KeyboardInput
extends InputSource
## Debug-Spieler auf der Tastatur (D22). Nur in Debug-Builds aktiv, siehe InputRouter.

var bindings: Dictionary = {}
var label: String = ""


func _init(p_key: String, p_label: String, p_bindings: Dictionary) -> void:
	key = p_key
	label = p_label
	bindings = p_bindings


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


func _any_key(action: StringName) -> bool:
	for keycode: int in bindings.get(action, []):
		if Input.is_physical_key_pressed(keycode as Key):
			return true
	return false
