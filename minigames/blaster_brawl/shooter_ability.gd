class_name ShooterAbility
extends PlayerAbility
## Ego-Steuerung (D72): linker Stick läuft relativ zur Blickrichtung, rechter Stick dreht und neigt
## den Blick. Ohne zweiten Stick (Tastatur-Debug) dreht links/rechts, vor/zurück läuft.
## Leichte Zielhilfe: Liegt ein Gegner nahe am Fadenkreuz, dreht der Blick langsamer.

## Höchste Drehgeschwindigkeit seitlich und hoch/runter (Grad pro Sekunde).
@export var yaw_speed_deg: float = 170.0
@export var pitch_speed_deg: float = 110.0
@export var max_pitch_deg: float = 60.0
## Zielhilfe: Winkel um das Fadenkreuz und Bremsfaktor der Drehung.
@export var assist_angle_deg: float = 7.0
@export var assist_slowdown: float = 0.45
@export var move_speed: float = 6.5
@export var acceleration: float = 45.0
## Augenhöhe über den Füßen (Meter).
@export var eye_height: float = 1.2

var yaw: float = 0.0
var pitch: float = 0.0
## Liefert true, wenn ein Gegner nahe am Fadenkreuz liegt (vom Minispiel gesetzt).
var assist_check: Callable = Callable()

var _velocity: Vector3 = Vector3.ZERO


func reset(facing: Vector3) -> void:
	yaw = atan2(-facing.x, -facing.z)
	pitch = 0.0
	_velocity = Vector3.ZERO


## Blickrichtung (Länge 1) inklusive Neigung.
func get_look_direction() -> Vector3:
	return Vector3.FORWARD.rotated(Vector3.RIGHT, pitch).rotated(Vector3.UP, yaw)


func get_eye_position() -> Vector3:
	return player.global_position + Vector3.UP * eye_height


func physics_update(delta: float) -> void:
	var source: InputSource = player.get_input()
	var move: Vector2 = source.get_move() if source != null else Vector2.ZERO
	var aim: Vector2 = source.get_aim() if source != null else Vector2.ZERO
	var has_stick: bool = source != null and source.has_aim_stick()
	if not has_stick:
		# Tastatur: links/rechts dreht, vor/zurück läuft
		aim = Vector2(move.x, 0.0)
		move = Vector2(0.0, move.y)
	var factor: float = 1.0
	if assist_check.is_valid() and bool(assist_check.call(player)):
		factor = assist_slowdown
	# Quadratische Kennlinie für feines Zielen
	var curved := Vector2(aim.x * absf(aim.x), aim.y * absf(aim.y))
	yaw -= deg_to_rad(yaw_speed_deg) * curved.x * factor * delta
	pitch = clampf(pitch - deg_to_rad(pitch_speed_deg) * curved.y * factor * delta, -deg_to_rad(max_pitch_deg), deg_to_rad(max_pitch_deg))
	var forward := Vector3.FORWARD.rotated(Vector3.UP, yaw)
	var right := Vector3.RIGHT.rotated(Vector3.UP, yaw)
	var wanted: Vector3 = (right * move.x - forward * move.y) * move_speed
	if player.is_stunned():
		wanted *= 0.2
	_velocity = _velocity.move_toward(wanted, acceleration * delta)
	player.drive_velocity = _velocity
	player.facing = forward
	player.visual.rotation.y = yaw
