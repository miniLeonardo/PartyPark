extends Minigame
## Tauziehen (D35), 2 gegen 2: A im Takt zieht, beide Teammitglieder im selben Takt geben Synchronbonus,
## Fehldruck lässt kurz ausrutschen. Wer die Markierung über die eigene Linie zieht, gewinnt.
## D53: Synchrontakte füllen den Kraftbalken des Teams; voll löst Y einen großen Ruck aus.

## Abstand zwischen zwei Takten am Anfang und am Ende (Sekunden); der Takt wird schneller.
@export var beat_interval_start: float = 0.8
@export var beat_interval_end: float = 0.55
## Toleranz um den Takt herum (Sekunden).
@export var hit_window: float = 0.13
## Seilweg pro Treffer und Zusatz bei Synchronität (Meter).
@export var pull_per_hit: float = 0.16
@export var sync_bonus: float = 0.08
## Sieg, sobald die Markierung so weit von der Mitte entfernt ist (Meter).
@export var win_distance: float = 3.0
## Sperre nach einem Fehldruck (Sekunden).
@export var slip_time: float = 0.6

@export_group("Kraftakt (D53)")
## Synchrontakte, bis der Kraftbalken voll ist (Platzhalter).
@export var power_charge_needed: int = 4
## Seilweg des Kraftakts (Meter).
@export var power_pull: float = 0.6

@export_group("Seil-Optik")
## Federhärte und Dämpfung, mit der das Seil dem Zielwert folgt (schwingt leicht nach).
@export var rope_stiffness: float = 45.0
@export var rope_damping: float = 7.0

var rope_x: float = 0.0

var _rope_target: float = 0.0
var _rope_velocity: float = 0.0
var _rope_wobble: float = 0.0
var _rope: Node3D
var _rope_mesh: MeshInstance3D
## Kraftbalken je Team (Index 0 und 1).
var _team_charge: Array[int] = [0, 0]
var _debug_power_count: int = 0
var _beat_ring: BeatRing
var _last_beat: float = -10.0
var _next_beat: float = 0.0
var _beat_id: int = 0
## Beat-ID → Array[int] der Platzindizes, die diesen Takt getroffen haben.
var _hits: Dictionary = {}
var _slipped_until: Dictionary = {}
var _feedback_timers: Dictionary = {}
var _ai_press_at: Dictionary = {}
var _ai_planned_beat: Dictionary = {}


func _init() -> void:
	time_limit = 30.0


func _build_arena() -> void:
	super._build_arena()
	StageKit.add_box(self, Vector3(30, 1, 8), Vector3(0, -0.5, 0), Color("#7cc66a"))
	# Schlammgrube in der Mitte (nur Optik)
	var mud: StaticBody3D = StageKit.add_box(self, Vector3(2.4, 0.05, 7.6), Vector3(0, 0.02, 0), Color("#6b4a2b"))
	mud.get_child(1).queue_free()
	for side: int in [-1, 1]:
		var team: int = 0 if side < 0 else 1
		var line: StaticBody3D = StageKit.add_box(self, Vector3(0.25, 0.05, 7.6), Vector3(side * win_distance, 0.03, 0), TeamFormat.TEAM_COLORS[team])
		line.get_child(1).queue_free()
	_rope = Node3D.new()
	add_child(_rope)
	var rope_mesh := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.06
	cylinder.bottom_radius = 0.06
	cylinder.height = 22.0
	rope_mesh.mesh = cylinder
	rope_mesh.rotation_degrees = Vector3(0, 0, 90)
	rope_mesh.position = Vector3(0, 0.95, 0)
	rope_mesh.material_override = StageKit.make_material(Color("#d9b77a"))
	_rope.add_child(rope_mesh)
	_rope_mesh = rope_mesh
	var flag := MeshInstance3D.new()
	var flag_mesh := BoxMesh.new()
	flag_mesh.size = Vector3(0.15, 0.7, 0.5)
	flag.mesh = flag_mesh
	flag.position = Vector3(0, 0.55, 0)
	flag.material_override = StageKit.make_material(Color("#e0262f"))
	_rope.add_child(flag)
	var camera := Camera3D.new()
	camera.fov = 45.0
	add_child(camera)
	camera.position = Vector3(0, 10, 15)
	camera.look_at(Vector3(0, 0.6, 0), Vector3.UP)
	camera.current = true


func _spawn_position(_i: int, slot: PlayerSlot) -> Vector3:
	return _stand_position(slot.index, 0.0) + Vector3.UP * 0.2


func _spawn_facing(_i: int, slot: PlayerSlot) -> Vector3:
	return Vector3.RIGHT if context.team_of(slot.index) == 0 else Vector3.LEFT


func _configure_player(player: Player, _slot: PlayerSlot) -> void:
	player.movement_enabled = false
	player.jump_ability.enabled = false
	player.push_ability.enabled = false


