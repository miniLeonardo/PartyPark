extends Minigame
## Zerfetzung (D72), Jeder gegen jeden in Ego-Sicht mit geteiltem Bildschirm (D49).
## Krawumm-Blaster: X feuert, halten = Dauerfeuer mit Überhitzung. Nach 3 Treffern zerplatzt die Figur
## comichaft in Stücke ihrer Farbe. Der Letzte gewinnt; nach Zeitablauf zählen die übrigen Treffer.

@export_group("Regeln")
## Treffer, bis eine Figur zerplatzt (D72).
@export var hits_to_out: int = 3
## Kurze Unverwundbarkeit nach einem Treffer (Sekunden).
@export var hit_grace: float = 0.4

@export_group("Blaster")
@export var fire_interval: float = 0.22
@export var projectile_speed: float = 34.0
@export var projectile_life: float = 1.4
## Streuung in Grad.
@export var spread_deg: float = 1.2
## Hitze pro Schuss, Abkühlung pro Sekunde, Sperre nach Überhitzung.
@export var heat_per_shot: float = 0.13
@export var cool_rate: float = 0.55
@export var overheat_lock: float = 1.5
@export var hit_knockback: float = 7.0

@export_group("Arena")
@export var arena_half: float = 14.0

@export_group("Computer")
## Zielfehler der Computer (Bogenmaß je Meter AIProfile-Zielfehler) und Zögern, bevor sie feuern (Sekunden).
@export var ai_aim_error_factor: float = 0.14
@export var ai_fire_delay: float = 0.35
@export var wall_height: float = 3.5

var hits: Dictionary = {}
## Platzindizes in der Reihenfolge des Ausscheidens.
var eliminated: Array[int] = []
var split: SplitScreen
var shots_fired: int = 0
var shots_hit: int = 0

var _abilities: Dictionary = {}
var _views: Dictionary = {}
var _heat: Dictionary = {}
var _locked: Dictionary = {}
var _fire_ready: Dictionary = {}
var _grace: Dictionary = {}
var _projectiles: Array[Dictionary] = []
var _projectile_mesh: SphereMesh
var _projectile_materials: Dictionary = {}
var _crosshairs: Dictionary = {}
var _ai_state: Dictionary = {}
var _spectator_angle: float = 0.0


func _init() -> void:
	time_limit = 120.0


func _build_arena() -> void:
	super._build_arena()
	StageKit.add_box(self, Vector3(arena_half * 2.0, 1.0, arena_half * 2.0), Vector3(0, -0.5, 0), Color("#7a87a8"))
	# Schachbrett-Flecken als Orientierung
	for x: int in range(-3, 4):
		for z: int in range(-3, 4):
			if (x + z) % 2 == 0:
				var tile: StaticBody3D = StageKit.add_box(self, Vector3(3.6, 0.02, 3.6), Vector3(x * 4.0, 0.01, z * 4.0), Color("#8d9abb"))
				tile.get_child(1).queue_free()
	var wall_color := Color("#c86f9e")
	for side: int in 4:
		var horizontal: bool = side < 2
		var sign_value: float = -1.0 if side % 2 == 0 else 1.0
		var size := Vector3(arena_half * 2.0 + 1.0, wall_height, 0.6) if horizontal else Vector3(0.6, wall_height, arena_half * 2.0 + 1.0)
		var spot := Vector3(0, wall_height * 0.5, sign_value * arena_half) if horizontal else Vector3(sign_value * arena_half, wall_height * 0.5, 0)
		StageKit.add_box(self, size, spot, wall_color)
	# Deckung: Kisten und Säulen (Platzhalter-Arena, D72)
	var crates: Array[Vector3] = [Vector3(-6, 1, -6), Vector3(6, 1, 6), Vector3(6, 1, -6), Vector3(-6, 1, 6), Vector3(0, 1, -9), Vector3(0, 1, 9), Vector3(-9, 1, 0), Vector3(9, 1, 0)]
	for spot: Vector3 in crates:
		StageKit.add_box(self, Vector3(2, 2, 2), spot, Color("#e0a458"))
	for spot: Vector3 in [Vector3(-3, 1.5, 0), Vector3(3, 1.5, 0), Vector3(0, 1.5, -3), Vector3(0, 1.5, 3)]:
		StageKit.add_cylinder(self, 0.7, 3.0, spot, Color("#5fb0b7"))
	StageKit.add_box(self, Vector3(4, 0.9, 0.5), Vector3(-10, 0.45, -10), Color("#9b6bff"))
	StageKit.add_box(self, Vector3(4, 0.9, 0.5), Vector3(10, 0.45, 10), Color("#9b6bff"))
	_projectile_mesh = SphereMesh.new()
	_projectile_mesh.radius = 0.12
	_projectile_mesh.height = 0.24
	_projectile_mesh.radial_segments = 8
	_projectile_mesh.rings = 4
	split = SplitScreen.new(4)
	add_child(split)


