extends Minigame
## Riese gegen Zwerge (D36), 1 gegen 3: Der Riese stampft Schockwellen, die Zwerge wickeln ihn durch
## volle Runden eng um ihn herum mit Seilen ein. 5 Seile: Riese fällt. Riese gewinnt nach Zeitablauf
## oder wenn alle Zwerge raus sind.

@export_group("Riese")
@export var giant_scale: float = 3.0
@export var giant_speed: float = 4.2
## Verlangsamung pro Seil (Anteil).
@export var rope_slowdown: float = 0.1
## Ausholzeit vor der Schockwelle (Sekunden).
@export var stomp_windup: float = 0.4
@export var stomp_radius: float = 5.0
@export var stomp_cooldown: float = 1.3
@export var stomp_strength: float = 14.0
@export var stomp_stun: float = 1.2
@export var shake_cooldown: float = 6.0

@export_group("Zwerge")
## Treffer, bis ein Zwerg raus ist.
@export var dwarf_hits: int = 2
@export var invulnerable_time: float = 1.5
## Wie nah ein Zwerg am Riesen laufen muss, damit seine Runde zählt (Meter ab Riesenmitte).
@export var wrap_radius: float = 4.3
@export var ropes_to_win: int = 5

@export_group("Arena")
@export var arena_radius: float = 14.0

var giant: Player
var ropes: int = 0
var hits_left: Dictionary = {}
var out: Array[int] = []

var _windup: float = -1.0
var _windup_id: int = 0
var _stomp_ready_in: float = 0.0
var _shake_ready_in: float = 0.0
var _invulnerable: Dictionary = {}
var _remove_at: Dictionary = {}
var _wrap_progress: Dictionary = {}
var _last_angle: Dictionary = {}
var _rope_rings: Array[MeshInstance3D] = []
var _shockwave: MeshInstance3D
var _shock_time: float = -1.0
var _ai_state: Dictionary = {}


func _init() -> void:
	time_limit = 75.0


func _build_arena() -> void:
	super._build_arena()
	StageKit.add_cylinder(self, arena_radius, 1.0, Vector3(0, -0.5, 0), Color("#6fbf5e"))
	var segments: int = 40
	for i: int in segments:
		var angle: float = TAU * float(i) / float(segments)
		var radius: float = arena_radius - 0.2
		var length: float = TAU * radius / float(segments) + 0.05
		var fence: StaticBody3D = StageKit.add_box(self, Vector3(length, 1.4, 0.35), Vector3(sin(angle) * radius, 0.7, cos(angle) * radius), Color("#8a5a33"))
		fence.rotation.y = angle
	# Ein paar Felsen als Deckung
	for spot: Vector3 in [Vector3(-7, 0.5, -4), Vector3(7, 0.5, -3), Vector3(0, 0.5, 8)]:
		StageKit.add_cylinder(self, 0.9, 1.0, spot, Color("#9aa3ad"))
	_shockwave = MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.9
	torus.outer_radius = 1.0
	torus.rings = 48
	_shockwave.mesh = torus
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1, 0.95, 0.7, 0.8)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_shockwave.material_override = material
	_shockwave.visible = false
	add_child(_shockwave)
	var camera := ArenaCamera.new()
	# Steiler Blick von oben, damit die Zwerge hinter dem Riesen nicht verschwinden
	camera.min_distance = 21.0
	camera.max_distance = 32.0
	camera.pitch_deg = 70.0
	add_child(camera)
	camera.current = true


func _spawn_position(i: int, slot: PlayerSlot) -> Vector3:
	if context.is_solo(slot.index):
		return Vector3(0, 0.3, -2)
	var angle: float = deg_to_rad(-50.0 + 50.0 * float(i % 3))
	return Vector3(sin(angle) * 8.0, 0.3, cos(angle) * 8.0)


func _configure_player(player: Player, slot: PlayerSlot) -> void:
	player.push_ability.enabled = false
	if context.is_solo(slot.index):
		giant = player
		player.set_body_scale(giant_scale)
		player.move_speed = giant_speed
		player.jump_ability.enabled = false
		player.turn_speed = 8.0
	else:
		hits_left[slot.index] = dwarf_hits
		player.move_speed = 7.5


func _after_setup() -> void:
	for i: int in ropes_to_win:
		var ring := MeshInstance3D.new()
		var torus := TorusMesh.new()
		torus.inner_radius = 1.3
		torus.outer_radius = 1.55
		ring.mesh = torus
		ring.position.y = 0.9 + 0.45 * float(i)
		ring.material_override = StageKit.make_material(Color("#d9b77a"))
		ring.visible = false
		giant.add_child(ring)
		_rope_rings.append(ring)
	_update_hud()


