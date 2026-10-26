extends Minigame
## Schafe hüten (D37), alle gegen den Computer: 12 Schafe fliehen vor Spielern, X bellt (scheucht stark)
## und schubst. Ziel: 10 Schafe gleichzeitig im Gehege. Ab der Hälfte der Zeit holt ein Wolf Schafe heraus.

@export_group("Ziel")
@export var sheep_count: int = 12
@export var sheep_needed: int = 10
## Ab diesem Anteil der Spielzeit kommt der Wolf (0.5 = Hälfte).
@export_range(0.0, 1.0) var wolf_start_fraction: float = 0.5
@export var wolf_return_delay: float = 6.0

@export_group("Schafverhalten")
## Abstand, ab dem Schafe vor Spielern fliehen.
@export var player_flee_radius: float = 4.5
@export var player_flee_strength: float = 6.5
@export var wolf_flee_radius: float = 6.0
@export var wolf_flee_strength: float = 10.0
@export var cohesion: float = 0.25
@export var wander_strength: float = 1.0

@export_group("Bellen")
@export var bark_radius: float = 6.0
@export var bark_strength: float = 8.0
@export var bark_cooldown: float = 1.2

const FIELD_HALF := Vector2(15.0, 10.0)
const PEN_MIN := Vector2(-4.0, -10.0)
const PEN_MAX := Vector2(4.0, -4.0)
const PEN_ENTRANCE := Vector3(0.0, 0.0, -3.0)
const SHEEP_SCRIPT: GDScript = preload("res://minigames/sheep_herding/sheep.gd")
const WOLF_SCRIPT: GDScript = preload("res://minigames/sheep_herding/wolf.gd")

var sheep: Array[Sheep] = []
var wolf: Wolf
var in_pen: int = 0

var _wander_angle: Dictionary = {}
var _bark_ready_in: Dictionary = {}
var _bark_rings: Array[Dictionary] = []
var _wolf_state: String = "waiting"
var _wolf_timer: float = 0.0
var _ai_state: Dictionary = {}


func _init() -> void:
	time_limit = 90.0


func _build_arena() -> void:
	super._build_arena()
	StageKit.add_box(self, Vector3(FIELD_HALF.x * 2.0 + 2.0, 1, FIELD_HALF.y * 2.0 + 2.0), Vector3(0, -0.5, 0), Color("#7cc66a"))
	var fence := Color("#8a5a33")
	StageKit.add_box(self, Vector3(FIELD_HALF.x * 2.0, 1.2, 0.3), Vector3(0, 0.6, -FIELD_HALF.y), fence)
	StageKit.add_box(self, Vector3(FIELD_HALF.x * 2.0, 1.2, 0.3), Vector3(0, 0.6, FIELD_HALF.y), fence)
	StageKit.add_box(self, Vector3(0.3, 1.2, FIELD_HALF.y * 2.0), Vector3(-FIELD_HALF.x, 0.6, 0), fence)
	StageKit.add_box(self, Vector3(0.3, 1.2, FIELD_HALF.y * 2.0), Vector3(FIELD_HALF.x, 0.6, 0), fence)
	# Gehege: Boden, Seitenwände, vorne zwei Teilstücke mit 4 m Öffnung
	var straw: StaticBody3D = StageKit.add_box(self, Vector3(8, 0.04, 6), Vector3(0, 0.02, -7), Color("#e6cf7a"))
	straw.get_child(1).queue_free()
	var pen := Color("#ffffff")
	StageKit.add_box(self, Vector3(0.25, 1.0, 6), Vector3(-4, 0.5, -7), pen)
	StageKit.add_box(self, Vector3(0.25, 1.0, 6), Vector3(4, 0.5, -7), pen)
	StageKit.add_box(self, Vector3(2, 1.0, 0.25), Vector3(-3, 0.5, -4), pen)
	StageKit.add_box(self, Vector3(2, 1.0, 0.25), Vector3(3, 0.5, -4), pen)
	var camera := Camera3D.new()
	camera.fov = 50.0
	add_child(camera)
	camera.position = Vector3(0, 19.5, 14.5)
	camera.look_at(Vector3(0, 0, -0.8), Vector3.UP)
	camera.current = true


func _spawn_position(i: int, _slot: PlayerSlot) -> Vector3:
	return Vector3(-4.5 + 3.0 * float(i), 0.3, 8.5)