func _after_setup() -> void:
	_beat_ring = BeatRing.new()
	hud.add_child(_beat_ring)
	_beat_ring.position = Vector2(960.0 - _beat_ring.custom_minimum_size.x * 0.5, 150.0)
	_update_hud()


func _on_round_started() -> void:
	_next_beat = beat_interval_start
	_last_beat = -10.0


func _stand_position(index: int, rope: float) -> Vector3:
	var team: int = context.team_of(index)
	var members: Array[int] = context.team_members(team)
	var k: int = members.find(index)
	var side: float = -1.0 if team == 0 else 1.0
	# Jedes Team steht hinter seiner Linie, die Grube liegt dazwischen
	return Vector3(rope + side * (win_distance + 0.9 + 1.3 * float(k)), 0.0, 0.3 if k % 2 == 0 else -0.3)


func _current_interval() -> float:
	var t: float = clampf(elapsed / maxf(time_limit, 1.0), 0.0, 1.0)
	return lerpf(beat_interval_start, beat_interval_end, t)


func _round_process(delta: float) -> void:
	if elapsed >= _next_beat:
		_last_beat = _next_beat
		_next_beat += _current_interval()
		_beat_id += 1
		_beat_ring.pulse()
		Sfx.play(&"beat", Vector3.INF, -6.0)
	var span: float = maxf(_next_beat - _last_beat, 0.01)
	_beat_ring.progress = clampf((elapsed - _last_beat) / span, 0.0, 1.0) if _last_beat > -5.0 else clampf(elapsed / _next_beat, 0.0, 1.0)
	for player: Player in players:
		var source: InputSource = player.get_input()
		if source != null and source.just_pressed(InputBindings.JUMP):
			_on_press(player)
		if source != null and source.just_pressed(InputBindings.SPECIAL):
			_on_power(player)
	# Seil folgt dem Ziel wie eine Feder und schwingt leicht nach
	_rope_velocity += ((_rope_target - rope_x) * rope_stiffness - _rope_velocity * rope_damping) * delta
	rope_x += _rope_velocity * delta
	_rope.position.x = rope_x
	_rope_wobble = move_toward(_rope_wobble, 0.0, delta * 1.5)
	_rope_mesh.position.y = 0.95 + sin(elapsed * 38.0) * 0.12 * _rope_wobble
	for player: Player in players:
		var stand: Vector3 = _stand_position(player.slot.index, rope_x)
		player.global_position = Vector3(stand.x, player.global_position.y, stand.z)
	_tick_feedback(delta)
	if _rope_target <= -win_distance:
		_finish_team(0)
	elif _rope_target >= win_distance:
		_finish_team(1)


func _on_press(player: Player) -> void:
	var index: int = player.slot.index
	if elapsed < float(_slipped_until.get(index, -1.0)):
		return
	# Nächstgelegenen Takt bestimmen: der gerade vergangene (ID _beat_id) oder der kommende (ID _beat_id + 1)
	var to_last: float = absf(elapsed - _last_beat)
	var to_next: float = absf(_next_beat - elapsed)
	var beat: int = _beat_id if to_last <= to_next else _beat_id + 1
	var offset: float = minf(to_last, to_next)
	var hits: Array = _hits.get(beat, [])
	if offset > hit_window or hits.has(index):
		_slipped_until[index] = elapsed + slip_time
		player.visual.play_hit(Vector3(0, 0, 4))
		Fx.burst(&"dust", player.global_position + Vector3.UP * 0.2, Color(0, 0, 0, 0), 0.7)
		Sfx.play(&"slip", player.global_position)
		_feedback(player, "Daneben!")
		return
	hits.append(index)
	_hits[beat] = hits
	var team: int = context.team_of(index)
	var direction: float = -1.0 if team == 0 else 1.0
	var amount: float = pull_per_hit
	var synced: bool = false
	for other: int in hits:
		if other != index and context.team_of(other) == team:
			synced = true
	if synced:
		amount += sync_bonus
		if _team_charge[team] < power_charge_needed:
			_team_charge[team] += 1
			if _team_charge[team] >= power_charge_needed:
				hud.show_message("%s: Kraftakt bereit!" % context.team_name(team, info), 1.2)
	_rope_target += direction * amount
	_rope_wobble = maxf(_rope_wobble, 0.35 if synced else 0.2)
	player.visual.play_land(6.0)
	# Schlammspritzer bei jedem Zug, größer bei Synchronität (D53)
	Fx.burst(&"mud", player.global_position + Vector3.UP * 0.1, Color(0, 0, 0, 0), 1.0 if synced else 0.6)
	Sfx.play(&"pull", player.global_position)
	if synced:
		Sfx.play(&"sync", player.global_position)
	var source: InputSource = player.slot.source
	source.rumble(0.25 if not synced else 0.5, 0.0, 0.08)
	_feedback(player, "Synchron!" if synced else "Zug!")
	_update_hud()


