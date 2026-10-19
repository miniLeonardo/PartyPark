class_name BeatRing
extends Control
## Taktanzeige für Tauziehen: ein Ring zieht sich zusammen und trifft im Takt den inneren Kreis.

## 0 = gerade ein Schlag vorbei, 1 = nächster Schlag jetzt.
var progress: float = 0.0
var flash: float = 0.0

@export var outer_radius: float = 190.0
@export var inner_radius: float = 70.0


func _ready() -> void:
	custom_minimum_size = Vector2(outer_radius * 2.0 + 20.0, outer_radius * 2.0 + 20.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	flash = maxf(0.0, flash - delta * 3.0)
	queue_redraw()


func pulse() -> void:
	flash = 1.0


func _draw() -> void:
	var center: Vector2 = size * 0.5
	draw_circle(center, inner_radius, Color(1, 0.85, 0.3, 0.25 + 0.6 * flash))
	draw_arc(center, inner_radius, 0.0, TAU, 48, Color(1, 0.9, 0.4), 6.0, true)
	var radius: float = lerpf(outer_radius, inner_radius, clampf(progress, 0.0, 1.0))
	draw_arc(center, radius, 0.0, TAU, 64, Color(1, 1, 1, 0.9), 8.0, true)