func _spawn_facing(_i: int, _slot: PlayerSlot) -> Vector3:
	return Vector3.FORWARD


func _configure_player(player: Player, _slot: PlayerSlot) -> void:
	player.push_ability.friendly_fire = false


func _after_setup() -> void:
	for i: int in sheep_count:
		var animal := SHEEP_SCRIPT.new() as Sheep
		animal.name = "Sheep%d" % i
		add_child(animal)
		animal.global_position = Vector3(rng.randf_range(-12.0, 12.0), 0.2, rng.randf_range(-1.0, 6.5))
		sheep.append(animal)
		_wander_angle[animal] = rng.randf_range(0.0, TAU)
	wolf = WOLF_SCRIPT.new() as Wolf
	wolf.name = "Wolf"
	add_child(wolf)
	wolf.global_position = Vector3(FIELD_HALF.x + 6.0, 0.2, 9.0)
	wolf.target = wolf.global_position
	wolf.chased_away.connect(_on_wolf_chased)
	_set_wolf_active(false)
	_update_hud()


func _round_process(delta: float) -> void:
	_handle_barks(delta)
	_steer_sheep(delta)
	_update_wolf(delta)
	_update_bark_rings(delta)
	var count: int = 0
	for animal: Sheep in sheep:
		if _in_pen(animal.global_position):
			count += 1
	if count != in_pen:
		if count > in_pen:
			Fx.burst(&"stars", PEN_ENTRANCE + Vector3.UP * 1.0)
			Sfx.play(&"sheep_in", PEN_ENTRANCE)
		in_pen = count
		_update_hud()
	if in_pen >= sheep_needed:
		finish(MinigameResult.coop(context.indices(), true))


## Knapp: in den letzten 10 Sekunden geschafft oder um höchstens zwei Schafe verpasst.
func was_close() -> bool:
	if in_pen >= sheep_needed:
		return time_left() < 10.0
	return in_pen >= sheep_needed - 2


func _on_time_up() -> void:
	finish(MinigameResult.coop(context.indices(), in_pen >= sheep_needed))


func _in_pen(spot: Vector3) -> bool:
	return spot.x > PEN_MIN.x and spot.x < PEN_MAX.x and spot.z > PEN_MIN.y and spot.z < PEN_MAX.y


func _update_hud() -> void:
	hud.set_info("pen", "Im Gehege: %d / %d" % [in_pen, sheep_needed], Color("#e6cf7a"))


# --- Bellen ---

func _handle_barks(delta: float) -> void:
	for player: Player in players:
		var index: int = player.slot.index
		_bark_ready_in[index] = float(_bark_ready_in.get(index, 0.0)) - delta
		var source: InputSource = player.get_input()
		var bark_pressed: bool = source != null and (source.just_pressed(InputBindings.TRIGGER) or source.just_pressed(InputBindings.PUSH))
		if not bark_pressed or float(_bark_ready_in[index]) > 0.0:
			continue
		_bark_ready_in[index] = bark_cooldown
		_spawn_bark_ring(player.global_position, player.slot.color)
		Fx.burst(&"dust", player.global_position + Vector3.UP * 0.2, Color(0, 0, 0, 0), 0.7)
		Fx.squash(player, 0.6)
		Sfx.play(&"bark", player.global_position)
		for animal: Sheep in sheep:
			var d: float = animal.global_position.distance_to(player.global_position)
			if d < bark_radius:
				animal.scare(player.global_position, bark_strength * (1.0 - d / bark_radius) + 2.0)
		player.set_tag_text("Wuff!")
		# An die Figur gebundener Tween, damit nichts nachläuft, wenn das Minispiel endet
		var tween: Tween = player.create_tween()
		tween.tween_interval(0.5)
		tween.tween_callback(func() -> void: player.set_tag_text(player.slot.get_tag()))


func _spawn_bark_ring(at: Vector3, color: Color) -> void:
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.92
	torus.outer_radius = 1.0
	ring.mesh = torus
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(color.r, color.g, color.b, 0.8)
	ring.material_override = material
	add_child(ring)
	ring.global_position = Vector3(at.x, 0.2, at.z)
	_bark_rings.append({"node": ring, "t": 0.0, "material": material})


