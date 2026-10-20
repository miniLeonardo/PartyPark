extends Minigame
## Autoscooter (D34): runde Plattform mit Lücken in der Bande, 3 Leben, Letzter gewinnt,
## nach Zeitablauf zählen die Leben.

## Startleben pro Spieler.
@export var start_lives: int = 3
@export var arena_radius: float = 11.0
## Anzahl der Bandenlücken und ihre Breite in Grad.
@export var gap_count: int = 4
@export var gap_width_deg: float = 26.0
## Unterhalb dieser Höhe gilt ein Scooter als rausgefallen.
@export var fall_height: float = -2.5
@export var respawn_delay: float = 1.2

var lives: Dictionary = {}
## Platzindizes in der Reihenfolge des Ausscheidens.
var eliminated: Array[int] = []

var _respawn_timers: Dictionary = {}
var _ai_state: Dictionary = {}


func _init() -> void:
	time_limit = 90.0


func _build_arena() -> void:
	super._build_arena()
	var floor_body: StaticBody3D = StageKit.add_cylinder(self, arena_radius, 1.0, Vector3(0, -0.5, 0), Color("#7d8296"))
	floor_body.name = "Floor"
	StageKit.add_cylinder(self, arena_radius - 0.6, 0.02, Vector3(0, 0.01, 0), Color("#9499ad"))
	# Bande als Ring aus Segmenten, mit Lücken
	var segments: int = 36
	for i: int in segments:
		var angle_deg: float = 360.0 * float(i) / float(segments)
		if _in_gap(angle_deg):
			continue
		var angle: float = deg_to_rad(angle_deg)
		var radius: float = arena_radius - 0.2
		var position_on_ring := Vector3(sin(angle) * radius, 0.35, cos(angle) * radius)
		var length: float = TAU * radius / float(segments) + 0.05
		var wall: StaticBody3D = StageKit.add_box(self, Vector3(length, 0.7, 0.4), position_on_ring, Color("#ffd23f") if i % 2 == 0 else Color("#e5531a"))
		wall.rotation.y = angle
	# Wasser darunter
	var water: StaticBody3D = StageKit.add_box(self, Vector3(80, 1, 80), Vector3(0, -6, 0), Color("#3f8fd6"))
	water.get_child(1).queue_free()
	var camera := Camera3D.new()
	camera.fov = 50.0
	add_child(camera)
	camera.position = Vector3(0, 24, 14)
	camera.look_at(Vector3(0, 0, 1.5), Vector3.UP)
	camera.current = true


func _in_gap(angle_deg: float) -> bool:
	for g: int in gap_count:
		var center: float = 45.0 + 360.0 * float(g) / float(gap_count)
		var diff: float = absf(wrapf(angle_deg - center, -180.0, 180.0))
		if diff < gap_width_deg * 0.5:
			return true
	return false


func _spawn_position(i: int, _slot: PlayerSlot) -> Vector3:
	var count: int = maxi(2, context.slots.size())
	var angle: float = TAU * float(i) / float(count) + PI * 0.25
	return Vector3(sin(angle) * 5.0, 0.3, cos(angle) * 5.0)


func _spawn_facing(i: int, slot: PlayerSlot) -> Vector3:
	return -_spawn_position(i, slot).normalized()


func _configure_player(player: Player, slot: PlayerSlot) -> void:
	lives[slot.index] = start_lives
	player.jump_ability.enabled = false
	player.push_ability.enabled = false
	player.movement_enabled = false
	player.drive_override = true
	player.knockback_friction_ground = 9.0
	var shape := CylinderShape3D.new()
	shape.radius = 0.9
	shape.height = 0.9
	player.set_collision_shape(shape, 0.45)
	_add_car_mesh(player, slot.color)
	var scooter := ScooterAbility.new()
	scooter.name = "ScooterAbility"
	player.add_ability(scooter)
	scooter.bumped.connect(_on_bumped.bind(player, scooter))
	scooter.reset(player.facing)


func _add_car_mesh(player: Player, color: Color) -> void:
	var body := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.8
	cylinder.bottom_radius = 0.9
	cylinder.height = 0.55
	body.mesh = cylinder
	body.position.y = 0.3
	body.material_override = StageKit.make_material(color.darkened(0.15))
	player.visual.add_child(body)
	var bumper := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.82
	torus.outer_radius = 1.02
	bumper.mesh = torus
	bumper.position.y = 0.22
	bumper.material_override = StageKit.make_material(Color(0.12, 0.12, 0.14))
	player.visual.add_child(bumper)
	var pole := MeshInstance3D.new()
	var pole_mesh := CylinderMesh.new()
	pole_mesh.top_radius = 0.03
	pole_mesh.bottom_radius = 0.03
	pole_mesh.height = 1.6
	pole.mesh = pole_mesh
	pole.position = Vector3(0, 1.4, 0.65)
	pole.material_override = StageKit.make_material(Color(0.8, 0.8, 0.85))
	player.visual.add_child(pole)
	player.visual.foot_left.visible = false
	player.visual.foot_right.visible = false


func _after_setup() -> void:
	_update_hud()


func _round_process(delta: float) -> void:
	for player: Player in players:
		var index: int = player.slot.index
		if _respawn_timers.has(index):
			_respawn_timers[index] = float(_respawn_timers[index]) - delta
			if _respawn_timers[index] <= 0.0:
				_respawn_timers.erase(index)
				_respawn(player)
			continue
		if eliminated.has(index):
			continue
		if player.global_position.y < fall_height:
			_on_fell(player)
	var alive: Array[int] = _alive()
	if alive.size() <= 1 and context.slots.size() > 1:
		finish(_ranking())