func _round_process(delta: float) -> void:
	_stomp_ready_in -= delta
	_shake_ready_in -= delta
	for index: int in _invulnerable.keys():
		_invulnerable[index] = float(_invulnerable[index]) - delta
		if _invulnerable[index] <= 0.0:
			_invulnerable.erase(index)
	for index: int in _remove_at.keys():
		_remove_at[index] = float(_remove_at[index]) - delta
		if _remove_at[index] <= 0.0:
			_remove_at.erase(index)
			get_player(index).set_active(false)
	_handle_giant_input(delta)
	_update_wraps(delta)
	_update_shockwave(delta)
	giant.move_speed = giant_speed * maxf(0.3, 1.0 - rope_slowdown * float(ropes))
	if ropes >= ropes_to_win:
		_giant_falls()
	elif out.size() >= context.slots.size() - 1:
		finish(MinigameResult.team_win([giant.slot.index], _dwarf_indices()))


func _handle_giant_input(delta: float) -> void:
	var source: InputSource = giant.get_input()
	if _windup >= 0.0:
		_windup -= delta
		if _windup < 0.0:
			_do_stomp()
	elif source != null and source.just_pressed(InputBindings.JUMP) and _stomp_ready_in <= 0.0:
		_windup = stomp_windup
		_windup_id += 1
		giant.visual.play_jump()
		giant.stun(stomp_windup)
	if source != null and source.just_pressed(InputBindings.SPECIAL) and ropes > 0 and _shake_ready_in <= 0.0:
		ropes -= 1
		_shake_ready_in = shake_cooldown
		giant.visual.play_hit(Vector3(8, 0, 0))
		source.rumble(0.4, 0.4, 0.3)
		hud.show_message("Seil abgeschüttelt!", 1.0)
		_update_hud()


func _do_stomp() -> void:
	_stomp_ready_in = stomp_cooldown
	giant.visual.play_land(20.0)
	_shock_time = 0.0
	_shockwave.visible = true
	_shockwave.global_position = Vector3(giant.global_position.x, 0.15, giant.global_position.z)
	var giant_source: InputSource = giant.slot.source
	giant_source.rumble(0.6, 0.8, 0.25)
	for index: int in _dwarf_indices():
		if out.has(index):
			continue
		var dwarf: Player = get_player(index)
		var offset: Vector3 = dwarf.global_position - giant.global_position
		offset.y = 0.0
		var distance: float = offset.length()
		dwarf.slot.source.rumble(0.3, 0.0, 0.15)
		if distance > stomp_radius or not dwarf.is_on_floor() or _invulnerable.has(index):
			continue
		var direction: Vector3 = offset.normalized() if distance > 0.01 else Vector3.BACK
		dwarf.receive_push(direction * stomp_strength, 7.0, stomp_stun, giant)
		hits_left[index] = int(hits_left[index]) - 1
		_invulnerable[index] = invulnerable_time
		_wrap_progress[index] = 0.0
		if hits_left[index] <= 0:
			out.append(index)
			_remove_at[index] = 0.8
			hud.show_message("%s ist raus!" % dwarf.slot.display_name, 1.5)
	_update_hud()


func _update_shockwave(delta: float) -> void:
	if _shock_time < 0.0:
		return
	_shock_time += delta
	var t: float = _shock_time / 0.35
	var radius: float = lerpf(0.5, stomp_radius, clampf(t, 0.0, 1.0))
	_shockwave.scale = Vector3(radius, 1.0, radius)
	if t >= 1.2:
		_shockwave.visible = false
		_shock_time = -1.0


func _update_wraps(delta: float) -> void:
	for index: int in _dwarf_indices():
		if out.has(index):
			continue
		var dwarf: Player = get_player(index)
		var offset: Vector3 = dwarf.global_position - giant.global_position
		offset.y = 0.0
		var progress: float = float(_wrap_progress.get(index, 0.0))
		if offset.length() <= wrap_radius and not dwarf.is_stunned():
			var angle: float = atan2(offset.x, offset.z)
			if _last_angle.has(index):
				progress += wrapf(angle - float(_last_angle[index]), -PI, PI)
			_last_angle[index] = angle
			if absf(progress) >= TAU:
				progress = 0.0
				ropes += 1
				dwarf.slot.source.rumble(0.5, 0.0, 0.15)
				hud.show_message("Seil %d von %d!" % [ropes, ropes_to_win], 1.0)
				_update_hud()
		else:
			_last_angle.erase(index)
			progress = move_toward(progress, 0.0, delta * 1.5)
		_wrap_progress[index] = progress