func _spawn_position(i: int, _slot: PlayerSlot) -> Vector3:
	var corners: Array[Vector3] = [Vector3(-11, 0.3, -11), Vector3(11, 0.3, 11), Vector3(11, 0.3, -11), Vector3(-11, 0.3, 11)]
	return corners[i % corners.size()]


func _spawn_facing(i: int, slot: PlayerSlot) -> Vector3:
	return -_spawn_position(i, slot) * Vector3(1, 0, 1)


func _configure_player(player: Player, slot: PlayerSlot) -> void:
	var view: int = players.size()
	hits[slot.index] = 0
	_heat[slot.index] = 0.0
	_locked[slot.index] = 0.0
	_fire_ready[slot.index] = 0.0
	player.push_ability.enabled = false
	player.movement_enabled = false
	player.drive_override = true
	player.spawn_particles = false
	# Namensschilder würden Gegner durch Deckung verraten
	player.tag_label.visible = false
	var ability := ShooterAbility.new()
	ability.name = "ShooterAbility"
	player.add_ability(ability)
	ability.reset(player.facing)
	ability.assist_check = _assist_check
	_abilities[slot.index] = ability
	_views[slot.index] = view
	var layer_bit: int = SplitScreen.player_layer_bit(view)
	SplitScreen.set_render_layer(player, layer_bit)
	split.hide_layer_in_view(view, layer_bit)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = slot.color.lightened(0.35)
	_projectile_materials[slot.index] = material
	_build_overlay(view, slot)


func _build_overlay(view: int, slot: PlayerSlot) -> void:
	var overlay: Control = split.overlays[view]
	var crosshair := BlasterCrosshair.new()
	crosshair.color = slot.color.lightened(0.4)
	crosshair.set_anchors_preset(Control.PRESET_FULL_RECT)
	crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(crosshair)
	_crosshairs[slot.index] = crosshair
	var name_label: Label = UiStyle.make_label(slot.display_name, 26, slot.color.lightened(0.3))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	name_label.position = Vector2(16, 10)
	overlay.add_child(name_label)


func _after_setup() -> void:
	# Ungenutzte Ansichten (weniger als 4 Spieler) zeigen die Arena von oben
	for view: int in range(players.size(), split.cameras.size()):
		var camera: Camera3D = split.cameras[view]
		camera.global_position = Vector3(0, 26, 18)
		camera.look_at(Vector3.ZERO, Vector3.UP)
	_update_cameras(0.0)
	_update_hud()


func _process(delta: float) -> void:
	_update_cameras(delta)


func _update_cameras(delta: float) -> void:
	_spectator_angle += delta * 0.25
	for player: Player in players:
		var index: int = player.slot.index
		var camera: Camera3D = split.cameras[int(_views[index])]
		if eliminated.has(index):
			# Zuschauer: langsam kreisende Übersicht
			var spot := Vector3(sin(_spectator_angle) * 18.0, 22.0, cos(_spectator_angle) * 18.0)
			camera.global_position = spot
			camera.look_at(Vector3.ZERO, Vector3.UP)
			continue
		var ability: ShooterAbility = _abilities[index]
		camera.global_position = ability.get_eye_position()
		camera.rotation = Vector3(ability.pitch, ability.yaw, 0.0)
		var crosshair: BlasterCrosshair = _crosshairs[index]
		crosshair.heat = float(_heat[index])
		crosshair.locked = float(_locked[index]) > 0.0
		crosshair.lives = hits_to_out - int(hits[index])


