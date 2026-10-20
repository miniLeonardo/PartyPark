extends CanvasLayer
## Autoload Announcer (WP 4.4): der Ansager „Hodenhüpfer“ (D67, D68), ein trockener Kommentator.
## Zeigt eine Sprechblase unten links, der Text erscheint Zeichen für Zeichen und wird von
## silbenweisem Geplapper begleitet (Sfx-Silben `voice_0` bis `voice_5`, Bus Voice).
## Spruchlisten je Ereignis in `core/announcer/announcer_lines.json`, zufällig ohne direkte Wiederholung.
## Nie spielblockierend: wichtigere Sprüche unterbrechen unwichtigere, der Rest wird verworfen.
##
## Beispiele:
##   Announcer.say(&"round_start", {"game": "Tauziehen"})
##   Announcer.say(&"bad_luck", {"player": "Spieler 2"}, 0.5)   # nur in der Hälfte der Fälle

const LINES_PATH: String = "res://core/announcer/announcer_lines.json"
const DISPLAY_NAME: String = "Hodenhüpfer"
## Wichtigkeit je Ereignis (höher unterbricht niedriger).
const PRIORITY: Dictionary = {
	&"countdown": 1, &"bad_luck": 1, &"close_call": 2, &"round_start": 2,
	&"win": 3, &"coop_lost": 3, &"draw": 3, &"tournament_end": 4,
}
const VOICE_COUNT: int = 6

## Grundtonhöhe und Streuung der Silben (trocken: tief und fast monoton).
@export var base_pitch: float = 0.82
@export var pitch_spread: float = 0.05
## Zeichen pro Sekunde, wächst mit der Textlänge (längere Sätze werden zügiger gesprochen).
@export var min_chars_per_second: float = 16.0
@export var max_chars_per_second: float = 32.0
## Alle wie viele Buchstaben eine Silbe erklingt.
@export var letters_per_syllable: float = 2.6
## Sichtbarkeit nach dem letzten Zeichen: fest plus pro Zeichen (Sekunden).
@export var hold_time: float = 1.3
@export var hold_per_char: float = 0.035

## Für Tests und Anzeige.
var last_event: StringName = &""
var last_line: String = ""
var spoken_count: int = 0

var _lines: Dictionary = {}
var _last_index: Dictionary = {}
var _rng := RandomNumberGenerator.new()
var _text: String = ""
var _shown: float = 0.0
var _speed: float = 20.0
var _hold: float = 0.0
var _priority: int = 0
var _letters_since_syllable: float = 0.0
var _queued: Array = []
var _fade: float = 0.0
var _root: Control
var _label: Label
var _portrait: AnnouncerPortrait


func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_rng.randomize()
	_load_lines()
	_build_ui()
	_root.modulate.a = 0.0


func _load_lines() -> void:
	var text: String = FileAccess.get_file_as_string(LINES_PATH)
	var data: Variant = JSON.parse_string(text)
	if data is Dictionary:
		for key: String in data:
			if data[key] is Array:
				_lines[StringName(key)] = data[key]
	else:
		push_warning("Announcer: %s nicht lesbar" % LINES_PATH)


## Alle Ereignisse mit Sprüchen (für Tests).
func get_events() -> Array:
	return _lines.keys()


func get_lines(event: StringName) -> Array:
	return _lines.get(event, [])


func is_speaking() -> bool:
	return not _text.is_empty() and (_shown < float(_text.length()) or _hold > 0.0)


## Lässt den Ansager etwas zu einem Ereignis sagen. chance < 1 lässt ihn manchmal schweigen.
func say(event: StringName, values: Dictionary = {}, chance: float = 1.0) -> void:
	var list: Array = _lines.get(event, [])
	if list.is_empty() or _rng.randf() > chance:
		return
	var priority: int = int(PRIORITY.get(event, 1))
	if is_speaking():
		if priority > _priority:
			_queued.clear()
		elif priority >= 2 and _queued.is_empty():
			_queued.append([event, values])
			return
		else:
			return
	_start(event, values)