## Rempler: Hitstop für beide, Sterne an der Aufprallstelle, Turbo wackelt leicht (D56).
func _on_bumped(other: Player, _strength: float, bumper: Player, scooter: ScooterAbility) -> void:
	Fx.hitstop([bumper, other])
	Sfx.play(&"bump", bumper.global_position, 0.0, 1.15 if not scooter.is_turbo() else 0.85)
	Fx.burst(&"stars", (bumper.global_position + other.global_position) * 0.5 + Vector3.UP * 0.6)
	if scooter.is_turbo():
		Fx.shake(Fx.SHAKE_LIGHT)


func _on_fell(player: Player) -> void:
	var index: int = player.slot.index
	# Rausfallen: Platscher im Wasser und starkes Wackeln (D56)
	Fx.burst(&"splash", Vector3(player.global_position.x, -5.4, player.global_position.z))
	Fx.shake(Fx.SHAKE_STRONG)
	Sfx.play(&"splash", player.global_position)
	lives[index] = int(lives[index]) - 1
	player.set_active(false)
	var source: InputSource = player.slot.source
	source.rumble(0.8, 0.8, 0.35)
	if lives[index] <= 0:
		eliminated.append(index)
		hud.show_message("%s ist raus!" % player.slot.display_name, 1.5)
		Sfx.play(&"eliminated")
		Announcer.say(&"bad_luck", {"player": player.slot.display_name}, 0.6)
	else:
		_respawn_timers[index] = respawn_delay
	_update_hud()


func _respawn(player: Player) -> void:
	var spot: Vector3 = Vector3(rng.randf_range(-2.5, 2.5), 2.0, rng.randf_range(-2.5, 2.5))
	player.set_active(true)
	player.respawn(spot)
	var scooter := player.get_node("ScooterAbility") as ScooterAbility
	scooter.reset(Vector3.BACK)
	player.face(Vector3.BACK)


func _alive() -> Array[int]:
	var result: Array[int] = []
	for slot: PlayerSlot in context.slots:
		if not eliminated.has(slot.index):
			result.append(slot.index)
	return result


## Rangliste: Überlebende nach Leben, dann Ausgeschiedene in umgekehrter Reihenfolge.
func _ranking() -> MinigameResult:
	var groups: Array = []
	var alive: Array[int] = _alive()
	var by_lives: Dictionary = {}
	for index: int in alive:
		var key: int = int(lives[index])
		if not by_lives.has(key):
			by_lives[key] = []
		(by_lives[key] as Array).append(index)
	var keys: Array = by_lives.keys()
	keys.sort()
	keys.reverse()
	for key: int in keys:
		groups.append(by_lives[key])
	for i: int in range(eliminated.size() - 1, -1, -1):
		groups.append([eliminated[i]])
	return MinigameResult.from_ranking(groups)


## Knapp: Am Ende hat der Sieger nur noch ein Leben, oder mehrere teilen sich die meisten Leben.
func was_close() -> bool:
	var alive: Array[int] = _alive()
	if alive.size() == 1:
		return int(lives[alive[0]]) <= 1
	var best: int = 0
	var count: int = 0
	for index: int in alive:
		if int(lives[index]) > best:
			best = int(lives[index])
			count = 1
		elif int(lives[index]) == best:
			count += 1
	return count > 1


func _on_time_up() -> void:
	finish(_ranking())


func _update_hud() -> void:
	for slot: PlayerSlot in context.slots:
		var n: int = int(lives.get(slot.index, 0))
		hud.set_status(slot, "%s  %s" % [slot.get_tag(), ("Leben %d" % n) if n > 0 else "raus"])


# --- Computergegner ---

func _update_ai(player: Player, ai: AIInput, delta: float) -> void:
	var state: Dictionary = _ai_state.get(player.slot.index, {"think": 0.0, "target": Vector3.ZERO})
	state["think"] = float(state["think"]) - delta
	var scooter := player.get_node("ScooterAbility") as ScooterAbility
	if float(state["think"]) <= 0.0:
		state["think"] = AIProfile.reaction_time(context.difficulty)
		var target: Player = _nearest_opponent(player)
		var aim: Vector3 = Vector3.ZERO
		if target != null:
			aim = target.global_position + target.velocity * 0.35
		var error: float = AIProfile.aim_error(context.difficulty)
		aim += Vector3(rng.randf_range(-error, error), 0, rng.randf_range(-error, error))
		state["target"] = aim
	var position_flat := Vector3(player.global_position.x, 0, player.global_position.z)
	var wanted: Vector3 = (state["target"] as Vector3) - position_flat
	# Nicht über die Kante fahren
	if position_flat.length() > arena_radius - 3.5 and scooter.heading.dot(position_flat.normalized()) > 0.2:
		wanted = -position_flat
	if wanted.length() > 0.1:
		ai.move = player.world_to_input(wanted.normalized())
	ai.hold(InputBindings.JUMP, true)
	var aligned: bool = scooter.heading.dot(wanted.normalized()) > 0.93
	if aligned and wanted.length() < 6.0 and scooter.turbo_ready_in <= 0.0 and rng.randf() < AIProfile.skill(context.difficulty) * 0.05:
		ai.tap(InputBindings.PUSH)
	_ai_state[player.slot.index] = state


func _nearest_opponent(player: Player) -> Player:
	var best: Player = null
	var best_distance: float = INF
	for other: Player in players:
		if other == player or eliminated.has(other.slot.index) or not other.visible:
			continue
		var d: float = other.global_position.distance_to(player.global_position)
		if d < best_distance:
			best_distance = d
			best = other
	return best
