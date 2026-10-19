class_name GamepadInput
extends InputSource
## Ein echter Controller. Liest Tasten und Achsen gezielt für eine Geräte-ID.

## Radiale Deadzone des linken Sticks.
const STICK_DEADZONE: float = 0.2

var device: int = -1
var guid: String = ""
var connected: bool = true
## Beschriftungsstil der Tasten: "xbox", "playstation" oder "nintendo" (aus dem Gerätenamen erkannt).
var label_style: String = "xbox"

## Tastenbeschriftung nach Position (SDL3 meldet Positionen, nicht Aufdrucke).
const BUTTON_LABELS: Dictionary = {
	"xbox": {JOY_BUTTON_A: "A", JOY_BUTTON_B: "B", JOY_BUTTON_X: "X", JOY_BUTTON_Y: "Y", JOY_BUTTON_START: "Start"},
	"playstation": {JOY_BUTTON_A: "Kreuz", JOY_BUTTON_B: "Kreis", JOY_BUTTON_X: "Viereck", JOY_BUTTON_Y: "Dreieck", JOY_BUTTON_START: "Options"},
	"nintendo": {JOY_BUTTON_A: "B", JOY_BUTTON_B: "A", JOY_BUTTON_X: "Y", JOY_BUTTON_Y: "X", JOY_BUTTON_START: "+"},
}


func _init(p_device: int) -> void:
	device = p_device
	key = "joy:%d" % p_device
	if Input.get_connected_joypads().has(p_device):
		guid = Input.get_joy_guid(p_device)
	label_style = detect_label_style(get_display_name())


## Erkennt die Controllerfamilie am Namen, den SDL meldet.
static func detect_label_style(joy_name: String) -> String:
	var lower: String = joy_name.to_lower()
	for word: String in ["playstation", "dualsense", "dualshock", "ps3", "ps4", "ps5", "sony"]:
		if lower.contains(word):
			return "playstation"
	for word: String in ["nintendo", "switch", "joy-con", "pro controller"]:
		if lower.contains(word):
			return "nintendo"
	return "xbox"


func _read_buttons() -> Dictionary[StringName, bool]:
	var result: Dictionary[StringName, bool] = {}
	if not connected:
		return result
	for action: StringName in InputBindings.GAMEPAD:
		var pressed: bool = false
		for button: int in InputBindings.GAMEPAD[action]:
			if Input.is_joy_button_pressed(device, button as JoyButton):
				pressed = true
				break
		result[action] = pressed
	return result


func _actions_for_event(event: InputEvent) -> Array[StringName]:
	var result: Array[StringName] = []
	var button_event := event as InputEventJoypadButton
	if button_event == null or button_event.device != device:
		return result
	for action: StringName in InputBindings.GAMEPAD:
		if (InputBindings.GAMEPAD[action] as Array).has(button_event.button_index):
			result.append(action)
	return result


func _read_move() -> Vector2:
	if not connected:
		return Vector2.ZERO
	var stick := Vector2(
		Input.get_joy_axis(device, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(device, JOY_AXIS_LEFT_Y))
	var length: float = stick.length()
	if length < STICK_DEADZONE:
		stick = Vector2.ZERO
	else:
		# Nach der Deadzone wieder auf 0 bis 1 strecken, damit feines Laufen möglich bleibt.
		stick = stick / length * minf(1.0, (length - STICK_DEADZONE) / (1.0 - STICK_DEADZONE))
	var dpad := Vector2(
		float(Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_RIGHT)) - float(Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_LEFT)),
		float(Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_DOWN)) - float(Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_UP)))
	if dpad != Vector2.ZERO:
		return dpad.normalized()
	return stick


func rumble(weak: float, strong: float, duration: float) -> void:
	if connected and Settings.vibration_enabled:
		Input.start_joy_vibration(device, clampf(weak, 0.0, 1.0), clampf(strong, 0.0, 1.0), duration)


func is_available() -> bool:
	return connected


func get_kind_name() -> String:
	return "Controller"


func get_action_label(action: StringName) -> String:
	var buttons: Array = InputBindings.GAMEPAD.get(action, [])
	if buttons.is_empty():
		return String(action)
	return (BUTTON_LABELS[label_style] as Dictionary).get(buttons[0], "?")


func get_display_name() -> String:
	var joy_name: String = ""
	if Input.get_connected_joypads().has(device):
		joy_name = Input.get_joy_name(device)
	if joy_name.is_empty():
		joy_name = "Controller"
	return joy_name
