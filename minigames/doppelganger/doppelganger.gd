extends Minigame
## Doppelgänger-Gewusel (P1), 1 gegen 3: Drei Doppelgänger tauchen in einer Menge gleich aussehender
## Parkbesucher unter und erledigen an der leuchtenden Bude Aufgaben (Aktion halten). Der Wächter steht
## mit Spielzeug-Blaster auf dem Hochsitz, schiebt ein Fadenkreuz und hat 3 Schüsse.
## D132 (nur Koop, kein Schubsen), D133 (Hochsitz, Fadenkreuz, 3 Schüsse), D136 (eigene Figur per Knopf
## aufblinken, der Wächter sieht es auch), D137 (4 Aufgaben in 90 s, gleiches Tempo wie die Besucher).
## Die Besucher sind echte Player-Figuren mit eigener KI-Quelle, damit Laufen, Wippen und Blinzeln
## exakt gleich aussehen. Sie stehen nicht in `players` und nicht in der Gruppe `players`.

const BLASTER_SCENE: PackedScene = preload("res://core/weapons/blaster_a.tscn")

@export_group("Regeln")
@export var round_time: float = 90.0
## So viele erledigte Aufgaben gewinnen für die Doppelgänger (gemeinsam).
@export var tasks_to_win: int = 4
## So lange muss die Aktionstaste an der aktiven Bude gehalten werden (Sekunden).
@export var task_time: float = 2.0
## Radius der Aufgabenfläche vor einer Bude (Meter).
@export var task_zone_radius: float = 1.7

@export_group("Menge")
@export var crowd_count: int = 32
## Lauftempo aller Figuren auf dem Platz (Besucher und Doppelgänger, D137).
@export var walk_speed: float = 2.6
## Farbe aller Besucher und Doppelgänger.
@export var crowd_color: Color = Color("#c9b79c")
## Anteil der Besucher-Entscheidungen, die zu einer Bude führen (davon die Hälfte zur aktiven).
@export var booth_visit_chance: float = 0.3

@export_group("Doppelgänger")
## Aufblinken in Spielerfarbe (D136): Dauer und Abklingzeit in Sekunden.
@export var blink_time: float = 0.7
@export var blink_cooldown: float = 2.5

@export_group("Wächter")
@export var shots: int = 3
@export var shot_cooldown: float = 1.5
## Tempo des Fadenkreuzes (m/s).
@export var crosshair_speed: float = 11.0
## So nah (waagerecht) muss eine Figur am Fadenkreuz stehen, um getroffen zu werden.
@export var hit_radius: float = 0.85
## Ein getroffener Besucher bleibt so lange liegen (Sekunden).
@export var visitor_down_time: float = 3.0

@export_group("Computer-Wächter")
## Ab diesem Verdacht zielt der Computer (sinkt mit der Stärke).
@export var ai_suspicion_threshold: float = 3.0

@export_group("Platz")
## Halbe Größe des Platzes (x = Breite, y = Tiefe).
@export var plaza_half: Vector2 = Vector2(13.5, 8.5)
@export var tower_height: float = 4.0

const BOOTH_COLORS: Array[Color] = [Color("#ff6b6b"), Color("#4fb3ff"), Color("#ffd75e"), Color("#7bd88f"), Color("#c18cff")]
const BOOTH_NAMES: Array[String] = ["Lose", "Ballons", "Eis", "Zuckerwatte", "Dosenwerfen"]

var guard: Player
var hiders: Array[Player] = []
var crowd: Array[Player] = []
var tasks_done: int = 0
var shots_left: int = 0
var eliminated: Array[int] = []
var active_booth: int = -1
var wasted_shots: int = 0