## Kraftakt (D53): nur mit vollem Teambalken, auch während des Ausrutschens nicht.
func _on_power(player: Player) -> void:
	var index: int = player.slot.index
	var team: int = context.team_of(index)
	if _team_charge[team] < power_charge_needed or elapsed < float(_slipped_until.get(index, -1.0)):
		return
	_team_charge[team] = 0
	_debug_power_count += 1
	var direction: float = -1.0 if team == 0 else 1.0
	_rope_target += direction * power_pull
	_rope_velocity += direction * 4.0
	_rope_wobble = 1.0
	for member: int in context.team_members(team):
		var mate: Player = get_player(member)
		mate.visual.play_land(14.0)
		mate.slot.source.rumble(0.6, 0.6, 0.25)
		_feedback(mate, "KRAFTAKT!")
	hud.show_message("KRAFTAKT!", 1.0)
	Fx.shake(Fx.SHAKE_MEDIUM)
	Sfx.play(&"power", Vector3(rope_x, 0.5, 0.0))
	Fx.burst(&"mud", Vector3(rope_x, 0.2, 0.0), Color(0, 0, 0, 0), 1.8)
	_update_hud()


## Knapp: Zeit ist abgelaufen und die Markierung lag nahe der Mitte.
func was_close() -> bool:
	return elapsed >= time_limit - 0.1 and absf(_rope_target) < 1.0


## Für den Smoke-Test `--smoke-games`.
func debug_summary() -> String:
	return "Seil %.2f m, Kraftakte %d" % [_rope_target, _debug_power_count]


func _feedback(player: Player, text: String) -> void:
	player.set_tag_text(text)
	_feedback_timers[player.slot.index] = 0.5


func _tick_feedback(delta: float) -> void:
	for index: int in _feedback_timers.keys():
		_feedback_timers[index] = float(_feedback_timers[index]) - delta
		if _feedback_timers[index] <= 0.0:
			_feedback_timers.erase(index)
			var player: Player = get_player(index)
			player.set_tag_text(player.slot.get_tag())


func _finish_team(winner_team: int) -> void:
	var loser_team: int = 1 - winner_team
	for index: int in context.team_members(loser_team):
		var player: Player = get_player(index)
		var toward_center: float = 1.0 if loser_team == 0 else -1.0
		player.receive_push(Vector3(toward_center * 9.0, 0, 0), 6.0, 1.0, null)
	Fx.burst(&"mud", Vector3(rope_x, 0.2, 0.0), Color(0, 0, 0, 0), 2.0)
	Sfx.play(&"mud", Vector3(rope_x, 0.2, 0.0))
	finish(MinigameResult.team_win(context.team_members(winner_team), context.team_members(loser_team)))


func _on_time_up() -> void:
	if _rope_target < -0.3:
		_finish_team(0)
	elif _rope_target > 0.3:
		_finish_team(1)
	else:
		finish(MinigameResult.draw(context.indices()))


func _update_hud() -> void:
	var meters: float = absf(_rope_target)
	var leader: String = "Gleichstand"
	if _rope_target < -0.05:
		leader = "Team Orange vorn"
	elif _rope_target > 0.05:
		leader = "Team Lila vorn"
	hud.set_info("rope", "%s (%.1f m)" % [leader, meters])
	for team: int in 2:
		var charge: int = _team_charge[team]
		var bar: String = "■".repeat(charge) + "□".repeat(maxi(0, power_charge_needed - charge))
		var text: String = "Kraftakt bereit!" if charge >= power_charge_needed else "Kraft %s" % bar
		hud.set_info("power%d" % team, text, context.team_color(team))


# --- Computergegner ---

func _update_ai(player: Player, ai: AIInput, _delta: float) -> void:
	var index: int = player.slot.index
	var upcoming: int = _beat_id + 1
	var pending: Array = _ai_press_at.get(index, [])
	if int(_ai_planned_beat.get(index, -1)) != upcoming:
		_ai_planned_beat[index] = upcoming
		if rng.randf() < AIProfile.skill(context.difficulty) + 0.15:
			var sigma: float = AIProfile.timing_sigma(context.difficulty)
			pending.append(_next_beat + rng.randfn(0.0, sigma) - 1.0 / 60.0)
	if not pending.is_empty() and elapsed >= float(pending[0]):
		pending.pop_front()
		ai.tap(InputBindings.JUMP)
	# Kraftakt: nicht sofort, sondern nach kurzer Reaktionszeit zufällig
	var team: int = context.team_of(index)
	if _team_charge[team] >= power_charge_needed and rng.randf() < AIProfile.skill(context.difficulty) * 0.04:
		ai.tap(InputBindings.SPECIAL)
	_ai_press_at[index] = pending