func _update_bark_rings(delta: float) -> void:
	for entry: Dictionary in _bark_rings.duplicate():
		entry["t"] = float(entry["t"]) + delta
		var t: float = float(entry["t"]) / 0.35
		var ring := entry["node"] as MeshInstance3D
		var radius: float = lerpf(0.5, bark_radius, clampf(t, 0.0, 1.0))
		ring.scale = Vector3(radius, 1.0, radius)
		(entry["material"] as StandardMaterial3D).albedo_color.a = clampf(1.0 - t, 0.0, 0.8)
		if t >= 1.0:
			ring.queue_free()
			_bark_rings.erase(entry)


# --- Schafe ---

func _steer_sheep(delta: float) -> void:
	for animal: Sheep in sheep:
		var spot: Vector3 = animal.global_position
		var force: Vector3 = Vector3.ZERO
		var fleeing: bool = false
		for player: Player in players:
			var away: Vector3 = spot - player.global_position
			away.y = 0.0
			var d: float = away.length()
			if d < player_flee_radius and d > 0.01:
				force += away / d * player_flee_strength * (1.0 - d / player_flee_radius)
				fleeing = true
		if wolf.visible:
			var away_wolf: Vector3 = spot - wolf.global_position
			away_wolf.y = 0.0
			var dw: float = away_wolf.length()
			if dw < wolf_flee_radius and dw > 0.01:
				force += away_wolf / dw * wolf_flee_strength * (1.0 - dw / wolf_flee_radius)
				fleeing = true
		var center: Vector3 = Vector3.ZERO
		var neighbors: int = 0
		for other: Sheep in sheep:
			if other == animal:
				continue
			var offset: Vector3 = other.global_position - spot
			offset.y = 0.0
			var d: float = offset.length()
			if d < 5.0:
				center += other.global_position
				neighbors += 1
			if d < 1.1 and d > 0.01:
				force -= offset / d * 1.5
		if neighbors > 0:
			var to_center: Vector3 = center / float(neighbors) - spot
			to_center.y = 0.0
			force += to_center * cohesion
		var calm: float = 0.3 if _in_pen(spot) else 1.0
		var angle: float = float(_wander_angle[animal]) + rng.randf_range(-1.5, 1.5) * delta
		_wander_angle[animal] = angle
		if not fleeing:
			force += Vector3(sin(angle), 0.0, cos(angle)) * wander_strength * calm
		animal.desired = force


# --- Wolf ---

func _update_wolf(delta: float) -> void:
	match _wolf_state:
		"waiting":
			if elapsed >= time_limit * wolf_start_fraction:
				_wolf_state = "hunting"
				_set_wolf_active(true)
				wolf.global_position = Vector3(FIELD_HALF.x - 1.0 if rng.randf() < 0.5 else -FIELD_HALF.x + 1.0, 0.3, 8.0)
				hud.show_message("Ein Wolf kommt!", 1.5)
				Sfx.play(&"wolf_howl", wolf.global_position)
		"hunting":
			var target: Vector3 = Vector3(0, 0, -7)
			var best: float = INF
			for animal: Sheep in sheep:
				if _in_pen(animal.global_position):
					var d: float = animal.global_position.distance_to(wolf.global_position)
					if d < best:
						best = d
						# Hinter das Schaf (vom Ausgang aus gesehen), damit es hinausrennt
						var outward: Vector3 = (PEN_ENTRANCE - animal.global_position).normalized()
						target = animal.global_position - outward * 1.2
			if best == INF:
				target = PEN_ENTRANCE + Vector3(0, 0, -2)
			wolf.target = target
		"fleeing":
			wolf.target = Vector3(FIELD_HALF.x + 8.0 if wolf.global_position.x >= 0.0 else -FIELD_HALF.x - 8.0, 0, 9.0)
			if absf(wolf.global_position.x) > FIELD_HALF.x + 4.0 or wolf.global_position.y < -5.0:
				_set_wolf_active(false)
				_wolf_state = "away"
				_wolf_timer = wolf_return_delay
		"away":
			_wolf_timer -= delta
			if _wolf_timer <= 0.0:
				_wolf_state = "hunting"
				wolf.fleeing = false
				_set_wolf_active(true)
				wolf.global_position = Vector3(FIELD_HALF.x - 1.0 if rng.randf() < 0.5 else -FIELD_HALF.x + 1.0, 0.3, 8.0)
				hud.show_message("Der Wolf ist zurück!", 1.2)
				Sfx.play(&"wolf_howl", wolf.global_position)


