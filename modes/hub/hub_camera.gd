class_name HubCamera
extends ArenaCamera
## Großraum-Kamera für den Freizeitpark-Hub (D99, D113, D114).
## Bietet sanfte Zoom-Grenzen, dynamische Turm-Höhenneigung und
## Offscreen-Indikator-Pfeile am Bildschirmrand für weit entfernte Spieler.

## Neigung am Boden und beim Klettern ganz oben (D114).
@export var base_pitch_deg: float = 50.0
@export var high_pitch_deg: float = 38.0
## Ab dieser Höhe des höchsten Spielers gilt die flache Neigung ganz.
@export var max_height_ref: float = 18.0
## Nähester und weitester Abstand (m). Mit der Leine im Hub (D121) reicht der Höchstwert für die Gruppe.
@export var hub_min_distance: float = 13.0
@export var hub_max_distance: float = 32.0
## Rand um die Figuren im Bild (m).
@export var hub_padding: float = 3.5

var _indicator_layer: CanvasLayer
var _indicators: Dictionary = {} # PlayerSlot -> Control


func _ready() -> void:
	pitch_deg = base_pitch_deg
	yaw_deg = 0.0
	min_distance = hub_min_distance
	max_distance = hub_max_distance
	padding = hub_padding
	follow_smoothing = 4.0
	zoom_smoothing = 2.5
	target_offset = Vector3(0.0, 1.0, 0.0)
	ignore_below_height = -5.0
	super._ready()
	_build_indicators_layer()


func _process(delta: float) -> void:
	if not current:
		if _indicator_layer != null and _indicator_layer.visible:
			_indicator_layer.visible = false
		return
	if _indicator_layer != null and not _indicator_layer.visible:
		_indicator_layer.visible = true

	super._process(delta)
	_update_offscreen_indicators()


func snap_to_targets() -> void:
	_update_camera(0.0, true)


func set_indicators_visible(val: bool) -> void:
	if _indicator_layer != null:
		_indicator_layer.visible = val


func _update_camera(delta: float, snap: bool) -> void:
	# Im Park gibt es nur menschliche Figuren (D124)
	var points: Array[Vector3] = []
	var highest_y: float = 0.0
	for node: Node in get_tree().get_nodes_in_group(target_group):
		var target := node as Node3D
		if target != null and target.is_inside_tree() and target.global_position.y > ignore_below_height:
			points.append(target.global_position)
			highest_y = maxf(highest_y, target.global_position.y)

	if points.is_empty():
		if snap:
			_place()
		return

	# Höhenabhängige Neigung (D114) anhand des höchsten Kletterers
	var height_factor: float = clampf(highest_y / max_height_ref, 0.0, 1.0)
	var target_pitch: float = lerpf(base_pitch_deg, high_pitch_deg, height_factor)
	if snap:
		pitch_deg = target_pitch
	else:
		pitch_deg = lerpf(pitch_deg, target_pitch, clampf(3.0 * delta, 0.0, 1.0))

	var bounds := AABB(points[0], Vector3.ZERO)
	for point: Vector3 in points:
		bounds = bounds.expand(point)

	var center: Vector3 = bounds.get_center() + target_offset
	var wanted: float = clampf(_distance_to_fit(bounds.size), min_distance, max_distance)

	if snap:
		_center = center
		_distance = wanted
		_initialized = true
	else:
		_center = _center.lerp(center, clampf(follow_smoothing * delta, 0.0, 1.0))
		_distance = lerpf(_distance, wanted, clampf(zoom_smoothing * delta, 0.0, 1.0))

	_place()


## Abstand, bei dem eine Gruppe der Ausdehnung `size` samt Rand ins Bild passt.
## Breite → waagerechter Bildwinkel, Tiefe und Höhe (Klettern!) → senkrechter Bildwinkel.
## Vorher zählte nur die Diagonale am Boden: Wer auf dem Turm stand, fiel oben aus dem Bild.
func _distance_to_fit(size: Vector3) -> float:
	var pitch: float = deg_to_rad(pitch_deg)
	var vp: Vector2 = get_viewport().get_visible_rect().size
	var aspect: float = vp.x / maxf(vp.y, 1.0)
	var half_v: float = deg_to_rad(fov) * 0.5
	var half_h: float = atan(tan(half_v) * aspect)
	var screen_width: float = size.x * 0.5 + padding
	var screen_height: float = (size.z * sin(pitch) + size.y * cos(pitch)) * 0.5 + padding
	return maxf(screen_width / tan(half_h), screen_height / tan(half_v))


func _build_indicators_layer() -> void:
	_indicator_layer = CanvasLayer.new()
	_indicator_layer.name = "OffscreenIndicators"
	_indicator_layer.layer = 25
	add_child(_indicator_layer)


func _update_offscreen_indicators() -> void:
	if not current or not is_inside_tree() or _indicator_layer == null or not _indicator_layer.visible:
		return

	var vp_rect: Rect2 = get_viewport().get_visible_rect()
	var vp_size: Vector2 = vp_rect.size
	var margin: float = 48.0
	var vp_center: Vector2 = vp_size * 0.5

	var players_in_tree: Array[Node] = get_tree().get_nodes_in_group(target_group)
	for node: Node in players_in_tree:
		var player := node as Player
		if player == null or player.slot == null or not player.visible:
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
			var scale_x: float = absf(max_x / dir.x) if absf(dir.x) > 0.001 else 99999.0
			var scale_y: float = absf(max_y / dir.y) if absf(dir.y) > 0.001 else 99999.0
			var scale_factor: float = minf(scale_x, scale_y)
			var edge_p: Vector2 = vp_center + dir * scale_factor

			indicator.position = edge_p
			var arrow: Node2D = indicator.get_node_or_null("Arrow") as Node2D
			if arrow != null:
				arrow.rotation = dir.angle()

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
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_indicator_layer.add_child(root)

	var arrow := Polygon2D.new()
	arrow.name = "Arrow"
	arrow.polygon = PackedVector2Array([
		Vector2(18.0, 0.0),
		Vector2(-10.0, -10.0),
		Vector2(-4.0, 0.0),
		Vector2(-10.0, 10.0),
	])
	arrow.color = slot.color
	root.add_child(arrow)

	var lbl := Label.new()
	lbl.name = "Label"
	lbl.text = "P%d" % (slot.index + 1)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.add_theme_color_override("font_outline_color", Color("#111111"))
	lbl.add_theme_constant_override("outline_size", 4)
	lbl.position = Vector2(-30, -32)
	lbl.size = Vector2(60, 24)
	root.add_child(lbl)

	_indicators[slot] = root
