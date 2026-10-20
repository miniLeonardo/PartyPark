extends Minigame
## Wackelwaben (D70), Jeder gegen jeden: drei sechseckige Ebenen aus Waben übereinander, darunter Wasser.
## Jede betretene Wabe wackelt kurz und fällt. Wer ins Wasser fällt, ist raus; der Letzte gewinnt.
## Nach Zeitablauf gewinnt, wer am höchsten steht.

@export_group("Arena")
@export var levels: int = 3
## Ringe um die Mittelwabe (5 Ringe = 91 Waben je Ebene, D73).
@export var rings: int = 5
## Umkreisradius einer Wabe (Meter) und Fuge dazwischen.
@export var hex_size: float = 1.25
@export var hex_gap: float = 0.08
@export var hex_height: float = 0.5
## Höhenabstand der Ebenen (Meter).
@export var level_spacing: float = 6.0
## Darunter gilt eine Figur als im Wasser.
@export var water_height: float = -2.5
@export var level_colors: Array[Color] = [Color("#4fb3bf"), Color("#f2c14e"), Color("#f78154")]

@export_group("Waben")
## So lange wackelt eine betretene Wabe, bevor sie fällt (Sekunden, D70).
@export var wobble_time: float = 0.6
@export var fall_time: float = 0.9

@export_group("Computer")
## Abstand, in dem Computer nach der nächsten freien Wabe suchen (Meter).
@export var ai_search_radius: float = 7.0

const STATE_INTACT: int = 0
const STATE_WOBBLE: int = 1
const STATE_FALLING: int = 2
const STATE_GONE: int = 3

## Platzindizes in der Reihenfolge des Ausscheidens.
var eliminated: Array[int] = []
var tiles: Array[Dictionary] = []

var _hex_mesh: CylinderMesh
var _hex_shape: ConvexPolygonShape3D
var _level_materials: Array[StandardMaterial3D] = []
var _warning_material: StandardMaterial3D
var _ai_state: Dictionary = {}
## (Ebene, q, r) → Wabenindex
var _lookup: Dictionary = {}
var _last_elimination_time: float = -100.0
var _debug_times: Array[float] = []
var _debug_level_drops: int = 0


func _init() -> void:
	time_limit = 90.0


func _build_arena() -> void:
	super._build_arena()
	_hex_mesh = CylinderMesh.new()
	_hex_mesh.radial_segments = 6
	_hex_mesh.rings = 1
	_hex_mesh.top_radius = hex_size - hex_gap
	_hex_mesh.bottom_radius = hex_size - hex_gap
	_hex_mesh.height = hex_height
	_hex_shape = ConvexPolygonShape3D.new()
	var points := PackedVector3Array()
	for i: int in 6:
		var angle: float = TAU * float(i) / 6.0
		var corner := Vector3(sin(angle), 0.0, cos(angle)) * (hex_size - hex_gap)
		points.append(corner + Vector3.UP * hex_height * 0.5)
		points.append(corner - Vector3.UP * hex_height * 0.5)
	_hex_shape.points = points
	for color: Color in level_colors:
		_level_materials.append(StageKit.make_material(color))
	_warning_material = StageKit.make_material(Color("#e8e8e8"))
	_warning_material.emission_enabled = true
	_warning_material.emission = Color("#ff5a3c")
	_warning_material.emission_energy_multiplier = 0.6
	for level: int in levels:
		var y: float = float(level) * level_spacing
		for q: int in range(-rings, rings + 1):
			for r: int in range(maxi(-rings, -q - rings), mini(rings, -q + rings) + 1):
				_lookup[Vector3i(level, q, r)] = tiles.size()
				_add_tile(level, _axial_to_world(q, r) + Vector3.UP * (y - hex_height * 0.5))
	# Wasser
	var water := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(120, 120)
	water.mesh = plane
	water.position.y = water_height - 2.0
	var water_material := StageKit.make_material(Color("#3f8fd6"))
	water_material.roughness = 0.3
	water.material_override = water_material
	add_child(water)
	var camera := ArenaCamera.new()
	camera.pitch_deg = 58.0
	camera.min_distance = 20.0
	camera.max_distance = 36.0
	camera.ignore_below_height = water_height
	add_child(camera)
	camera.current = true


func _axial_to_world(q: int, r: int) -> Vector3:
	# Spitze Seite zeigt nach ±Z (passt zur Ecke der CylinderMesh bei Winkel 0)
	return Vector3(hex_size * sqrt(3.0) * (float(q) + float(r) * 0.5), 0.0, hex_size * 1.5 * float(r))


func _add_tile(level: int, at: Vector3) -> void:
	var body := StaticBody3D.new()
	body.position = at
	var shape := CollisionShape3D.new()
	shape.shape = _hex_shape
	body.add_child(shape)
	var mesh := MeshInstance3D.new()
	mesh.mesh = _hex_mesh
	mesh.material_override = _level_materials[level % _level_materials.size()]
	body.add_child(mesh)
	add_child(body)
	body.set_meta(&"tile_index", tiles.size())
	tiles.append({"body": body, "mesh": mesh, "shape": shape, "level": level, "state": STATE_INTACT, "timer": 0.0, "base": at})