func _round_process(delta: float) -> void:
	for player: Player in players:
		var index: int = player.slot.index
		if eliminated.has(index):
			continue
		_grace[index] = maxf(0.0, float(_grace.get(index, 0.0)) - delta)
		_fire_ready[index] = float(_fire_ready[index]) - delta
		if float(_locked[index]) > 0.0:
			_locked[index] = float(_locked[index]) - delta
			_heat[index] = maxf(0.0, float(_heat[index]) - cool_rate * delta)
			continue
		var source: InputSource = player.get_input()
		var firing: bool = source != null and (source.is_down(InputBindings.TRIGGER) or source.is_down(InputBindings.PUSH))
		if firing and float(_fire_ready[index]) <= 0.0:
			_fire(player)
		else:
			_heat[index] = maxf(0.0, float(_heat[index]) - cool_rate * delta)
	_update_projectiles(delta)
	if _alive().size() <= 1 and context.slots.size() > 1:
		finish(_ranking())


func _fire(player: Player) -> void:
	var index: int = player.slot.index
	_fire_ready[index] = fire_interval
	_heat[index] = float(_heat[index]) + heat_per_shot
	if float(_heat[index]) >= 1.0:
		_heat[index] = 1.0
		_locked[index] = overheat_lock
		Sfx.play(&"overheat", player.global_position)
	var ability: ShooterAbility = _abilities[index]
	var direction: Vector3 = ability.get_look_direction()
	var spread: float = deg_to_rad(spread_deg)
	direction = direction.rotated(Vector3.UP, rng.randf_range(-spread, spread)).rotated(Vector3.RIGHT, rng.randf_range(-spread, spread)).normalized()
	var start: Vector3 = ability.get_eye_position() + direction * 0.5 + Vector3.DOWN * 0.15
	var mesh := MeshInstance3D.new()
	mesh.mesh = _projectile_mesh
	mesh.material_override = _projectile_materials[index]
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mesh)
	mesh.global_position = start
	_projectiles.append({"position": start, "direction": direction, "owner": player, "life": projectile_life, "mesh": mesh})
	shots_fired += 1
	Sfx.play(&"blaster", player.global_position, -3.0)
	player.slot.source.rumble(0.15, 0.0, 0.05)
	Fx.squash(player, -0.2)


func _update_projectiles(delta: float) -> void:
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	for i: int in range(_projectiles.size() - 1, -1, -1):
		var shot: Dictionary = _projectiles[i]
		var from: Vector3 = shot["position"]
		var to: Vector3 = from + (shot["direction"] as Vector3) * projectile_speed * delta
		var query := PhysicsRayQueryParameters3D.create(from, to)
		query.exclude = [(shot["owner"] as Player).get_rid()]
		var hit: Dictionary = space.intersect_ray(query)
		shot["life"] = float(shot["life"]) - delta
		var mesh := shot["mesh"] as MeshInstance3D
		if not hit.is_empty():
			var victim := hit["collider"] as Player
			if victim != null and victim.visible and not eliminated.has(victim.slot.index):
				_on_hit(victim, shot["owner"], shot["direction"])
			else:
				Fx.burst(&"dust", hit["position"], (_projectile_materials[(shot["owner"] as Player).slot.index] as StandardMaterial3D).albedo_color, 0.5)
				Sfx.play(&"impact", hit["position"], -8.0)
			mesh.queue_free()
			_projectiles.remove_at(i)
			continue
		if float(shot["life"]) <= 0.0:
			mesh.queue_free()
			_projectiles.remove_at(i)
			continue
		shot["position"] = to
		mesh.global_position = to


func _on_hit(victim: Player, shooter: Player, direction: Vector3) -> void:
	var index: int = victim.slot.index
	if float(_grace.get(index, 0.0)) > 0.0:
		return
	_grace[index] = hit_grace
	hits[index] = int(hits[index]) + 1
	shots_hit += 1
	var flat: Vector3 = Vector3(direction.x, 0.0, direction.z).normalized()
	victim.receive_push(flat * hit_knockback, 2.5, 0.2, shooter)
	Fx.hitstop([victim])
	Fx.burst(&"stars", victim.global_position + Vector3.UP * 1.0, victim.slot.color.lightened(0.3))
	Fx.shake(Fx.SHAKE_LIGHT, split.cameras[int(_views[index])])
	Sfx.play(&"splat", victim.global_position)
	shooter.slot.source.rumble(0.3, 0.0, 0.08)
	(_crosshairs[shooter.slot.index] as BlasterCrosshair).flash_hit()
	if int(hits[index]) >= hits_to_out:
		_shred(victim)
	_update_hud()


