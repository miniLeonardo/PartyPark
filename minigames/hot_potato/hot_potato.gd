extends Minigame
## Heiße Kartoffel (D71), Jeder gegen jeden: Die Bombe springt per Schubser weiter. Die Lunte brennt
## zufällig 8 bis 15 Sekunden; wer beim Knall die Bombe hält, ist raus. Danach neue Bombe, bis einer übrig ist.

@export_group("Bombe")
@export var fuse_min: float = 8.0
@export var fuse_max: float = 15.0
## Keine Rückgabe an den Vorbesitzer innerhalb dieser Zeit (Sekunden).
@export var pass_back_lock: float = 0.6
## Tempo-Bonus des Bombenträgers (Anteil).
@export var holder_speed_bonus: float = 0.15
## Pause zwischen Knall und neuer Bombe (Sekunden).
@export var new_bomb_delay: float = 1.6
## Explosionsradius, in dem andere weggeschleudert werden (Meter).
@export var blast_radius: float = 3.5
@export var blast_strength: float = 14.0

@export_group("Arena")
@export var arena_radius: float = 10.0

var holder: Player = null
## Platzindizes in der Reihenfolge des Ausscheidens.
var eliminated: Array[int] = []
var explosions: int = 0
var passes: int = 0

var _previous_holder: Player = null
var _pass_time: float = -10.0
var _fuse_total: float = 10.0
var _fuse_left: float = 10.0
var _tick_timer: float = 0.0
var _new_bomb_in: float = 1.0
var _base_speed: float = 7.0
var _bomb: Node3D
var _bomb_body: MeshInstance3D
var _fuse_mesh: MeshInstance3D
var _spark: MeshInstance3D
var _bomb_material: StandardMaterial3D
var _ai_state: Dictionary = {}
var _last_elimination_time: float = -100.0


func _init() -> void:
	time_limit = 120.0


func _build_arena() -> void:
	super._build_arena()
	StageKit.add_cylinder(self, arena_radius, 1.0, Vector3(0, -0.5, 0), Color("#d9a066"))
	StageKit.add_cylinder(self, arena_radius - 3.0, 0.02, Vector3(0, 0.01, 0), Color("#e8b77d"))
	var segments: int = 36
	for i: int in segments:
		var angle: float = TAU * float(i) / float(segments)
		var radius: float = arena_radius - 0.2
		var length: float = TAU * radius / float(segments) + 0.05
		var fence: StaticBody3D = StageKit.add_box(self, Vector3(length, 1.2, 0.35), Vector3(sin(angle) * radius, 0.6, cos(angle) * radius), Color("#8a5a33") if i % 2 == 0 else Color("#a86f3f"))
		fence.rotation.y = angle
	_build_bomb()
	var camera := Camera3D.new()
	camera.fov = 50.0
	add_child(camera)
	camera.position = Vector3(0, 21, 13)
	camera.look_at(Vector3(0, 0, 1.0), Vector3.UP)
	camera.current = true


func _build_bomb() -> void:
	_bomb = Node3D.new()
	_bomb.name = "Bomb"
	add_child(_bomb)
	_bomb_body = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.38
	sphere.height = 0.76
	_bomb_body.mesh = sphere
	_bomb_material = StageKit.make_material(Color(0.12, 0.12, 0.14))
	_bomb_material.emission_enabled = true
	_bomb_material.emission = Color(1, 0.2, 0.1)
	_bomb_material.emission_energy_multiplier = 0.0
	_bomb_body.material_override = _bomb_material
	_bomb.add_child(_bomb_body)
	_fuse_mesh = MeshInstance3D.new()
	var fuse := CylinderMesh.new()
	fuse.top_radius = 0.04
	fuse.bottom_radius = 0.05
	fuse.height = 0.4
	_fuse_mesh.mesh = fuse
	_fuse_mesh.material_override = StageKit.make_material(Color("#c9b48a"))
	_bomb.add_child(_fuse_mesh)
	_spark = MeshInstance3D.new()
	var spark_mesh := SphereMesh.new()
	spark_mesh.radius = 0.09
	spark_mesh.height = 0.18
	spark_mesh.radial_segments = 6
	spark_mesh.rings = 3
	_spark.mesh = spark_mesh
	var spark_material := StandardMaterial3D.new()
	spark_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spark_material.albedo_color = Color(1, 0.85, 0.3)
	_spark.material_override = spark_material
	_bomb.add_child(_spark)
	_bomb.visible = false


