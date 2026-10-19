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
var _body_material: StandardMaterial3D
var _base_color: Color = Color.WHITE
var _ghosted: bool = false

@onready var pivot: Node3D = $Pivot
@onready var body: MeshInstance3D = $Pivot/Body
@onready var foot_left: MeshInstance3D = $FootLeft
@onready var foot_right: MeshInstance3D = $FootRight


func _ready() -> void:
	_body_material = StandardMaterial3D.new()
	_body_material.albedo_color = Color.WHITE
	_body_material.roughness = 0.45
	body.material_override = _body_material


## Erst nach _ready aufrufen (Player sorgt dafür).
func set_color(color: Color) -> void:
	_base_color = color
	_apply_color()


## Blasse Darstellung, z. B. für Computer-Platzhalter im Beitrittsbildschirm.
func set_ghosted(ghosted: bool) -> void:
	_ghosted = ghosted
	_apply_color()


func _apply_color() -> void:
	_body_material.albedo_color = _base_color.lerp(Color(0.8, 0.8, 0.82), 0.45) if _ghosted else _base_color


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


func play_spawn() -> void:
	_spawn_scale = 0.2


## Wird jeden Physik-Frame von Player aufgerufen.
func update_motion(speed_ratio: float, on_floor: bool, delta: float) -> void:
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
