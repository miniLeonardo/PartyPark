class_name AnnouncerPortrait
extends Control
## Platzhalter-Gesicht des Ansagers (D68): rundes graues Gesicht mit Brille, Mund öffnet sich mit den Silben.

## 0 = geschlossen, 1 = weit offen.
var mouth: float = 0.0


func _draw() -> void:
	var c: Vector2 = size * 0.5
	var r: float = minf(size.x, size.y) * 0.45
	draw_circle(c + Vector2(4, 6), r, Color(0, 0, 0, 0.25))
	draw_circle(c, r, Color("#9aa0a8"))
	draw_arc(c, r, 0.0, TAU, 48, Color("#5d636b"), 4.0, true)
	# Brille
	var eye_y: float = c.y - r * 0.2
	for side: float in [-1.0, 1.0]:
		var eye := Vector2(c.x + side * r * 0.38, eye_y)
		draw_circle(eye, r * 0.22, Color(1, 1, 1, 0.9))
		draw_arc(eye, r * 0.24, 0.0, TAU, 32, Color("#2b2e33"), 4.0, true)
		draw_circle(eye + Vector2(0, r * 0.04), r * 0.08, Color("#2b2e33"))
	draw_line(Vector2(c.x - r * 0.14, eye_y), Vector2(c.x + r * 0.14, eye_y), Color("#2b2e33"), 4.0)
	# Mund: Strich, der sich zu einem Oval öffnet
	var mouth_center := Vector2(c.x, c.y + r * 0.42)
	var height: float = lerpf(2.0, r * 0.28, clampf(mouth, 0.0, 1.0))
	draw_set_transform(mouth_center, 0.0, Vector2(1.0, height / (r * 0.3)))
	draw_circle(Vector2.ZERO, r * 0.3, Color("#3a2a2a"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
