class_name ScooterAbility
extends PlayerAbility
## Autoscooter-Steuerung (D34): Stick lenkt, A (oder RB) gibt Gas, X (oder B) ist ein kurzer Turbo-Rempler.
## Setzt Player.drive_velocity; Zusammenstöße schubsen andere Scooter weg.

signal bumped(other: Player, strength: float)

@export var max_speed: float = 9.0
@export var acceleration: float = 14.0
## Abbremsen ohne Gas (m/s²).
@export var coast_friction: float = 5.0
## Wendigkeit in Grad pro Sekunde.
@export var turn_speed_deg: float = 220.0
@export var turbo_speed: float = 17.0
@export var turbo_duration: float = 0.35
@export var turbo_cooldown: float = 2.0
## Rempelstärke im Verhältnis zur Aufprallgeschwindigkeit.
@export var bump_factor: float = 1.15
@export var min_bump: float = 6.0
@export var max_bump: float = 22.0

var heading: Vector3 = Vector3.FORWARD
var speed: float = 0.0
var turbo_ready_in: float = 0.0

var _turbo_time: float = 0.0
var _bump_cooldowns: Dictionary = {}
## Turbo-Ring unter dem Wagen (D128): wächst beim Aufladen, leuchtet, wenn der Turbo bereit ist.
var _turbo_ring: MeshInstance3D
var _turbo_material: StandardMaterial3D


func _ready() -> void:
	super._ready()
	player.was_pushed.connect(_on_was_pushed)
	_build_turbo_ring()


func _build_turbo_ring() -> void:
	_turbo_material = StandardMaterial3D.new()
	_turbo_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_turbo_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_turbo_ring = MeshInstance3D.new()
	_turbo_ring.name = "TurboRing"
	var torus := TorusMesh.new()
	torus.inner_radius = 1.05
	torus.outer_radius = 1.25
	torus.rings = 32
	torus.ring_segments = 6
	_turbo_ring.mesh = torus
	_turbo_ring.material_override = _turbo_material
	_turbo_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_turbo_ring.position.y = 0.05
	player.add_child.call_deferred(_turbo_ring)


func _update_turbo_ring() -> void:
	if _turbo_ring == null:
		return
	var charge: float = clampf(1.0 - turbo_ready_in / maxf(turbo_cooldown, 0.01), 0.0, 1.0)
	if charge >= 1.0:
		var pulse: float = 0.75 + 0.25 * sin(Time.get_ticks_msec() * 0.012)
		_turbo_material.albedo_color = Color(1.0, 0.85, 0.2, pulse)
		_turbo_ring.scale = Vector3.ONE
	else:
		_turbo_material.albedo_color = Color(0.6, 0.6, 0.65, 0.45)
		_turbo_ring.scale = Vector3(lerpf(0.45, 0.95, charge), 1.0, lerpf(0.45, 0.95, charge))


func reset(new_heading: Vector3) -> void:
	heading = new_heading.normalized()
	speed = 0.0
	_turbo_time = 0.0