var _booth_spots: Array[Vector3] = []
var _booth_lamps: Array[MeshInstance3D] = []
var _booth_rings: Array[MeshInstance3D] = []
var _crosshair: Node3D
var _crosshair_pos: Vector3 = Vector3.ZERO
var _shot_ready_in: float = 0.0
var _blaster: Blaster
var _progress: Dictionary = {}
var _blink_left: Dictionary = {}
var _blink_ready_in: Dictionary = {}
var _down_left: Dictionary = {}
var _remove_at: Dictionary = {}
var _walker_state: Dictionary = {}
var _suspicion: Dictionary = {}
var _guard_think: float = 0.0
var _pulse: float = 0.0


func _init() -> void:
	time_limit = 90.0


# --- Aufbau ---

func _build_arena() -> void:
	super._build_arena()
	time_limit = round_time
	var w: float = plaza_half.x
	var d: float = plaza_half.y
	StageKit.add_box(self, Vector3(w * 2.0 + 2.0, 1.0, d * 2.0 + 2.0), Vector3(0, -0.5, 0), Color("#d8c3a0"), Vector3.ZERO, Look.Kind.GROUND)
	StageKit.add_box(self, Vector3(60, 1.0, 50), Vector3(0, -0.52, 0), Color("#6fbf5e"), Vector3.ZERO, Look.Kind.GRASS)
	# Zaun ringsum
	for side: int in 4:
		var horizontal: bool = side < 2
		var size := Vector3(w * 2.0 + 1.0, 1.0, 0.3) if horizontal else Vector3(0.3, 1.0, d * 2.0 + 1.0)
		var pos := Vector3(0, 0.5, (d + 0.6) * (1.0 if side == 0 else -1.0)) if horizontal else Vector3((w + 0.6) * (1.0 if side == 2 else -1.0), 0.5, 0)
		StageKit.add_box(self, size, pos, Color("#8a5a33"), Vector3.ZERO, Look.Kind.WOOD)
	_build_booths()
	_build_tower()
	_build_crosshair()
	var camera := Camera3D.new()
	camera.fov = 50.0
	add_child(camera)
	camera.position = Vector3(0, 21.0, 19.5)
	camera.look_at(Vector3(0, 0, -0.8), Vector3.UP)
	camera.current = true


func _build_booths() -> void:
	var spots: Array[Vector3] = [Vector3(-9.5, 0, -5.5), Vector3(9.5, 0, -5.5), Vector3(-9.5, 0, 5.0), Vector3(9.5, 0, 5.0), Vector3(0, 0, 1.5)]
	for i: int in spots.size():
		var base: Vector3 = spots[i]
		var color: Color = BOOTH_COLORS[i]
		# Bude steht hinter der Aufgabenfläche (zum Rand hin), Fläche zeigt zur Platzmitte
		var outward: Vector3 = Vector3(signf(base.x), 0, 0) if absf(base.x) > 0.5 else Vector3(0, 0, -1)
		var booth_pos: Vector3 = base + outward * 1.9
		StageKit.add_box(self, Vector3(2.4, 1.1, 2.4), booth_pos + Vector3(0, 0.55, 0), Color("#f4ead8"), Vector3.ZERO, Look.Kind.WOOD)
		var roof := StageKit.add_box(self, Vector3(2.8, 0.25, 2.8), booth_pos + Vector3(0, 2.3, 0), color, Vector3.ZERO, Look.Kind.FABRIC)
		roof.set_collision_layer_value(1, false)
		for corner: Vector2 in [Vector2(-1.1, -1.1), Vector2(1.1, -1.1), Vector2(-1.1, 1.1), Vector2(1.1, 1.1)]:
			var pole := StageKit.add_cylinder(self, 0.07, 1.2, booth_pos + Vector3(corner.x, 1.7, corner.y), Color("#8a5a33"), Look.Kind.WOOD)
			pole.set_collision_layer_value(1, false)
		var lamp := MeshInstance3D.new()
		var orb := SphereMesh.new()
		orb.radius = 0.35
		orb.height = 0.7
		lamp.mesh = orb
		lamp.material_override = Look.surface(color.darkened(0.3), Look.Kind.GLOSSY)
		lamp.position = booth_pos + Vector3(0, 2.8, 0)
		lamp.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(lamp)
		_booth_lamps.append(lamp)
		var board := Label3D.new()
		board.text = BOOTH_NAMES[i]
		board.font_size = 72
		board.outline_size = 14
		board.pixel_size = 0.006
		board.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		board.position = booth_pos + Vector3(0, 3.5, 0)
		board.modulate = color.lightened(0.4)
		add_child(board)
		var ring := MeshInstance3D.new()
		var torus := TorusMesh.new()
		torus.inner_radius = task_zone_radius - 0.12
		torus.outer_radius = task_zone_radius
		torus.rings = 40
		ring.mesh = torus
		ring.scale = Vector3(1.0, 0.15, 1.0)
		ring.position = base + Vector3(0, 0.03, 0)
		var ring_mat := StandardMaterial3D.new()
		ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ring_mat.albedo_color = color
		ring.material_override = ring_mat
		ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		ring.visible = false
		add_child(ring)
		_booth_rings.append(ring)
		_booth_spots.append(base)


