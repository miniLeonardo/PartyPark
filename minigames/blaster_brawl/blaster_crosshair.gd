class_name BlasterCrosshair
extends Control
## Fadenkreuz, Hitzebalken und Lebensanzeige einer Splitscreen-Ansicht in „Zerfetzung“.

var color: Color = Color.WHITE
## 0 bis 1; bei 1 überhitzt.
var heat: float = 0.0
var locked: bool = false
var lives: int = 3

var _hit_flash: float = 0.0


func flash_hit() -> void:
	_hit_flash = 1.0


func _process(delta: float) -> void:
	_hit_flash = maxf(0.0, _hit_flash - delta * 4.0)
	queue_redraw()


func _draw() -> void:
	var c: Vector2 = size * 0.5
	var gap: float = 8.0 + 6.0 * heat
	var length: float = 14.0
	var line_color: Color = Color(1, 0.3, 0.2) if locked else color
	for direction: Vector2 in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		draw_line(c + direction * gap, c + direction * (gap + length), Color(0, 0, 0, 0.6), 6.0)
		draw_line(c + direction * gap, c + direction * (gap + length), line_color, 3.0)
	draw_circle(c, 2.5, line_color)
	if _hit_flash > 0.0:
		# Treffermarke: kleines X
		var k: float = 10.0 + 6.0 * _hit_flash
		var hit_color := Color(1, 1, 1, _hit_flash)
		draw_line(c + Vector2(-k, -k), c + Vector2(-k * 0.4, -k * 0.4), hit_color, 3.0)
		draw_line(c + Vector2(k, -k), c + Vector2(k * 0.4, -k * 0.4), hit_color, 3.0)
		draw_line(c + Vector2(-k, k), c + Vector2(-k * 0.4, k * 0.4), hit_color, 3.0)
		draw_line(c + Vector2(k, k), c + Vector2(k * 0.4, k * 0.4), hit_color, 3.0)
	# Hitzebalken unten mittig
	var bar := Rect2(Vector2(c.x - 90.0, size.y - 46.0), Vector2(180.0, 14.0))
	draw_rect(bar, Color(0, 0, 0, 0.55))
	var fill_color: Color = Color(1, 0.3, 0.2) if locked else Color(1, 0.75, 0.2).lerp(Color(1, 0.3, 0.2), heat)
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * clampf(heat, 0.0, 1.0), bar.size.y)), fill_color)
	draw_rect(bar, Color(1, 1, 1, 0.7), false, 2.0)
	# Leben als Kreise oben rechts
	for i: int in 3:
		var spot := Vector2(size.x - 30.0 - 30.0 * i, 26.0)
		draw_circle(spot, 10.0, color if i < lives else Color(0.2, 0.2, 0.2, 0.6))