func _spawn_position(i: int, _slot: PlayerSlot) -> Vector3:
	var count: int = maxi(2, context.slots.size())
	var angle: float = TAU * float(i) / float(count) + PI * 0.25
	return Vector3(sin(angle) * 4.5, 0.3, cos(angle) * 4.5)


func _spawn_facing(i: int, slot: PlayerSlot) -> Vector3:
	return -_spawn_position(i, slot)


func _configure_player(player: Player, _slot: PlayerSlot) -> void:
	_base_speed = player.move_speed
	player.push_ability.pushed.connect(_on_pushed.bind(player))


func _after_setup() -> void:
	_update_hud()


func _round_process(delta: float) -> void:
	if holder == null:
		_new_bomb_in -= delta
		if _new_bomb_in <= 0.0 and _alive().size() >= 2:
			var alive: Array[int] = _alive()
			_give_bomb(get_player(alive[rng.randi_range(0, alive.size() - 1)]), null)
			_fuse_total = rng.randf_range(fuse_min, fuse_max)
			_fuse_left = _fuse_total
			_tick_timer = 0.0
			hud.show_message("Neue Bombe!", 1.0)
	else:
		_fuse_left -= delta
		_update_bomb_visual(delta)
		if _fuse_left <= 0.0:
			_explode()
	var alive_now: Array[int] = _alive()
	if alive_now.size() <= 1 and context.slots.size() > 1:
		finish(_ranking())


func _update_bomb_visual(delta: float) -> void:
	var progress: float = 1.0 - clampf(_fuse_left / maxf(_fuse_total, 0.01), 0.0, 1.0)
	_bomb.global_position = holder.global_position + Vector3.UP * (1.95 * holder.body_scale + 0.25)
	var fuse_length: float = lerpf(0.4, 0.04, progress)
	_fuse_mesh.scale = Vector3(1.0, fuse_length / 0.4, 1.0)
	_fuse_mesh.position = Vector3(0, 0.36 + fuse_length * 0.5, 0)
	_spark.position = Vector3(0, 0.36 + fuse_length + 0.04, 0)
	_spark.scale = Vector3.ONE * rng.randf_range(0.7, 1.4)
	# Ticken wird schneller, Bombe glüht und pulsiert zum Ende hin
	_tick_timer -= delta
	if _tick_timer <= 0.0:
		_tick_timer = lerpf(0.6, 0.1, progress)
		Sfx.play(&"tick", _bomb.global_position, -4.0, lerpf(0.9, 1.5, progress))
		_bomb_body.scale = Vector3.ONE * (1.0 + 0.25 * progress)
	_bomb_body.scale = _bomb_body.scale.lerp(Vector3.ONE, clampf(delta * 10.0, 0.0, 1.0))
	_bomb_material.emission_energy_multiplier = progress * progress * 2.5


func _give_bomb(player: Player, from: Player) -> void:
	if holder != null:
		holder.move_speed = _base_speed
	_previous_holder = from
	holder = player
	_pass_time = elapsed
	holder.move_speed = _base_speed * (1.0 + holder_speed_bonus)
	_bomb.visible = true
	_bomb.global_position = holder.global_position + Vector3.UP * (1.95 * holder.body_scale + 0.25)
	Fx.squash(holder, 0.8)
	Fx.burst(&"stars", _bomb.global_position, holder.slot.color.lightened(0.3))
	Sfx.play(&"pass", holder.global_position)
	holder.slot.source.rumble(0.5, 0.0, 0.15)
	_update_hud()


func _on_pushed(target: Node3D, pusher: Player) -> void:
	var other := target as Player
	if pusher != holder or other == null or not other.visible or eliminated.has(other.slot.index):
		return
	if other == _previous_holder and elapsed - _pass_time < pass_back_lock:
		return
	passes += 1
	_give_bomb(other, pusher)