func _build_tower() -> void:
	var at := Vector3(0, 0, -plaza_half.y - 2.2)
	for corner: Vector2 in [Vector2(-0.9, -0.9), Vector2(0.9, -0.9), Vector2(-0.9, 0.9), Vector2(0.9, 0.9)]:
		StageKit.add_cylinder(self, 0.15, tower_height, at + Vector3(corner.x, tower_height * 0.5, corner.y), Color("#8a5a33"), Look.Kind.WOOD)
	StageKit.add_box(self, Vector3(2.4, 0.3, 2.4), at + Vector3(0, tower_height, 0), Color("#a0703f"), Vector3.ZERO, Look.Kind.WOOD)
	StageKit.add_box(self, Vector3(2.4, 0.7, 0.15), at + Vector3(0, tower_height + 0.5, 1.15), Color("#a0703f"), Vector3.ZERO, Look.Kind.WOOD)


func _build_crosshair() -> void:
	_crosshair = Node3D.new()
	_crosshair.name = "Crosshair"
	add_child(_crosshair)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color("#ff3b3b")
	mat.no_depth_test = true
	mat.render_priority = 10
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = hit_radius - 0.12
	torus.outer_radius = hit_radius
	torus.rings = 32
	ring.mesh = torus
	ring.scale = Vector3(1.0, 0.1, 1.0)
	ring.material_override = mat
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_crosshair.add_child(ring)
	for k: int in 2:
		var bar := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.9, 0.04, 0.08) if k == 0 else Vector3(0.08, 0.04, 0.9)
		bar.mesh = box
		bar.material_override = mat
		bar.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_crosshair.add_child(bar)
	_crosshair.position = Vector3(0, 0.08, 0)


func _spawn_position(_i: int, slot: PlayerSlot) -> Vector3:
	if context.is_solo(slot.index):
		return Vector3(0, tower_height + 0.5, -plaza_half.y - 2.2)
	return _random_point()


func _spawn_facing(_i: int, slot: PlayerSlot) -> Vector3:
	if context.is_solo(slot.index):
		return Vector3.BACK
	return Vector3(rng.randf_range(-1, 1), 0, rng.randf_range(-1, 1)).normalized()


func _configure_player(player: Player, slot: PlayerSlot) -> void:
	player.push_ability.enabled = false
	player.jump_ability.enabled = false
	if context.is_solo(slot.index):
		guard = player
		player.movement_enabled = false
		_blaster = BLASTER_SCENE.instantiate() as Blaster
		player.visual.add_child(_blaster)
		_blaster.position = Vector3(0.45, 0.85, -0.35)
		_blaster.scale = Vector3.ONE * 1.6
		return
	hiders.append(player)
	# Doppelgänger sehen exakt aus wie Besucher: Neutralfarbe, kein Name, kein Teamring, kein Schatten
	player.set_team_ring(Color(0, 0, 0, 0))
	player.tag_label.visible = false
	player.visual.set_color(crowd_color)
	player.move_speed = walk_speed / Handicap.speed(player.handicap_level())
	_disable_shadows(player)
	_progress[slot.index] = 0.0
	_blink_ready_in[slot.index] = 0.0


