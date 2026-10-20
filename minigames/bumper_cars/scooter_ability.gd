class_name ScooterAbility
extends PlayerAbility
## Autoscooter-Steuerung (D34): Stick lenkt, A gibt Gas, X ist ein kurzer Turbo-Rempler.
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


func _ready() -> void:
	super._ready()
	player.was_pushed.connect(_on_was_pushed)


func reset(new_heading: Vector3) -> void:
	heading = new_heading.normalized()
	speed = 0.0
	_turbo_time = 0.0


func physics_update(delta: float) -> void:
	var source: InputSource = player.get_input()
	var move: Vector2 = source.get_move() if source != null else Vector2.ZERO
	var wanted: Vector3 = player.input_to_world(move)
	if wanted.length() > 0.2 and not player.is_stunned():
		var angle: float = heading.signed_angle_to(wanted.normalized(), Vector3.UP)
		var max_turn: float = deg_to_rad(turn_speed_deg) * delta
		heading = heading.rotated(Vector3.UP, clampf(angle, -max_turn, max_turn)).normalized()
	turbo_ready_in -= delta
	if source != null and source.just_pressed(InputBindings.PUSH) and turbo_ready_in <= 0.0:
		_turbo_time = turbo_duration
		turbo_ready_in = turbo_cooldown
		player.visual.play_push()
		source.rumble(0.4, 0.0, 0.15)
		Fx.burst(&"dust", player.global_position - heading * 0.9 + Vector3.UP * 0.3, Color(0, 0, 0, 0), 0.8)
		Sfx.play(&"turbo", player.global_position)
	var gas: bool = source != null and source.is_down(InputBindings.JUMP)
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
		var strength: float = clampf(closing * bump_factor, min_bump, max_bump)
		other.receive_push(direction * strength, 2.5, 0.35, player)
		player.add_knockback(-direction * strength * 0.25)
		speed *= 0.35
		_bump_cooldowns[other.get_instance_id()] = 0.35
		var source: InputSource = player.get_input()
		if source != null:
			source.rumble(0.5, 0.2, 0.15)
		bumped.emit(other, strength)


## Läuft gerade ein Turbo-Rempler?
func is_turbo() -> bool:
	return _turbo_time > 0.0


func _on_was_pushed(_by: Player) -> void:
	speed *= 0.3
	_turbo_time = 0.0
