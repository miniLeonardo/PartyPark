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

@export_group("Seile (Optik, D52)")
## Abstand der Seilringe von der Riesenmitte (Meter, Körper hat ca. 1,35 m Radius).
@export var rope_ring_radius: float = 1.62
@export var rope_thickness: float = 0.16
@export var rope_color: Color = Color("#d9b77a")

@export_group("Computer-Zwerge (D58)")
## So lange wickelt ein Computer-Zwerg am Stück (Sekunden, zufällig zwischen den Werten).
@export var ai_wrap_burst_min: float = 5.0
@export var ai_wrap_burst_max: float = 8.0
## Danach Pause in sicherem Abstand (Sekunden, mittlere Stärke; leicht länger, schwer kürzer).
@export var ai_rest_min: float = 0.6
@export var ai_rest_max: float = 1.5
@export var ai_rest_radius: float = 8.0

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
## Platzindex → RopeTube des Seils, das ein Zwerg gerade wickelt.
var _wrap_ropes: Dictionary = {}
var _debug_ropes_drawn: int = 0
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
		torus.inner_radius = rope_ring_radius - rope_thickness
		torus.outer_radius = rope_ring_radius + rope_thickness
		torus.rings = 40
		ring.mesh = torus
		ring.position.y = _rope_height(i)
		ring.material_override = StageKit.make_material(rope_color)
		ring.visible = false
		giant.add_child(ring)
		_rope_rings.append(ring)
	for index: int in _dwarf_indices():
		var tube := RopeTube.new()
		tube.thickness = rope_thickness * 0.8
		tube.color = rope_color
		tube.visible = false
		add_child(tube)
		_wrap_ropes[index] = tube
	_update_hud()


## Höhe des i-ten Seilrings am Riesen (lokal, unskaliert).
func _rope_height(i: int) -> float:
	return 0.9 + 0.45 * float(i)


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
		_fling_ring(ropes)
		_shake_ready_in = shake_cooldown
		giant.visual.play_hit(Vector3(8, 0, 0))
		source.rumble(0.4, 0.4, 0.3)
		hud.show_message("Seil abgeschüttelt!", 1.0)
		_update_hud()


func _do_stomp() -> void:
	_stomp_ready_in = stomp_cooldown
	Fx.shake(Fx.SHAKE_MEDIUM)
	Sfx.play(&"stomp", giant.global_position)
	Fx.burst(&"dust_ring", Vector3(giant.global_position.x, 0.2, giant.global_position.z))
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
		Fx.hitstop([dwarf, giant])
		Fx.burst(&"stars", dwarf.global_position + Vector3.UP * 1.0)
		hits_left[index] = int(hits_left[index]) - 1
		_invulnerable[index] = invulnerable_time
		_wrap_progress[index] = 0.0
		if hits_left[index] <= 0:
			out.append(index)
			_remove_at[index] = 0.8
			hud.show_message("%s ist raus!" % dwarf.slot.display_name, 1.5)
			Fx.shake(Fx.SHAKE_STRONG)
			Sfx.play(&"eliminated", dwarf.global_position)
			Announcer.say(&"bad_luck", {"player": dwarf.slot.display_name}, 0.6)
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
			_draw_wrap_rope(index, 0.0, 0.0, null)
			continue
		var dwarf: Player = get_player(index)
		var offset: Vector3 = dwarf.global_position - giant.global_position
		offset.y = 0.0
		var angle: float = atan2(offset.x, offset.z)
		var progress: float = float(_wrap_progress.get(index, 0.0))
		if offset.length() <= wrap_radius and not dwarf.is_stunned():
			if _last_angle.has(index):
				progress += wrapf(angle - float(_last_angle[index]), -PI, PI)
			_last_angle[index] = angle
			# Leises Surren bei jeder Vierteldrehung, Tonhöhe steigt mit dem Fortschritt
			if floori(absf(progress) / (PI * 0.5)) > floori(absf(float(_wrap_progress.get(index, 0.0))) / (PI * 0.5)):
				Sfx.play(&"rope_wrap", dwarf.global_position, -6.0, 0.8 + absf(progress) / TAU * 0.6)
			if absf(progress) >= TAU:
				progress = 0.0
				ropes += 1
				_pop_ring(ropes - 1)
				dwarf.slot.source.rumble(0.5, 0.0, 0.15)
				hud.show_message("Seil %d von %d!" % [ropes, ropes_to_win], 1.0)
				_update_hud()
		else:
			_last_angle.erase(index)
			progress = move_toward(progress, 0.0, delta * 1.5)
		_wrap_progress[index] = progress
		_draw_wrap_rope(index, angle, progress, dwarf if offset.length() <= wrap_radius * 1.5 else null)


## Zeichnet das Seil, das ein Zwerg gerade um den Riesen legt (D52): Bogen um den Körper
## über den bisher umrundeten Winkel, dazu das Stück vom Bogenende zur Hand des Zwergs.
func _draw_wrap_rope(index: int, angle: float, progress: float, dwarf: Player) -> void:
	var tube: RopeTube = _wrap_ropes.get(index)
	if tube == null:
		return
	if absf(progress) < 0.05:
		tube.set_points(PackedVector3Array())
		return
	var center: Vector3 = giant.global_position
	var height: float = _rope_height(mini(ropes, ropes_to_win - 1))
	var radius: float = rope_ring_radius
	var points := PackedVector3Array()
	var steps: int = maxi(2, ceili(absf(progress) / 0.12))
	for s: int in steps + 1:
		var a: float = angle - progress + progress * float(s) / float(steps)
		points.append(center + Vector3(sin(a) * radius, height, cos(a) * radius))
	if dwarf != null:
		var hand: Vector3 = dwarf.global_position + Vector3.UP * 0.6
		var start: Vector3 = points[points.size() - 1]
		for s: int in range(1, 5):
			var t: float = float(s) / 4.0
			var p: Vector3 = start.lerp(hand, t)
			p.y -= sin(t * PI) * 0.25
			points.append(p)
	tube.set_points(points)
	_debug_ropes_drawn += 1