func _spawn_position(i: int, _slot: PlayerSlot) -> Vector3:
	var count: int = maxi(2, context.slots.size())
	var angle: float = TAU * float(i) / float(count) + PI * 0.25
	var top: float = float(levels - 1) * level_spacing
	return Vector3(sin(angle) * hex_size * 3.0, top + 0.3, cos(angle) * hex_size * 3.0)


func _spawn_facing(i: int, slot: PlayerSlot) -> Vector3:
	return -_spawn_position(i, slot) * Vector3(1, 0, 1)


func _round_process(delta: float) -> void:
	for player: Player in players:
		var index: int = player.slot.index
		if eliminated.has(index):
			continue
		if player.global_position.y < water_height:
			_on_fell(player)
			continue
		# Nur die Wabe direkt unter der Figurmitte zählt, nicht die Nachbarn an der Fuge
		var under: int = _tile_under(player)
		if under >= 0:
			_trigger(under)
	_update_tiles(delta)
	var alive: Array[int] = _alive()
	if alive.size() <= 1 and context.slots.size() > 1:
		finish(_ranking())


func _trigger(tile_index: int) -> void:
	var tile: Dictionary = tiles[tile_index]
	if int(tile["state"]) != STATE_INTACT:
		return
	tile["state"] = STATE_WOBBLE
	tile["timer"] = wobble_time
	(tile["mesh"] as MeshInstance3D).material_override = _warning_material
	Sfx.play(&"tile_crack", tile["base"], -6.0)


func _update_tiles(delta: float) -> void:
	for tile: Dictionary in tiles:
		var state: int = int(tile["state"])
		if state == STATE_WOBBLE:
			tile["timer"] = float(tile["timer"]) - delta
			var mesh := tile["mesh"] as MeshInstance3D
			mesh.position = Vector3(rng.randf_range(-0.06, 0.06), 0.0, rng.randf_range(-0.06, 0.06))
			if float(tile["timer"]) <= 0.0:
				tile["state"] = STATE_FALLING
				tile["timer"] = 0.0
				(tile["shape"] as CollisionShape3D).set_deferred("disabled", true)
				mesh.position = Vector3.ZERO
				Fx.burst(&"dust", tile["base"], level_colors[int(tile["level"]) % level_colors.size()], 0.7)
				Sfx.play(&"tile_fall", tile["base"], -8.0)
		elif state == STATE_FALLING:
			tile["timer"] = float(tile["timer"]) + delta
			var t: float = float(tile["timer"]) / fall_time
			var body := tile["body"] as StaticBody3D
			body.position = (tile["base"] as Vector3) + Vector3.DOWN * 9.0 * t * t
			body.scale = Vector3.ONE * lerpf(1.0, 0.4, t)
			if t >= 1.0:
				tile["state"] = STATE_GONE
				body.visible = false


func _on_fell(player: Player) -> void:
	var index: int = player.slot.index
	eliminated.append(index)
	_last_elimination_time = elapsed
	_debug_times.append(snappedf(elapsed, 0.1))
	player.set_active(false)
	player.slot.source.rumble(0.8, 0.8, 0.35)
	Fx.burst(&"splash", Vector3(player.global_position.x, water_height - 2.0, player.global_position.z))
	Fx.shake(Fx.SHAKE_STRONG)
	Sfx.play(&"splash", player.global_position)
	Sfx.play(&"eliminated")
	hud.show_message("%s ist raus!" % player.slot.display_name, 1.5)
	Announcer.say(&"bad_luck", {"player": player.slot.display_name}, 0.6)
	_update_hud()


func _alive() -> Array[int]:
	var result: Array[int] = []
	for slot: PlayerSlot in context.slots:
		if not eliminated.has(slot.index):
			result.append(slot.index)
	return result


## Rangliste: Überlebende nach Ebene (höher ist besser), dann Ausgeschiedene in umgekehrter Reihenfolge.
func _ranking() -> MinigameResult:
	var groups: Array = []
	var by_level: Dictionary = {}
	for index: int in _alive():
		var level: int = roundi(get_player(index).global_position.y / level_spacing)
		if not by_level.has(level):
			by_level[level] = []
		(by_level[level] as Array).append(index)
	var keys: Array = by_level.keys()
	keys.sort()
	keys.reverse()
	for key: int in keys:
		groups.append(by_level[key])
	for i: int in range(eliminated.size() - 1, -1, -1):
		groups.append([eliminated[i]])
	return MinigameResult.from_ranking(groups)


func _on_time_up() -> void:
	finish(_ranking())


## Knapp: Der Vorletzte fiel erst in den letzten 3 Sekunden, oder mehrere teilen sich den Sieg.
func was_close() -> bool:
	return _alive().size() > 1 or elapsed - _last_elimination_time < 3.0


func _after_setup() -> void:
	_update_hud()