## „Zerfetzung“ (D72): Die Figur platzt comichaft in Stücke ihrer Farbe.
func _shred(victim: Player) -> void:
	var index: int = victim.slot.index
	eliminated.append(index)
	var center: Vector3 = victim.global_position + Vector3.UP * 0.7
	Fx.burst(&"chunks", center, victim.slot.color, 1.3)
	Fx.burst(&"chunks", center + Vector3.UP * 0.3, victim.slot.color.darkened(0.2), 1.0)
	Fx.burst(&"dust_ring", Vector3(center.x, 0.2, center.z), victim.slot.color.lightened(0.4), 0.7)
	Fx.shake(Fx.SHAKE_STRONG, split.cameras[int(_views[index])])
	for other: Player in players:
		if other != victim:
			Fx.shake(Fx.SHAKE_LIGHT, split.cameras[int(_views[other.slot.index])])
	Sfx.play(&"shred", center)
	victim.slot.source.rumble(1.0, 1.0, 0.4)
	victim.set_active(false)
	hud.show_message("%s ist zerfetzt!" % victim.slot.display_name, 1.5)
	Announcer.say(&"bad_luck", {"player": victim.slot.display_name}, 0.7)


## Zielhilfe: liegt ein sichtbarer Gegner nahe am Fadenkreuz?
func _assist_check(player: Player) -> bool:
	var ability: ShooterAbility = _abilities.get(player.slot.index)
	if ability == null:
		return false
	var eye: Vector3 = ability.get_eye_position()
	var look: Vector3 = ability.get_look_direction()
	for other: Player in players:
		if other == player or not other.visible or eliminated.has(other.slot.index):
			continue
		var to_other: Vector3 = other.global_position + Vector3.UP * 0.7 - eye
		if to_other.length() > 30.0:
			continue
		if rad_to_deg(look.angle_to(to_other)) < ability.assist_angle_deg:
			return true
	return false


func _alive() -> Array[int]:
	var result: Array[int] = []
	for slot: PlayerSlot in context.slots:
		if not eliminated.has(slot.index):
			result.append(slot.index)
	return result


## Rangliste: Überlebende nach wenigsten Treffern, dann Ausgeschiedene in umgekehrter Reihenfolge.
func _ranking() -> MinigameResult:
	var groups: Array = []
	var by_hits: Dictionary = {}
	for index: int in _alive():
		var key: int = int(hits[index])
		if not by_hits.has(key):
			by_hits[key] = []
		(by_hits[key] as Array).append(index)
	var keys: Array = by_hits.keys()
	keys.sort()
	for key: int in keys:
		groups.append(by_hits[key])
	for i: int in range(eliminated.size() - 1, -1, -1):
		groups.append([eliminated[i]])
	return MinigameResult.from_ranking(groups)


func _on_time_up() -> void:
	finish(_ranking())


## Knapp: Der Sieger hat nur noch einen Treffer übrig, oder mehrere überleben bis zum Schluss.
func was_close() -> bool:
	var alive: Array[int] = _alive()
	return alive.size() > 1 or (alive.size() == 1 and int(hits[alive[0]]) >= hits_to_out - 1)


func _update_hud() -> void:
	for slot: PlayerSlot in context.slots:
		var left: int = hits_to_out - int(hits.get(slot.index, 0))
		hud.set_status(slot, "%s  %s" % [slot.get_tag(), ("♥".repeat(left)) if left > 0 else "zerfetzt"])


## Für den Smoke-Test `--smoke-games`.
func debug_summary() -> String:
	return "Schüsse %d, Treffer %d, zerfetzt %d" % [shots_fired, shots_hit, eliminated.size()]


# --- Computergegner ---