func _set_wolf_active(active: bool) -> void:
	wolf.visible = active
	wolf.set_physics_process(active)
	(wolf.get_child(0) as CollisionShape3D).set_deferred("disabled", not active)
	if active:
		wolf.add_to_group(PushAbility.PUSHABLE_GROUP)
	else:
		wolf.remove_from_group(PushAbility.PUSHABLE_GROUP)


func _on_wolf_chased() -> void:
	_wolf_state = "fleeing"
	# Flucht über den Zaun: kurz ohne Kollision
	(wolf.get_child(0) as CollisionShape3D).set_deferred("disabled", true)
	hud.show_message("Wolf verjagt!", 1.2)
	Fx.burst(&"stars", wolf.global_position + Vector3.UP * 0.8)
	Sfx.play(&"wolf_yelp", wolf.global_position)


# --- Computergegner ---

func _update_ai(player: Player, ai: AIInput, delta: float) -> void:
	var index: int = player.slot.index
	var state: Dictionary = _ai_state.get(index, {"think": 0.0, "sheep": null})
	state["think"] = float(state["think"]) - delta
	var speed: float = AIProfile.speed(context.difficulty)
	# Wolf vertreiben, wenn dieser Computer am nächsten dran ist
	if _wolf_state == "hunting" and wolf.visible and _closest_ai_to(wolf.global_position) == player:
		var to_wolf: Vector3 = wolf.global_position - player.global_position
		to_wolf.y = 0.0
		ai_steer_to(player, ai, wolf.global_position, speed)
		if to_wolf.length() < 1.4 and float(state["think"]) <= 0.0:
			state["think"] = AIProfile.reaction_time(context.difficulty)
			ai.tap(InputBindings.TRIGGER)
			ai.tap(InputBindings.PUSH)
		_ai_state[index] = state
		return
	if float(state["think"]) <= 0.0 or state["sheep"] == null:
		state["think"] = 1.5
		state["sheep"] = _pick_sheep(player)
	var target_sheep: Sheep = state["sheep"]
	if target_sheep == null or _in_pen(target_sheep.global_position):
		state["sheep"] = null
		ai.move = Vector2.ZERO
		_ai_state[index] = state
		return
	var to_entrance: Vector3 = PEN_ENTRANCE - target_sheep.global_position
	to_entrance.y = 0.0
	var behind: Vector3 = target_sheep.global_position - to_entrance.normalized() * 2.4
	var error: float = AIProfile.aim_error(context.difficulty) * 0.3
	behind += Vector3(rng.randf_range(-error, error), 0, rng.randf_range(-error, error))
	if player.global_position.distance_to(behind) > 1.2:
		ai_steer_to(player, ai, behind, speed)
	else:
		ai_steer_to(player, ai, target_sheep.global_position, 0.55 * speed)
		if to_entrance.length() > 4.0 and float(_bark_ready_in.get(index, 0.0)) <= 0.0 and rng.randf() < AIProfile.skill(context.difficulty) * 0.03:
			ai.tap(InputBindings.TRIGGER)
			ai.tap(InputBindings.PUSH)
	_ai_state[index] = state


func _pick_sheep(player: Player) -> Sheep:
	var taken: Array = []
	for key: int in _ai_state:
		if key != player.slot.index and _ai_state[key].get("sheep") != null:
			taken.append(_ai_state[key]["sheep"])
	var best: Sheep = null
	var best_score: float = -INF
	for animal: Sheep in sheep:
		if _in_pen(animal.global_position) or taken.has(animal):
			continue
		# Nahe Schafe bevorzugen, aber weit vom Eingang entfernte zuerst holen
		var score: float = -animal.global_position.distance_to(player.global_position) * 0.6 + animal.global_position.distance_to(PEN_ENTRANCE) * 0.4
		if score > best_score:
			best_score = score
			best = animal
	return best


func _closest_ai_to(spot: Vector3) -> Player:
	var best: Player = null
	var best_distance: float = INF
	for player: Player in players:
		if not player.slot.is_cpu:
			continue
		var d: float = player.global_position.distance_to(spot)
		if d < best_distance:
			best_distance = d
			best = player
	return best