func _update_hud() -> void:
	for slot: PlayerSlot in context.slots:
		hud.set_status(slot, "%s  %s" % [slot.get_tag(), "raus" if eliminated.has(slot.index) else "dabei"])


## Für den Smoke-Test `--smoke-games`.
func debug_summary() -> String:
	var gone: int = 0
	for tile: Dictionary in tiles:
		if int(tile["state"]) != STATE_INTACT:
			gone += 1
	return "Waben %d, betreten %d, raus nach %s s" % [tiles.size(), gone, str(_debug_times)]


# --- Computergegner ---

func _update_ai(player: Player, ai: AIInput, delta: float) -> void:
	var index: int = player.slot.index
	var state: Dictionary = _ai_state.get(index, {"think": 0.0, "target": -1})
	state["think"] = float(state["think"]) - delta
	var target_index: int = int(state["target"])
	var need_new: bool = target_index < 0 or int(tiles[target_index]["state"]) != STATE_INTACT
	if not need_new:
		var flat: Vector3 = (tiles[target_index]["base"] as Vector3) - player.global_position
		flat.y = 0.0
		need_new = flat.length() < 0.7
	if need_new or float(state["think"]) <= 0.0:
		state["think"] = AIProfile.reaction_time(context.difficulty) * 2.0
		state["target"] = _pick_tile(player, target_index)
	target_index = int(state["target"])
	# Sparsam laufen: auf der eigenen Wabe bleiben, bis sie gleich fällt (geübte Spieler machen das auch)
	var under: int = _tile_under(player)
	if under >= 0 and player.is_on_floor() and int(tiles[under]["state"]) == STATE_WOBBLE and float(tiles[under]["timer"]) > lerpf(0.35, 0.2, AIProfile.skill(context.difficulty)):
		ai.move = Vector2.ZERO
		_ai_state[index] = state
		return
	if target_index >= 0:
		var aim: Vector3 = tiles[target_index]["base"]
		ai_steer_to(player, ai, aim, AIProfile.speed(context.difficulty))
		var flat_distance: float = Vector2(aim.x - player.global_position.x, aim.z - player.global_position.z).length()
		# Über eine Lücke springen, wenn das Ziel weiter weg ist
		if player.is_on_floor() and flat_distance > 2.4 and rng.randf() < 0.03 * AIProfile.skill(context.difficulty):
			ai.tap(InputBindings.JUMP)
	else:
		ai.move = Vector2.ZERO
	# Schubsen, wenn jemand direkt vor einem steht
	for other: Player in players:
		if other == player or eliminated.has(other.slot.index):
			continue
		var offset: Vector3 = other.global_position - player.global_position
		if absf(offset.y) < 1.0 and Vector2(offset.x, offset.z).length() < 1.5 and rng.randf() < AIProfile.skill(context.difficulty) * 0.01:
			ai.tap(InputBindings.PUSH)
			break
	_ai_state[index] = state


## Wabe, auf der die Figur steht (aus Position berechnet, auch im Stillstand zuverlässig), sonst -1.
func _tile_under(player: Player) -> int:
	if not player.is_on_floor():
		return -1
	var p: Vector3 = player.global_position
	var level: int = roundi(p.y / level_spacing)
	if absf(p.y - float(level) * level_spacing) > 0.4:
		return -1
	# Weltposition → axiale Koordinaten (spitze Seite nach ±Z), dann runden
	var qf: float = (sqrt(3.0) / 3.0 * p.x - p.z / 3.0) / hex_size
	var rf: float = (2.0 / 3.0 * p.z) / hex_size
	var sf: float = -qf - rf
	var q: int = roundi(qf)
	var r: int = roundi(rf)
	var s_round: int = roundi(sf)
	var dq: float = absf(float(q) - qf)
	var dr: float = absf(float(r) - rf)
	var ds: float = absf(float(s_round) - sf)
	if dq > dr and dq > ds:
		q = -r - s_round
	elif dr > ds:
		r = -q - s_round
	return int(_lookup.get(Vector3i(level, q, r), -1))


## Nächste freie Wabe auf der eigenen Ebene, bevorzugt weg von anderen Figuren.
func _pick_tile(player: Player, current: int) -> int:
	var level: int = roundi((player.global_position.y + hex_height) / level_spacing)
	var best: int = -1
	var best_score: float = INF
	for i: int in tiles.size():
		var tile: Dictionary = tiles[i]
		if int(tile["level"]) != level or int(tile["state"]) != STATE_INTACT or i == current:
			continue
		var offset: Vector3 = (tile["base"] as Vector3) - player.global_position
		offset.y = 0.0
		var distance: float = offset.length()
		if distance < 0.9 or distance > ai_search_radius:
			continue
		var crowd: float = 0.0
		for other: Player in players:
			if other != player and not eliminated.has(other.slot.index):
				crowd += 4.0 / maxf(0.5, (tile["base"] as Vector3).distance_to(other.global_position))
		var score: float = absf(distance - hex_size * 1.8) + crowd + rng.randf() * 0.8
		if score < best_score:
			best_score = score
			best = i
	return best