func _update_ai(player: Player, ai: AIInput, delta: float) -> void:
	var index: int = player.slot.index
	if eliminated.has(index):
		return
	var state: Dictionary = _ai_state.get(index, {"think": 0.0, "target": null, "wander": Vector3.ZERO, "strafe": 1.0, "strafe_time": 0.0, "error": Vector2.ZERO})
	state["think"] = float(state["think"]) - delta
	state["strafe_time"] = float(state["strafe_time"]) - delta
	var ability: ShooterAbility = _abilities[index]
	var eye: Vector3 = ability.get_eye_position()
	if float(state["think"]) <= 0.0:
		state["think"] = AIProfile.reaction_time(context.difficulty)
		state["target"] = _visible_enemy(player, eye)
		var error: float = AIProfile.aim_error(context.difficulty) * ai_aim_error_factor
		state["error"] = Vector2(rng.randf_range(-error, error), rng.randf_range(-error, error))
		if state["target"] == null and (player.global_position.distance_to(state["wander"]) < 2.0 or rng.randf() < 0.2):
			state["wander"] = Vector3(rng.randf_range(-11, 11), 0, rng.randf_range(-11, 11))
	if float(state["strafe_time"]) <= 0.0:
		state["strafe_time"] = rng.randf_range(0.8, 2.0)
		state["strafe"] = -float(state["strafe"])
	var target: Player = state["target"]
	if target != null and (not target.visible or eliminated.has(target.slot.index)):
		target = null
		state["target"] = null
	var look_at_point: Vector3
	var move_local := Vector2.ZERO
	if target != null:
		look_at_point = target.global_position + Vector3.UP * 0.7 + target.velocity * 0.15
		var distance: float = eye.distance_to(look_at_point)
		var forward_move: float = 0.0
		if distance > 11.0:
			forward_move = -1.0
		elif distance < 6.0:
			forward_move = 0.6
		move_local = Vector2(float(state["strafe"]) * 0.8, forward_move)
	else:
		look_at_point = (state["wander"] as Vector3) + Vector3.UP * 1.2
		move_local = Vector2(0.0, -0.8)
	# Drehen wie mit dem rechten Stick: proportional zum Winkelfehler, mit Ungenauigkeit
	var to_point: Vector3 = look_at_point - eye
	var wanted_yaw: float = atan2(-to_point.x, -to_point.z) + (state["error"] as Vector2).x
	var wanted_pitch: float = atan2(to_point.y, Vector2(to_point.x, to_point.z).length()) + (state["error"] as Vector2).y
	var yaw_error: float = wrapf(wanted_yaw - ability.yaw, -PI, PI)
	var pitch_error: float = wanted_pitch - ability.pitch
	ai.aim = Vector2(clampf(-yaw_error * 2.2, -1.0, 1.0), clampf(-pitch_error * 2.2, -1.0, 1.0))
	ai.aim = Vector2(signf(ai.aim.x) * sqrt(absf(ai.aim.x)), signf(ai.aim.y) * sqrt(absf(ai.aim.y))) * AIProfile.speed(context.difficulty)
	ai.move = move_local * AIProfile.speed(context.difficulty)
	var aligned: bool = absf(yaw_error) < deg_to_rad(6.0) and absf(pitch_error) < deg_to_rad(8.0)
	state["aligned_time"] = float(state.get("aligned_time", 0.0)) + delta if aligned and target != null else 0.0
	var ready: bool = float(state["aligned_time"]) > ai_fire_delay * (1.6 - AIProfile.skill(context.difficulty))
	ai.hold(InputBindings.TRIGGER, ready and float(_heat[index]) < 0.75)
	ai.hold(InputBindings.PUSH, ready and float(_heat[index]) < 0.75)
	if player.is_on_floor() and rng.randf() < 0.004:
		ai.tap(InputBindings.JUMP)
	_ai_state[index] = state


func _visible_enemy(player: Player, eye: Vector3) -> Player:
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var best: Player = null
	var best_distance: float = INF
	for other: Player in players:
		if other == player or not other.visible or eliminated.has(other.slot.index):
			continue
		var point: Vector3 = other.global_position + Vector3.UP * 0.7
		var query := PhysicsRayQueryParameters3D.create(eye, point)
		query.exclude = [player.get_rid()]
		var hit: Dictionary = space.intersect_ray(query)
		if not hit.is_empty() and hit["collider"] != other:
			continue
		var d: float = eye.distance_to(point)
		if d < best_distance:
			best_distance = d
			best = other
	return best
