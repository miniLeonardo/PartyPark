class_name PlayerVisual
extends Node3D
## Rein optische Lebendigkeit der Knubbelfigur: Stauchen, Strecken, Nachwippen,
## Vorlehnen beim Laufen, Fußwackeln. Beeinflusst die Steuerung nicht (D16).

@export_group("Feder")
## Steifigkeit der Squash-Feder; höher = schnelleres Nachwippen.
@export var spring_stiffness: float = 320.0
## Dämpfung der Feder; niedriger = längeres Wackeln.
@export var spring_damping: float = 11.0
## Wie stark Sprung und Landung strecken bzw. stauchen.
@export var squash_strength: float = 0.18

@export_group("Laufen")
## Vorlehnen bei voller Geschwindigkeit (Grad).
@export var lean_angle_deg: float = 10.0
## Schrittfrequenz der Füße.
@export var step_frequency: float = 14.0
## Hüpfen des Körpers beim Laufen (Meter).
@export var bob_height: float = 0.05

var _stretch: float = 0.0
var _stretch_velocity: float = 0.0
var _roll: float = 0.0
var _roll_velocity: float = 0.0
var _pitch_kick: float = 0.0
var _step_phase: float = 0.0
var _lean: float = 0.0
var _spawn_scale: float = 1.0
var _body_material: Material
var _base_color: Color = Color.WHITE
var _ghosted: bool = false

enum FaceExpression { NORMAL, HAPPY, SHOCKED, SMUG, SAD }

var expression: int = FaceExpression.NORMAL
var _blink_timer: float = 3.0
var _blinking: bool = false
var _blink_duration: float = 0.12
var _look_offset: Vector2 = Vector2.ZERO

@onready var pivot: Node3D = $Pivot
@onready var body: MeshInstance3D = $Pivot/Body
@onready var eye_left: MeshInstance3D = $Pivot/EyeLeft
@onready var eye_right: MeshInstance3D = $Pivot/EyeRight
@onready var pupil_left: MeshInstance3D = $Pivot/EyeLeft/Pupil
@onready var pupil_right: MeshInstance3D = $Pivot/EyeRight/Pupil
@onready var foot_left: MeshInstance3D = $FootLeft
@onready var foot_right: MeshInstance3D = $FootRight
@onready var accessory: Node3D = $Pivot/Accessory
@onready var party_hat: Node3D = $Pivot/Accessory/PartyHat


func _ready() -> void:
	_apply_color()


## Erst nach _ready aufrufen (Player sorgt dafür).
func set_color(color: Color) -> void:
	_base_color = color
	_apply_color()


## Blasse Darstellung, z. B. für Computer-Platzhalter im Beitrittsbildschirm.
func set_ghosted(ghosted: bool) -> void:
	_ghosted = ghosted
	_apply_color()


func _apply_color() -> void:
	var color: Color = _base_color.lerp(Color(0.8, 0.8, 0.82), 0.45) if _ghosted else _base_color
	_body_material = Look.character_material(color)
	body.material_override = _body_material


func play_jump() -> void:
	_stretch_velocity += 6.0 * squash_strength / 0.18


func play_land(fall_speed: float) -> void:
	_stretch_velocity -= clampf(fall_speed, 2.0, 20.0) * 0.6 * squash_strength / 0.18


func play_push() -> void:
	_pitch_kick = -0.5
	_stretch_velocity -= 2.0


func play_hit(impulse: Vector3) -> void:
	# Seitliches Wackeln abhängig von der Trefferrichtung relativ zur Figur.
	var local: Vector3 = global_basis.inverse() * impulse
	_roll_velocity += clampf(local.x, -15.0, 15.0) * 0.9
	_stretch_velocity -= 4.0


## Allgemeiner Squash-Impuls für Effekte (positiv = stauchen, negativ = strecken).
func punch_squash(amount: float) -> void:
	_stretch_velocity -= amount * 8.0


func play_spawn() -> void:
	_spawn_scale = 0.2


func set_expression(expr: int) -> void:
	expression = expr
	_update_face(0.0)


func show_hat(visible_hat: bool) -> void:
	if party_hat:
		party_hat.visible = visible_hat