func _explode() -> void:
	var victim: Player = holder
	var center: Vector3 = _bomb.global_position
	holder = null
	_bomb.visible = false
	explosions += 1
	victim.move_speed = _base_speed
	Fx.burst(&"dust_ring", Vector3(center.x, 0.2, center.z), Color(0, 0, 0, 0), 1.3)
	Fx.burst(&"stars", center, Color(1, 0.6, 0.2), 1.6)
	Fx.burst(&"confetti", center, Color(0.3, 0.3, 0.3))
	Fx.shake(Fx.SHAKE_STRONG)
	Sfx.play(&"explosion", center)
	for other: Player in players:
		if other == victim or not other.visible:
			continue
		var offset: Vector3 = other.global_position - victim.global_position
		offset.y = 0.0
		if offset.length() < blast_radius:
			var direction: Vector3 = offset.normalized() if offset.length() > 0.01 else Vector3.BACK
			other.receive_push(direction * blast_strength * (1.0 - offset.length() / blast_radius * 0.5), 6.0, 0.5, null)
	# Halter wird hochgeschleudert und verschwindet
	var index: int = victim.slot.index
	eliminated.append(index)
	_last_elimination_time = elapsed
	victim.slot.source.rumble(1.0, 1.0, 0.4)
	victim.controls_enabled = false
	victim.velocity = Vector3(0, 14, 0)
	var tween: Tween = create_tween()
	tween.tween_property(victim.visual, "rotation:x", TAU * 2.0, 0.7)
	tween.tween_callback(func() -> void:
		if is_instance_valid(victim):
			victim.set_active(false))
	hud.show_message("%s ist raus!" % victim.slot.display_name, 1.5)
	Announcer.say(&"bad_luck", {"player": victim.slot.display_name}, 0.7)
	_new_bomb_in = new_bomb_delay
	_update_hud()


func _alive() -> Array[int]:
	var result: Array[int] = []
	for slot: PlayerSlot in context.slots:
		if not eliminated.has(slot.index):
			result.append(slot.index)
	return result


func _ranking() -> MinigameResult:
	var groups: Array = []
	var alive: Array[int] = _alive()
	if not alive.is_empty():
		groups.append(alive)
	for i: int in range(eliminated.size() - 1, -1, -1):
		groups.append([eliminated[i]])
	return MinigameResult.from_ranking(groups)


func _on_time_up() -> void:
	finish(_ranking())


## Knapp: Das Finale (zwei übrig) dauerte nur kurz oder die Zeit lief ab.
func was_close() -> bool:
	return _alive().size() > 1


func _update_hud() -> void:
	for slot: PlayerSlot in context.slots:
		var text: String = "raus" if eliminated.has(slot.index) else "dabei"
		if holder != null and holder.slot == slot:
			text = "BOMBE!"
		hud.set_status(slot, "%s  %s" % [slot.get_tag(), text])


## Für den Smoke-Test `--smoke-games`.
func debug_summary() -> String:
	return "Explosionen %d, Weitergaben %d" % [explosions, passes]


# --- Computergegner ---

func _update_ai(player: Player, ai: AIInput, delta: float) -> void:
	var index: int = player.slot.index
	if eliminated.has(index):
		ai.move = Vector2.ZERO
		return
	var state: Dictionary = _ai_state.get(index, {"think": 0.0, "wander": Vector3.ZERO})
	state["think"] = float(state["think"]) - delta
	var speed: float = AIProfile.speed(context.difficulty)
	if player == holder:
		var target: Player = _nearest_target(player)
		if target != null:
			var aim: Vector3 = target.global_position + target.velocity * 0.25
			ai_steer_to(player, ai, aim, speed)
			if player.global_position.distance_to(target.global_position) < 1.5 and rng.randf() < AIProfile.skill(context.difficulty) * 0.15:
				ai.tap(InputBindings.PUSH)
	else:
		var away: Vector3 = Vector3.ZERO
		if holder != null:
			away = player.global_position - holder.global_position
			away.y = 0.0
		if holder != null and away.length() < 6.0:
			# Fliehen, an der Bande entlang statt hinein
			var flat := Vector3(player.global_position.x, 0, player.global_position.z)
			var direction: Vector3 = away.normalized()
			if flat.length() > arena_radius - 2.5:
				var tangent: Vector3 = Vector3.UP.cross(flat.normalized())
				direction = (tangent * signf(tangent.dot(direction) + 0.001) - flat.normalized() * 0.4).normalized()
			ai.move = player.world_to_input(direction) * speed
			# Bombenträger dicht dran: zurückschubsen
			if away.length() < 1.4 and rng.randf() < AIProfile.skill(context.difficulty) * 0.05:
				ai.tap(InputBindings.PUSH)
		else:
			if float(state["think"]) <= 0.0:
				state["think"] = rng.randf_range(1.0, 2.5)
				state["wander"] = Vector3(rng.randf_range(-5, 5), 0, rng.randf_range(-5, 5))
			ai_steer_to(player, ai, state["wander"], speed * 0.6)
	_ai_state[index] = state


func _nearest_target(player: Player) -> Player:
	var best: Player = null
	var best_distance: float = INF
	for other: Player in players:
		if other == player or eliminated.has(other.slot.index) or not other.visible:
			continue
		if other == _previous_holder and elapsed - _pass_time < pass_back_lock:
			continue
		var d: float = other.global_position.distance_to(player.global_position)
		if d < best_distance:
			best_distance = d
			best = other
	return best