## Neues Seil: Ring erscheint mit kleinem Aufploppen.
func _pop_ring(i: int) -> void:
	if i < 0 or i >= _rope_rings.size():
		return
	var ring: MeshInstance3D = _rope_rings[i]
	ring.visible = true
	ring.scale = Vector3.ONE * 1.35
	Fx.burst(&"stars", ring.global_position, rope_color.lightened(0.3))
	Sfx.play(&"rope_done", ring.global_position)
	var tween: Tween = create_tween()
	tween.tween_property(ring, "scale", Vector3.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Abgeschütteltes Seil: eine Kopie des Rings fliegt nach oben weg und schrumpft.
func _fling_ring(i: int) -> void:
	if i < 0 or i >= _rope_rings.size():
		return
	var ring: MeshInstance3D = _rope_rings[i]
	var copy := MeshInstance3D.new()
	copy.mesh = ring.mesh
	copy.material_override = ring.material_override
	add_child(copy)
	copy.global_transform = ring.global_transform
	Fx.burst(&"dust", ring.global_position, rope_color, 1.3)
	Sfx.play(&"rope_shake", ring.global_position)
	var side := Vector3(rng.randf_range(-1.0, 1.0), 0.0, rng.randf_range(-1.0, 1.0)).normalized()
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(copy, "global_position", copy.global_position + side * 4.0 + Vector3.UP * 3.0, 0.7).set_ease(Tween.EASE_OUT)
	tween.tween_property(copy, "rotation", Vector3(rng.randf_range(1.0, 2.5), 0.0, rng.randf_range(-2.0, 2.0)), 0.7)
	tween.tween_property(copy, "scale", Vector3.ONE * 0.2, 0.7).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(copy.queue_free)


## Knapp: Riese gewinnt mit nur noch einem fehlenden Seil, oder Zwerge gewinnen kurz vor Schluss bzw. zu einem.
func was_close() -> bool:
	if ropes >= ropes_to_win:
		return time_left() < 10.0 or out.size() >= context.slots.size() - 2
	return ropes >= ropes_to_win - 1


## Für den Smoke-Test `--smoke-games`.
func debug_summary() -> String:
	return "Seile %d, Zwerge raus %d, Seilteile sichtbar %d" % [ropes, out.size(), _debug_ropes_drawn]


func _giant_falls() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(giant.visual, "rotation:x", -1.4, 0.8).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	giant.slot.source.rumble(1.0, 1.0, 0.5)
	Fx.shake(Fx.SHAKE_STRONG)
	Sfx.play(&"giant_fall", giant.global_position)
	Fx.burst(&"dust_ring", Vector3(giant.global_position.x, 0.2, giant.global_position.z), Color(0, 0, 0, 0), 1.5)
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
	var dt: float = get_physics_process_delta_time()
	# D58: abwechselnd wickeln und in sicherem Abstand verschnaufen
	if not state.has("mode"):
		state["mode"] = "wrap"
		state["mode_time"] = rng.randf_range(ai_wrap_burst_min, ai_wrap_burst_max)
	state["mode_time"] = float(state["mode_time"]) - dt
	if float(state["mode_time"]) <= 0.0:
		if state["mode"] == "wrap":
			state["mode"] = "rest"
			var factor: float = 1.6 - AIProfile.skill(context.difficulty) * 0.85
			state["mode_time"] = rng.randf_range(ai_rest_min, ai_rest_max) * factor
		else:
			state["mode"] = "wrap"
			state["mode_time"] = rng.randf_range(ai_wrap_burst_min, ai_wrap_burst_max)
	var desired: float = float(state["radius"]) if state["mode"] == "wrap" else ai_rest_radius
	var direction: Vector3 = tangent + radial * clampf((desired - distance) * 0.8, -1.0, 1.0)
	if state["mode"] == "rest" and distance < ai_rest_radius - 1.0:
		# Beim Verschnaufen Abstand halten: eher weg vom Riesen als um ihn herum
		direction = radial * 1.5 + tangent * 0.5
	if distance > maxf(8.0, ai_rest_radius + 1.5):
		direction = -radial
	# Festgefahren (z. B. an einem Felsen): Richtung wechseln
	var speed_now: float = Vector2(player.velocity.x, player.velocity.z).length()
	state["stuck"] = float(state["stuck"]) + dt if speed_now < 0.5 and not player.is_stunned() else 0.0
	if float(state["stuck"]) > 1.2:
		state["orbit"] = -float(state["orbit"])
		state["stuck"] = 0.0
	ai.move = player.world_to_input(direction.normalized()) * AIProfile.speed(context.difficulty)
	# Über die Schockwelle springen (Weglaufen klappt bei 0,4 s Ausholzeit kaum, getestet)
	if _windup >= 0.0 and int(state["jumped"]) != _windup_id and distance < stomp_radius + 0.5:
		state["jumped"] = _windup_id
		state["jump_pending"] = rng.randf() < AIProfile.skill(context.difficulty)
	if bool(state.get("jump_pending", false)) and _windup >= 0.0 and _windup <= 0.25:
		state["jump_pending"] = false
		ai.tap(InputBindings.JUMP)