func _after_setup() -> void:
	shots_left = shots
	for i: int in crowd_count:
		var slot := PlayerSlot.new(100 + i, crowd_color, "Besucher")
		slot.source = AIInput.new(100 + i)
		slot.is_cpu = true
		var walker := PLAYER_SCENE.instantiate() as Player
		walker.setup(slot)
		walker.name = "Visitor%d" % i
		add_child(walker)
		walker.remove_from_group(Player.GROUP)
		walker.respawn(_random_point())
		walker.face(Vector3(rng.randf_range(-1, 1), 0, rng.randf_range(-1, 1)).normalized())
		walker.push_ability.enabled = false
		walker.jump_ability.enabled = false
		walker.tag_label.visible = false
		walker.move_speed = walk_speed
		walker.controls_enabled = false
		_disable_shadows(walker)
		crowd.append(walker)
	_crosshair_pos = Vector3(0, 0, 0)
	_activate_booth(rng.randi_range(0, _booth_spots.size() - 1))
	_update_hud()


func _on_round_started() -> void:
	for walker: Player in crowd:
		walker.controls_enabled = true
	hud.show_message("Doppelgänger: %s lässt die eigene Figur kurz aufblinken" % InputHints.for_humans(InputBindings.SPECIAL), 2.5)


func _disable_shadows(node: Node) -> void:
	var geometry := node as GeometryInstance3D
	if geometry != null:
		geometry.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for child: Node in node.get_children():
		_disable_shadows(child)


func _random_point() -> Vector3:
	for attempt: int in 12:
		var p := Vector3(rng.randf_range(-plaza_half.x + 1.0, plaza_half.x - 1.0), 0.3, rng.randf_range(-plaza_half.y + 1.0, plaza_half.y - 1.0))
		var free: bool = true
		for spot: Vector3 in _booth_spots:
			var outward: Vector3 = Vector3(signf(spot.x), 0, 0) if absf(spot.x) > 0.5 else Vector3(0, 0, -1)
			if Vector2(p.x, p.z).distance_to(Vector2(spot.x + outward.x * 1.9, spot.z + outward.z * 1.9)) < 2.2:
				free = false
		if free:
			return p
	return Vector3(rng.randf_range(-4, 4), 0.3, rng.randf_range(-3, 3))


# --- Runde ---

func _physics_process(delta: float) -> void:
	_pulse += delta
	_update_visual_timers(delta)
	if running:
		for walker: Player in crowd:
			_update_walker(walker, walker.slot.source as AIInput, delta, false)
			walker.slot.source.poll()
	super._physics_process(delta)


func _round_process(delta: float) -> void:
	_shot_ready_in -= delta
	for index: int in _remove_at.keys():
		_remove_at[index] = float(_remove_at[index]) - delta
		if _remove_at[index] <= 0.0:
			_remove_at.erase(index)
			get_player(index).set_active(false)
	_handle_guard(delta)
	for hider: Player in hiders:
		if not eliminated.has(hider.slot.index):
			_handle_hider(hider, delta)
	_update_suspicion(delta)
	if tasks_done >= tasks_to_win:
		Fx.shake(Fx.SHAKE_MEDIUM)
		finish(MinigameResult.team_win(_hider_indices(), [guard.slot.index]))
	elif eliminated.size() >= hiders.size():
		finish(MinigameResult.team_win([guard.slot.index], _hider_indices()))


func _on_time_up() -> void:
	finish(MinigameResult.team_win([guard.slot.index], _hider_indices()))


