class_name HubCamera
extends ArenaCamera
## Großraum-Kamera für den Freizeitpark-Hub (D99, D113, D114).
## Bietet sanfte Zoom-Grenzen, dynamische Turm-Höhenneigung und
## Offscreen-Indikator-Pfeile am Bildschirmrand für weit entfernte Spieler.

@export var base_pitch_deg: float = 48.0
@export var high_pitch_deg: float = 38.0
@export var max_height_ref: float = 18.0

var _indicator_layer: CanvasLayer
var _indicators: Dictionary = {} # PlayerSlot -> Control


func _ready() -> void:
	pitch_deg = base_pitch_deg
	yaw_deg = 0.0
	min_distance = 14.0
	max_distance = 46.0
	padding = 5.0
	follow_smoothing = 4.0
	zoom_smoothing = 2.5
	target_offset = Vector3(0.0, 1.2, 0.0)
	ignore_below_height = -5.0
	super._ready()
	_build_indicators_layer()


func _process(delta: float) -> void:
	# Höhenabhängige Neigung (D114)
	var height_factor: float = clampf(_center.y / max_height_ref, 0.0, 1.0)
	var target_pitch: float = lerpf(base_pitch_deg, high_pitch_deg, height_factor)
	pitch_deg = lerpf(pitch_deg, target_pitch, clampf(3.0 * delta, 0.0, 1.0))

	super._process(delta)
	_update_offscreen_indicators()


func _build_indicators_layer() -> void:
	_indicator_layer = CanvasLayer.new()
	_indicator_layer.name = "OffscreenIndicators"
	_indicator_layer.layer = 25
	add_child(_indicator_layer)


func _update_offscreen_indicators() -> void:
	if not current or not is_inside_tree():
		return

	var vp_rect: Rect2 = get_viewport().get_visible_rect()
	var vp_size: Vector2 = vp_rect.size
	var margin: float = 48.0
	var vp_center: Vector2 = vp_size * 0.5

	var players: Array[Node] = get_tree().get_nodes_in_group(target_group)
	for node: Node in players:
		var player := node as Player
		if player == null or player.slot == null:
			continue

		var slot: PlayerSlot = player.slot
		if not _indicators.has(slot):
			_create_indicator_for_slot(slot)

		var indicator: Control = _indicators[slot]
		var player_pos: Vector3 = player.global_position + Vector3(0, 1.0, 0)
		var is_behind: bool = is_position_behind(player_pos)
		var screen_p: Vector2 = unproject_position(player_pos)

		var is_offscreen: bool = is_behind or screen_p.x < margin or screen_p.x > vp_size.x - margin or screen_p.y < margin or screen_p.y > vp_size.y - margin

		if is_offscreen:
			indicator.visible = true
			var dir: Vector2 = (screen_p - vp_center)
			if is_behind:
				dir = -dir
			if dir.length_squared() < 0.001:
				dir = Vector2.UP
			dir = dir.normalized()

			# Schnittpunkt mit Viewport-Rand (mit Margin)
			var max_x: float = vp_center.x - margin
			var max_y: float = vp_center.y - margin
			var scale_factor: float = minf(absf(max_x / dir.x) if absf(dir.x) > 0.001 else 9999.0, absf(max_y / dir.y) if absf(dir.y) > 0.001 else 9999.0)
			var edge_p: Vector2 = vp_center + dir * scale_factor

			indicator.position = edge_p
			indicator.rotation = dir.angle()

			var dist: float = global_position.distance_to(player.global_position)
			var lbl: Label = indicator.get_node_or_null("Label") as Label
			if lbl != null:
				lbl.text = "P%d\n%dm" % [slot.index + 1, int(dist)]
		else:
			indicator.visible = false


func _create_indicator_for_slot(slot: PlayerSlot) -> void:
	var root := Control.new()
	root.name = "Indicator_P%d" % (slot.index + 1)
	root.visible = false
	_indicator_layer.add_child(root)

	# Bunter Pfeil
	var arrow := Polygon2D.new()
	arrow.polygon = PackedVector2Array([
		Vector2(20.0, 0.0),
		Vector2(-12.0, -12.0),
		Vector2(-4.0, 0.0),
		Vector2(-12.0, 12.0),
	])
	arrow.color = slot.color
	root.add_child(arrow)

	# Entfernungs- und Namenslabel (immer aufrecht lesen)
	var lbl := Label.new()
	lbl.name = "Label"
	lbl.text = "P%d" % (slot.index + 1)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.add_theme_color_override("font_outline_color", Color("#111111"))
	lbl.add_theme_constant_override("outline_size", 4)
	lbl.position = Vector2(-24, -36)
	root.add_child(lbl)

	_indicators[slot] = root