## Bricht ab und blendet aus (z. B. beim Szenenwechsel ins Menü).
func stop() -> void:
	_queued.clear()
	_text = ""
	_hold = 0.0


func _start(event: StringName, values: Dictionary) -> void:
	var list: Array = _lines[event]
	var index: int = _rng.randi_range(0, list.size() - 1)
	if list.size() > 1 and index == int(_last_index.get(event, -1)):
		index = (index + 1 + _rng.randi_range(0, list.size() - 2)) % list.size()
	_last_index[event] = index
	var line: String = String(list[index])
	for key: String in values:
		line = line.replace("{%s}" % key, str(values[key]))
	_text = line
	_shown = 0.0
	_letters_since_syllable = letters_per_syllable
	_speed = clampf(min_chars_per_second + float(line.length()) * 0.15, min_chars_per_second, max_chars_per_second)
	_hold = hold_time + hold_per_char * float(line.length())
	_priority = int(PRIORITY.get(event, 1))
	last_event = event
	last_line = line
	spoken_count += 1
	_label.text = ""


func _process(delta: float) -> void:
	# Unskalierte Zeit, damit die Zeitlupe am Rundenende den Ansager nicht verlangsamt
	var real_delta: float = delta / maxf(Engine.time_scale, 0.01)
	var visible_now: bool = not _text.is_empty()
	_fade = move_toward(_fade, 1.0 if visible_now else 0.0, real_delta * 6.0)
	_root.modulate.a = _fade
	if _text.is_empty():
		_portrait.mouth = 0.0
		return
	var total: int = _text.length()
	if _shown < float(total):
		var before: int = int(_shown)
		_shown = minf(float(total), _shown + _speed * real_delta)
		var after: int = int(_shown)
		for i: int in range(before, after):
			_on_letter(_text[i])
		_label.text = _text.substr(0, after)
	else:
		_portrait.mouth = move_toward(_portrait.mouth, 0.0, real_delta * 8.0)
		_hold -= real_delta
		if _hold <= 0.0:
			_text = ""
			_priority = 0
			if not _queued.is_empty():
				var next: Array = _queued.pop_front()
				_start(next[0], next[1])
	_portrait.queue_redraw()


func _on_letter(letter: String) -> void:
	if letter in [" ", ".", ",", "!", "?", ":", "-"]:
		_portrait.mouth = 0.15
		return
	_letters_since_syllable += 1.0
	if _letters_since_syllable >= letters_per_syllable:
		_letters_since_syllable = 0.0
		var pitch: float = base_pitch * (1.0 + _rng.randf_range(-pitch_spread, pitch_spread))
		Sfx.play_voice(StringName("voice_%d" % _rng.randi_range(0, VOICE_COUNT - 1)), pitch)
		_portrait.mouth = 1.0
	else:
		_portrait.mouth = maxf(0.3, _portrait.mouth - 0.3)


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 12)
	row.anchor_top = 1.0
	row.anchor_bottom = 1.0
	row.offset_left = 40.0
	row.offset_top = -250.0
	row.offset_bottom = -40.0
	row.alignment = BoxContainer.ALIGNMENT_END
	_root.add_child(row)
	_portrait = AnnouncerPortrait.new()
	_portrait.custom_minimum_size = Vector2(150, 150)
	_portrait.size_flags_vertical = Control.SIZE_SHRINK_END
	row.add_child(_portrait)
	var panel: PanelContainer = UiStyle.make_panel(Color(1, 1, 1, 0.95), Color(0.2, 0.2, 0.25), 4)
	panel.size_flags_vertical = Control.SIZE_SHRINK_END
	row.add_child(panel)
	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(box)
	var name_label: Label = UiStyle.make_label(DISPLAY_NAME, 24, Color(0.45, 0.45, 0.5))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	box.add_child(name_label)
	_label = UiStyle.make_label("", 34, Color(0.1, 0.1, 0.14))
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.custom_minimum_size = Vector2(620, 0)
	box.add_child(_label)