func play_win_pose() -> void:
	set_expression(FaceExpression.HAPPY)
	_stretch_velocity += 8.0
	show_hat(true)


func play_lose_pose() -> void:
	set_expression(FaceExpression.SAD)
	_stretch_velocity -= 4.0


## Wird jeden Physik-Frame von Player aufgerufen.
func update_motion(speed_ratio: float, on_floor: bool, delta: float) -> void:
	_update_face(delta)
	# Squash-Feder
	_stretch_velocity += (-spring_stiffness * _stretch - spring_damping * _stretch_velocity) * delta
	_stretch = clampf(_stretch + _stretch_velocity * delta, -0.45, 0.45)
	# Seitliche Wackelfeder
	_roll_velocity += (-spring_stiffness * 0.5 * _roll - spring_damping * 0.6 * _roll_velocity) * delta
	_roll = clampf(_roll + _roll_velocity * delta, -0.6, 0.6)
	_pitch_kick = move_toward(_pitch_kick, 0.0, delta * 3.0)
	_spawn_scale = move_toward(_spawn_scale, 1.0, delta * 4.0)

	var walking: float = speed_ratio if on_floor else 0.0
	_lean = lerpf(_lean, speed_ratio, clampf(delta * 10.0, 0.0, 1.0))
	if walking > 0.05:
		_step_phase += delta * step_frequency * clampf(walking, 0.4, 1.0)
	else:
		_step_phase = lerpf(_step_phase, roundf(_step_phase / PI) * PI, clampf(delta * 10.0, 0.0, 1.0))

	var squash: float = _stretch
	var spawn_bounce: float = _spawn_scale
	pivot.scale = Vector3(1.0 - squash * 0.5, 1.0 + squash, 1.0 - squash * 0.5) * spawn_bounce
	pivot.rotation = Vector3(-deg_to_rad(lean_angle_deg) * _lean + _pitch_kick, 0.0, -_roll)
	pivot.position.y = absf(sin(_step_phase)) * bob_height * walking

	var stride: float = 0.16 * walking
	foot_left.position = Vector3(-0.2, 0.08 + maxf(0.0, sin(_step_phase)) * 0.1 * walking, -sin(_step_phase) * stride)
	foot_right.position = Vector3(0.2, 0.08 + maxf(0.0, -sin(_step_phase)) * 0.1 * walking, sin(_step_phase) * stride)
	foot_left.scale = Vector3.ONE * spawn_bounce
	foot_right.scale = Vector3.ONE * spawn_bounce


func _update_face(delta: float) -> void:
	if eye_left == null or eye_right == null or pupil_left == null or pupil_right == null:
		return
	if delta > 0.0:
		_blink_timer -= delta
		if _blink_timer <= 0.0:
			if not _blinking:
				_blinking = true
				_blink_timer = _blink_duration
			else:
				_blinking = false
				_blink_timer = randf_range(2.5, 5.0)

	var blink_scale: float = 0.15 if _blinking and expression != FaceExpression.SHOCKED else 1.0
	var eye_scale := Vector3.ONE
	var pupil_scale := Vector3.ONE
	var pupil_offset := Vector3(0.0, 0.0, -0.09)

	match expression:
		FaceExpression.HAPPY:
			eye_scale = Vector3(1.1, 0.75 * blink_scale, 1.0)
			pupil_offset.y += 0.02
		FaceExpression.SHOCKED:
			eye_scale = Vector3(1.35, 1.35 * blink_scale, 1.1)
			pupil_scale = Vector3(0.65, 0.65, 0.65)
			pupil_offset.z = -0.13
		FaceExpression.SMUG:
			eye_scale = Vector3(1.0, 0.6 * blink_scale, 1.0)
		FaceExpression.SAD:
			eye_scale = Vector3(0.9, 0.8 * blink_scale, 0.9)
			pupil_offset.y -= 0.03
		_:
			eye_scale = Vector3(1.0, blink_scale, 1.0)

	eye_left.scale = eye_scale
	eye_right.scale = eye_scale
	pupil_left.scale = pupil_scale
	pupil_right.scale = pupil_scale
	pupil_left.position = pupil_offset
	pupil_right.position = pupil_offset