func physics_update(delta: float) -> void:
	_update_turbo_ring()
	var source: InputSource = player.get_input()
	var move: Vector2 = source.get_move() if source != null else Vector2.ZERO
	var wanted: Vector3 = player.input_to_world(move)
	if wanted.length() > 0.2 and not player.is_stunned():
		var angle: float = heading.signed_angle_to(wanted.normalized(), Vector3.UP)
		var max_turn: float = deg_to_rad(turn_speed_deg) * delta
		heading = heading.rotated(Vector3.UP, clampf(angle, -max_turn, max_turn)).normalized()
	turbo_ready_in -= delta
	var turbo_pressed: bool = source != null and (source.just_pressed(InputBindings.PUSH) or source.just_pressed(InputBindings.ACTION) or (source.is_down(InputBindings.TRIGGER) and source.just_pressed(InputBindings.JUMP)))
	if turbo_pressed and turbo_ready_in <= 0.0:
		_turbo_time = turbo_duration
		turbo_ready_in = turbo_cooldown
		player.visual.play_push()
		source.rumble(0.4, 0.0, 0.15)
		Fx.burst(&"dust", player.global_position - heading * 0.9 + Vector3.UP * 0.3, Color(0, 0, 0, 0), 0.8)
		Sfx.play(&"turbo", player.global_position)
	var gas: bool = source != null and (source.is_down(InputBindings.TRIGGER) or source.is_down(InputBindings.JUMP))
	if _turbo_time > 0.0:
		_turbo_time -= delta
		speed = maxf(speed, turbo_speed)
	elif gas:
		speed = move_toward(speed, max_speed, acceleration * delta) if speed <= max_speed else move_toward(speed, max_speed, coast_friction * 2.0 * delta)
	else:
		speed = move_toward(speed, 0.0, coast_friction * delta)
	player.drive_velocity = heading * speed
	player.facing = heading
	player.visual.rotation.y = atan2(-heading.x, -heading.z)


func post_move_update(delta: float) -> void:
	for key: Variant in _bump_cooldowns.keys():
		_bump_cooldowns[key] = float(_bump_cooldowns[key]) - delta
		if _bump_cooldowns[key] <= 0.0:
			_bump_cooldowns.erase(key)
	for i: int in player.get_slide_collision_count():
		var collision: KinematicCollision3D = player.get_slide_collision(i)
		var other := collision.get_collider() as Player
		if other == null:
			if absf(collision.get_normal().y) < 0.5 and speed > 3.0:
				# Bande: abprallen
				var normal: Vector3 = collision.get_normal()
				normal.y = 0.0
				heading = heading.bounce(normal.normalized()).normalized()
				speed *= 0.5
			continue
		if _bump_cooldowns.has(other.get_instance_id()):
			continue
		var direction: Vector3 = other.global_position - player.global_position
		direction.y = 0.0
		if direction.length_squared() < 0.0001:
			continue
		direction = direction.normalized()
		var other_velocity: Vector3 = other.velocity
		other_velocity.y = 0.0
		var closing: float = (heading * speed).dot(direction) - other_velocity.dot(direction)
		if closing < 1.5:
			continue
		# Zusammenstoß beidseitig auflösen: Jeder schubst den anderen mit seinem eigenen Tempo in dessen Richtung.
		# Vorher schubste nur, wessen Bewegung die Kollision zuerst meldete (immer die niedrigere Platznummer),
		# sodass Frontalzusammenstöße systematisch Spieler 1 gewann.
		var other_scooter := other.get_node_or_null("ScooterAbility") as ScooterAbility
		var my_push: float = maxf((heading * speed).dot(direction), 0.0)
		var their_push: float = 0.0
		if other_scooter != null:
			their_push = maxf((other_scooter.heading * other_scooter.speed).dot(-direction), 0.0)
		else:
			my_push = closing
		var strength: float = clampf(my_push * bump_factor, min_bump, max_bump)
		other.receive_push(direction * strength, 2.5, 0.35, player)
		player.add_knockback(-direction * strength * 0.25)
		speed *= 0.35
		_bump_cooldowns[other.get_instance_id()] = 0.35
		var source: InputSource = player.get_input()
		if source != null:
			source.rumble(0.5, 0.2, 0.15)
		bumped.emit(other, strength)
		if other_scooter != null:
			other_scooter._bump_cooldowns[player.get_instance_id()] = 0.35
			if their_push > 1.5:
				var counter: float = clampf(their_push * bump_factor, min_bump, max_bump)
				player.receive_push(-direction * counter, 2.5, 0.35, other)
				other.add_knockback(direction * counter * 0.25)
				other_scooter.speed *= 0.35
				other_scooter.bumped.emit(player, counter)


## Läuft gerade ein Turbo-Rempler?
func is_turbo() -> bool:
	return _turbo_time > 0.0


func _on_was_pushed(_by: Player) -> void:
	speed *= 0.3
	_turbo_time = 0.0