func _handle_hider(hider: Player, delta: float) -> void:
	var index: int = hider.slot.index
	_blink_ready_in[index] = float(_blink_ready_in[index]) - delta
	var source: InputSource = hider.get_input()
	if source == null:
		return
	if source.just_pressed(InputBindings.SPECIAL) and float(_blink_ready_in[index]) <= 0.0:
		_blink(hider)
	var in_zone: bool = _in_zone(hider.global_position, active_booth)
	if in_zone and source.is_down(InputBindings.ACTION):
		_progress[index] = float(_progress[index]) + delta
		if Engine.get_physics_frames() % 20 == 0:
			source.rumble(0.15, 0.0, 0.05)
		if float(_progress[index]) >= task_time:
			_complete_task(hider)
	elif float(_progress[index]) > 0.0:
		_progress[index] = 0.0
	_update_status(hider.slot)


func _blink(hider: Player) -> void:
	var index: int = hider.slot.index
	_blink_ready_in[index] = blink_cooldown
	_blink_left[index] = blink_time
	hider.visual.set_color(hider.slot.color)
	_suspicion[hider] = float(_suspicion.get(hider, 0.0)) + 6.0


func _complete_task(hider: Player) -> void:
	tasks_done += 1
	for h: Player in hiders:
		_progress[h.slot.index] = 0.0
	var spot: Vector3 = _booth_spots[active_booth]
	Fx.burst(&"confetti", spot + Vector3.UP * 2.0, BOOTH_COLORS[active_booth], 1.0)
	Sfx.play(&"sparkle", spot)
	hider.get_input().rumble(0.3, 0.3, 0.2)
	# Der Wächter sieht, wer an der Bude stand: Verdacht für alle in der Fläche
	for figure: Player in _all_figures():
		if _in_zone(figure.global_position, active_booth):
			_suspicion[figure] = float(_suspicion.get(figure, 0.0)) + 3.0
	if tasks_done < tasks_to_win:
		hud.show_message("Aufgabe erledigt! Noch %d" % (tasks_to_win - tasks_done), 1.2)
		var next: int = active_booth
		while next == active_booth:
			next = rng.randi_range(0, _booth_spots.size() - 1)
		_activate_booth(next)
	_update_hud()


func _activate_booth(index: int) -> void:
	active_booth = index
	for i: int in _booth_spots.size():
		_booth_rings[i].visible = i == index
		var lamp_color: Color = BOOTH_COLORS[i]
		_booth_lamps[i].material_override = Look.glow_surface(lamp_color, 2.5) if i == index else Look.surface(lamp_color.darkened(0.3), Look.Kind.GLOSSY)


func _in_zone(pos: Vector3, booth: int) -> bool:
	if booth < 0:
		return false
	var spot: Vector3 = _booth_spots[booth]
	return Vector2(pos.x, pos.z).distance_to(Vector2(spot.x, spot.z)) <= task_zone_radius


func _handle_guard(delta: float) -> void:
	var source: InputSource = guard.get_input()
	var move: Vector2 = source.get_move() if source != null else Vector2.ZERO
	_crosshair_pos += Vector3(move.x, 0, move.y) * crosshair_speed * delta
	_crosshair_pos.x = clampf(_crosshair_pos.x, -plaza_half.x, plaza_half.x)
	_crosshair_pos.z = clampf(_crosshair_pos.z, -plaza_half.y, plaza_half.y)
	_crosshair.position = Vector3(_crosshair_pos.x, 0.08, _crosshair_pos.z)
	var look: Vector3 = _crosshair_pos - guard.global_position
	look.y = 0.0
	if look.length_squared() > 0.01:
		guard.face(look)
	if _blaster != null:
		_blaster.look_at(_crosshair_pos + Vector3.UP * 0.6, Vector3.UP)
	var wants_shot: bool = source != null and (source.just_pressed(InputBindings.JUMP) or source.just_pressed(InputBindings.TRIGGER))
	if wants_shot and _shot_ready_in <= 0.0 and shots_left > 0:
		_shoot()


