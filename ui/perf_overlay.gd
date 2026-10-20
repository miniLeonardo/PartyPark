class_name PerfOverlay
extends CanvasLayer
## Leistungsanzeige (WP 4.5, D69): fps, Frametime, 1-%-Tiefstwert der letzten Sekunden, Draw Calls,
## Objekte, lebende Partikel, Grafikstufe. An/aus über die Optionen oder jederzeit mit F3.

## Wie viele Frames für Durchschnitt und Tiefstwert betrachtet werden.
const WINDOW: int = 240

var _label: Label
var _times: PackedFloat32Array = []
var _last_ticks: int = 0
var _refresh: float = 0.0


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	var panel: PanelContainer = UiStyle.make_panel(Color(0, 0, 0, 0.6))
	panel.position = Vector2(16, 16)
	add_child(panel)
	_label = UiStyle.make_label("", 22, Color(0.7, 1.0, 0.7))
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	panel.add_child(_label)
	_last_ticks = Time.get_ticks_usec()
	visible = Settings.show_performance


func _input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key != null and key.pressed and not key.echo and key.physical_keycode == KEY_F3:
		Settings.show_performance = not Settings.show_performance
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	var now: int = Time.get_ticks_usec()
	var frame_ms: float = float(now - _last_ticks) / 1000.0
	_last_ticks = now
	_times.append(frame_ms)
	if _times.size() > WINDOW:
		_times = _times.slice(_times.size() - WINDOW)
	visible = Settings.show_performance
	if not visible:
		return
	_refresh -= frame_ms / 1000.0
	if _refresh > 0.0:
		return
	_refresh = 0.25
	var stats: Dictionary = frame_stats(_times)
	_label.text = "%d fps   %.1f ms   1%% tief: %d fps\nDraw Calls %d   Objekte %d   Partikel %d\nGrafik %s" % [
		roundi(stats["avg_fps"]), stats["avg_ms"], roundi(stats["low_fps"]),
		int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
		int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)),
		Fx.live_particles(), Settings.QUALITY_NAMES[Settings.graphics_quality]]


## Durchschnitt und 1-%-Tiefstwert aus Frametimes in Millisekunden (auch für den Messmodus).
static func frame_stats(times_ms: PackedFloat32Array) -> Dictionary:
	if times_ms.is_empty():
		return {"avg_ms": 0.0, "avg_fps": 0.0, "low_fps": 0.0, "frames": 0}
	var total: float = 0.0
	for t: float in times_ms:
		total += t
	var avg_ms: float = total / float(times_ms.size())
	var sorted: PackedFloat32Array = times_ms.duplicate()
	sorted.sort()
	var worst_count: int = maxi(1, times_ms.size() / 100)
	var worst_total: float = 0.0
	for i: int in worst_count:
		worst_total += sorted[sorted.size() - 1 - i]
	var worst_ms: float = worst_total / float(worst_count)
	return {
		"avg_ms": avg_ms,
		"avg_fps": 1000.0 / maxf(avg_ms, 0.001),
		"low_fps": 1000.0 / maxf(worst_ms, 0.001),
		"frames": times_ms.size(),
	}