func _giant_falls() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(giant.visual, "rotation:x", -1.4, 0.8).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	giant.slot.source.rumble(1.0, 1.0, 0.5)
	finish(MinigameResult.team_win(_dwarf_indices(), [giant.slot.index]))


func _on_time_up() -> void:
	finish(MinigameResult.team_win([giant.slot.index], _dwarf_indices()))


func _dwarf_indices() -> Array[int]:
	var result: Array[int] = []
	for slot: PlayerSlot in context.slots:
		if not context.is_solo(slot.index):
			result.append(slot.index)
	return result


func _update_hud() -> void:
	for i: int in _rope_rings.size():
		_rope_rings[i].visible = i < ropes
	hud.set_info("ropes", "Seile %d / %d" % [ropes, ropes_to_win], Color("#d9b77a"))
	for slot: PlayerSlot in context.slots:
		if context.is_solo(slot.index):
			hud.set_status(slot, "%s  Riese" % slot.get_tag())
		else:
			var left: int = int(hits_left.get(slot.index, 0))
			hud.set_status(slot, "%s  %s" % [slot.get_tag(), ("Leben %d" % left) if left > 0 else "raus"])


# --- Computergegner ---

func _update_ai(player: Player, ai: AIInput, delta: float) -> void:
	# Alle Zwerge kreisen in dieselbe Richtung (sonst blockieren sie sich), jeder auf eigenem Radius.
	var lane: int = maxi(0, context.team_members(context.team_of(player.slot.index)).find(player.slot.index))
	var state: Dictionary = _ai_state.get(player.slot.index, {"think": 0.0, "orbit": 1.0, "jumped": -1, "radius": 2.6 + 0.55 * float(lane), "stuck": 0.0})
	state["think"] = float(state["think"]) - delta
	if player == giant:
		_ai_giant(player, ai, state)
	else:
		_ai_dwarf(player, ai, state)
	_ai_state[player.slot.index] = state


func _ai_giant(player: Player, ai: AIInput, state: Dictionary) -> void:
	var target: Player = null
	var best: float = INF
	var near_count: int = 0
	for index: int in _dwarf_indices():
		if out.has(index):
			continue
		var dwarf: Player = get_player(index)
		var d: float = dwarf.global_position.distance_to(player.global_position)
		if d < best:
			best = d
			target = dwarf
		if d < stomp_radius * 0.85 and dwarf.is_on_floor():
			near_count += 1
	if target != null:
		ai_steer_to(player, ai, target.global_position, AIProfile.speed(context.difficulty))
	if float(state["think"]) <= 0.0:
		state["think"] = AIProfile.reaction_time(context.difficulty)
		if near_count > 0 and _stomp_ready_in <= 0.0 and _windup < 0.0 and rng.randf() < AIProfile.skill(context.difficulty):
			ai.tap(InputBindings.JUMP)
		elif ropes >= 2 and _shake_ready_in <= 0.0 and rng.randf() < AIProfile.skill(context.difficulty):
			ai.tap(InputBindings.SPECIAL)


func _ai_dwarf(player: Player, ai: AIInput, state: Dictionary) -> void:
	var offset: Vector3 = player.global_position - giant.global_position
	offset.y = 0.0
	var distance: float = offset.length()
	var radial: Vector3 = offset.normalized() if distance > 0.01 else Vector3.BACK
	var tangent: Vector3 = Vector3.UP.cross(radial) * float(state["orbit"])
	var desired: float = float(state["radius"])
	var direction: Vector3 = tangent + radial * clampf((desired - distance) * 0.8, -1.0, 1.0)
	if distance > 8.0:
		direction = -radial
	# Festgefahren (z. B. an einem Felsen): Richtung wechseln
	var speed_now: float = Vector2(player.velocity.x, player.velocity.z).length()
	state["stuck"] = float(state["stuck"]) + get_physics_process_delta_time() if speed_now < 0.5 and not player.is_stunned() else 0.0
	if float(state["stuck"]) > 1.2:
		state["orbit"] = -float(state["orbit"])
		state["stuck"] = 0.0
	ai.move = player.world_to_input(direction.normalized()) * AIProfile.speed(context.difficulty)
	# Über die Schockwelle springen
	if _windup >= 0.0 and _windup <= 0.25 and int(state["jumped"]) != _windup_id and distance < stomp_radius + 0.5:
		state["jumped"] = _windup_id
		if rng.randf() < AIProfile.skill(context.difficulty):
			ai.tap(InputBindings.JUMP)