func _shoot() -> void:
	shots_left -= 1
	_shot_ready_in = shot_cooldown
	var target: Player = null
	var best: float = hit_radius
	for figure: Player in _all_figures():
		if _down_left.has(figure):
			continue
		var d: float = Vector2(figure.global_position.x, figure.global_position.z).distance_to(Vector2(_crosshair_pos.x, _crosshair_pos.z))
		if d < best:
			best = d
			target = figure
	var muzzle: Vector3 = _blaster.get_muzzle_position() if _blaster != null else guard.global_position + Vector3.UP
	var impact: Vector3 = target.global_position + Vector3.UP * 0.6 if target != null else _crosshair_pos + Vector3.UP * 0.1
	if _blaster != null:
		_blaster.fire_effect()
	_tracer(muzzle, impact)
	Sfx.play(&"blaster", muzzle)
	if guard.get_input() != null:
		guard.get_input().rumble(0.3, 0.2, 0.12)
	if target == null:
		wasted_shots += 1
		Fx.burst(&"dust", impact, Color(0, 0, 0, 0), 0.8)
		hud.show_message("Daneben!", 1.2)
	elif hiders.has(target):
		_hit_hider(target)
	else:
		wasted_shots += 1
		_down_left[target] = visitor_down_time
		target.controls_enabled = false
		var tween: Tween = target.create_tween()
		tween.tween_property(target.visual, "rotation:x", -1.45, 0.35).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		Fx.burst(&"stars", impact, Color("#ffd75e"), 0.8)
		Sfx.play(&"bump", impact)
		hud.show_message("Nur ein Besucher!", 1.4)
	_suspicion.erase(target)
	_update_hud()


func _hit_hider(hider: Player) -> void:
	var index: int = hider.slot.index
	eliminated.append(index)
	_progress[index] = 0.0
	hider.visual.set_color(hider.slot.color)
	hider.tag_label.visible = true
	hider.visual.play_hit(Vector3(0, 0, 6))
	hider.controls_enabled = false
	Fx.hitstop([hider])
	Fx.shake(Fx.SHAKE_MEDIUM)
	Fx.burst(&"stars", hider.global_position + Vector3.UP, hider.slot.color, 1.3)
	Sfx.play(&"eliminated", hider.global_position)
	Announcer.say(&"bad_luck", {"player": hider.slot.display_name}, 0.7)
	if hider.get_input() != null:
		hider.get_input().rumble(0.6, 0.6, 0.3)
	_remove_at[index] = 1.2
	hud.show_message("Erwischt: %s" % hider.slot.display_name, 1.5)


func _tracer(from: Vector3, to: Vector3) -> void:
	var beam := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	var length: float = from.distance_to(to)
	cyl.top_radius = 0.05
	cyl.bottom_radius = 0.05
	cyl.height = length
	beam.mesh = cyl
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(1, 0.85, 0.3, 0.9)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam.material_override = mat
	beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(beam)
	beam.global_position = (from + to) * 0.5
	var dir: Vector3 = (to - from).normalized()
	if absf(dir.dot(Vector3.UP)) < 0.99:
		beam.look_at(to, Vector3.UP)
		beam.rotate_object_local(Vector3.RIGHT, -PI * 0.5)
	var tween: Tween = beam.create_tween()
	tween.tween_property(mat, "albedo_color:a", 0.0, 0.25)
	tween.tween_callback(beam.queue_free)


func _update_visual_timers(delta: float) -> void:
	for index: int in _blink_left.keys():
		_blink_left[index] = float(_blink_left[index]) - delta
		if _blink_left[index] <= 0.0:
			_blink_left.erase(index)
			var hider: Player = get_player(index)
			if hider != null and not eliminated.has(index):
				hider.visual.set_color(crowd_color)
	for walker: Player in _down_left.keys():
		_down_left[walker] = float(_down_left[walker]) - delta
		if _down_left[walker] <= 0.0:
			_down_left.erase(walker)
			walker.controls_enabled = true
			var tween: Tween = walker.create_tween()
			tween.tween_property(walker.visual, "rotation:x", 0.0, 0.3)
	if active_booth >= 0:
		var ring: MeshInstance3D = _booth_rings[active_booth]
		var s: float = 1.0 + sin(_pulse * 5.0) * 0.05
		ring.scale = Vector3(s, 0.15, s)


func _all_figures() -> Array[Player]:
	var result: Array[Player] = []
	for hider: Player in hiders:
		if not eliminated.has(hider.slot.index):
			result.append(hider)
	result.append_array(crowd)
	return result


func _hider_indices() -> Array[int]:
	var result: Array[int] = []
	for hider: Player in hiders:
		result.append(hider.slot.index)
	return result


func _update_status(slot: PlayerSlot) -> void:
	if eliminated.has(slot.index):
		hud.set_status(slot, "%s  erwischt" % slot.get_tag())
		return
	var p: float = float(_progress.get(slot.index, 0.0))
	if p > 0.0:
		hud.set_status(slot, "%s  Aufgabe %d %%" % [slot.get_tag(), roundi(p / task_time * 100.0)])
	else:
		hud.set_status(slot, "%s  versteckt" % slot.get_tag())


func _update_hud() -> void:
	hud.set_info("tasks", "Aufgaben %d / %d" % [tasks_done, tasks_to_win], Color("#ffd75e"))
	hud.set_info("shots", "Schüsse %d" % shots_left, Color("#ff6b6b"))
	for slot: PlayerSlot in context.slots:
		if context.is_solo(slot.index):
			hud.set_status(slot, "%s  Wächter" % slot.get_tag())
		else:
			_update_status(slot)


## Knapp: nur noch eine Aufgabe fehlte, oder das Team gewann mit nur einem Überlebenden.
func was_close() -> bool:
	if tasks_done >= tasks_to_win:
		return eliminated.size() >= hiders.size() - 1 or time_left() < 10.0
	return tasks_done >= tasks_to_win - 1


func debug_summary() -> String:
	return "Aufgaben %d/%d, erwischt %d, Fehlschüsse %d, Schüsse übrig %d" % [tasks_done, tasks_to_win, eliminated.size(), wasted_shots, shots_left]


# --- Besucher und Computer ---

func _update_ai(player: Player, ai: AIInput, delta: float) -> void:
	if player == guard:
		_ai_guard(ai, delta)
	elif not eliminated.has(player.slot.index):
		_update_walker(player, ai, delta, true)


## Läuft für Besucher und Computer-Doppelgänger gleich; Doppelgänger gehen öfter zur aktiven Bude
## und halten dort die Aktionstaste.
func _update_walker(walker: Player, ai: AIInput, delta: float, is_hider: bool) -> void:
	if _down_left.has(walker):
		ai.move = Vector2.ZERO
		return
	var state: Dictionary = _walker_state.get(walker, {})
	if state.is_empty():
		state = {"mode": "idle", "timer": rng.randf_range(0.2, 2.0), "target": walker.global_position, "speed": 1.0, "stuck": 0.0, "booth": -1}
	state["timer"] = float(state["timer"]) - delta
	var mode: String = state["mode"]
	if mode == "task":
		# Computer-Doppelgänger: an der aktiven Bude Aktion halten, bis erledigt oder die Bude wechselt
		ai.move = Vector2.ZERO
		var done: bool = int(state["booth"]) != active_booth or not _in_zone(walker.global_position, active_booth)
		if done or float(state["timer"]) <= 0.0:
			ai.hold(InputBindings.ACTION, false)
			_choose_walker_plan(state, is_hider)
		else:
			ai.hold(InputBindings.ACTION, true)
	elif mode == "idle" or mode == "linger":
		ai.move = Vector2.ZERO
		if float(state["timer"]) <= 0.0:
			_choose_walker_plan(state, is_hider)
	else:
		var target: Vector3 = state["target"]
		var to_target: Vector3 = target - walker.global_position
		to_target.y = 0.0
		if to_target.length() < 0.45:
			ai.move = Vector2.ZERO
			if int(state["booth"]) >= 0:
				var at_active: bool = is_hider and int(state["booth"]) == active_booth
				state["mode"] = "task" if at_active else "linger"
				state["timer"] = task_time + 0.6 if at_active else rng.randf_range(1.5, 3.5)
			else:
				state["mode"] = "idle"
				state["timer"] = rng.randf_range(0.5, 2.5)
		else:
			ai_steer_to(walker, ai, target, float(state["speed"]))
			var speed_now: float = Vector2(walker.velocity.x, walker.velocity.z).length()
			state["stuck"] = float(state["stuck"]) + delta if speed_now < 0.4 else 0.0
			if float(state["stuck"]) > 1.5 or float(state["timer"]) <= 0.0:
				_choose_walker_plan(state, is_hider)
	_walker_state[walker] = state


func _choose_walker_plan(state: Dictionary, is_hider: bool) -> void:
	state["stuck"] = 0.0
	state["booth"] = -1
	var r: float = rng.randf()
	var booth_chance: float = booth_visit_chance
	if is_hider:
		booth_chance = 0.25 + 0.45 * AIProfile.skill(context.difficulty)
	if r < booth_chance:
		var booth: int = active_booth
		if not is_hider and rng.randf() < 0.5:
			booth = rng.randi_range(0, _booth_spots.size() - 1)
		state["booth"] = booth
		var spot: Vector3 = _booth_spots[booth]
		var offset := Vector3(rng.randf_range(-1.0, 1.0), 0, rng.randf_range(-1.0, 1.0)).limit_length(task_zone_radius * 0.6)
		state["target"] = spot + offset
		state["mode"] = "walk"
		state["speed"] = 1.0
		state["timer"] = 12.0
	elif r < booth_chance + 0.45:
		state["target"] = _random_point()
		state["mode"] = "walk"
		state["speed"] = 1.0 if rng.randf() < 0.75 else 0.6
		state["timer"] = 10.0
	else:
		state["mode"] = "idle"
		state["timer"] = rng.randf_range(1.0, 3.5)


## Verdacht des Computer-Wächters: wer lange in der aktiven Fläche steht, wer aufblinkt (D136)
## und wer bei einer erledigten Aufgabe dort stand. Klingt langsam ab.
func _update_suspicion(delta: float) -> void:
	if guard == null or not guard.slot.is_cpu:
		return
	for figure: Player in _all_figures():
		var value: float = float(_suspicion.get(figure, 0.0))
		if _in_zone(figure.global_position, active_booth):
			value += delta * 0.6
		value = maxf(0.0, value - delta * 0.15)
		if value > 0.0:
			_suspicion[figure] = value
		else:
			_suspicion.erase(figure)


func _ai_guard(ai: AIInput, delta: float) -> void:
	_guard_think -= delta
	var target: Player = null
	var best: float = ai_suspicion_threshold * (1.3 - AIProfile.skill(context.difficulty) * 0.6)
	for figure: Player in _suspicion.keys():
		if not is_instance_valid(figure) or _down_left.has(figure) or eliminated.has(figure.slot.index):
			continue
		if float(_suspicion[figure]) > best:
			best = float(_suspicion[figure])
			target = figure
	var aim_at: Vector3 = _booth_spots[active_booth] if active_booth >= 0 else Vector3.ZERO
	if target != null:
		aim_at = target.global_position
	var to_aim: Vector3 = aim_at - _crosshair_pos
	to_aim.y = 0.0
	var dist: float = to_aim.length()
	ai.move = Vector2(to_aim.x, to_aim.z).normalized() * clampf(dist / 1.2, 0.0, 1.0) if dist > 0.15 else Vector2.ZERO
	if target != null and dist < 0.5 and _shot_ready_in <= 0.0 and _guard_think <= 0.0:
		_guard_think = AIProfile.reaction_time(context.difficulty)
		if rng.randf() < 0.35 + 0.5 * AIProfile.skill(context.difficulty):
			ai.tap(InputBindings.JUMP)
