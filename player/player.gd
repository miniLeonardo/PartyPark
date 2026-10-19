class_name Player
extends CharacterBody3D
## Spielfigur (D15, D16): präzise Steuerung, Wackeln nur optisch über PlayerVisual.
## Liest ausschließlich die InputSource ihres Spielerplatzes.

## Ein anderer Spieler hat diese Figur geschubst.
signal was_pushed(by: Player)

const GROUP: StringName = &"players"

@export_group("Laufen")
## Höchstgeschwindigkeit am Boden (m/s).
@export var move_speed: float = 7.0
## Beschleunigung am Boden (m/s²).
@export var ground_acceleration: float = 60.0
## Abbremsen am Boden ohne Eingabe (m/s²).
@export var ground_deceleration: float = 70.0
## Beschleunigung in der Luft (m/s²).
@export var air_acceleration: float = 30.0
## Wie schnell sich die Figur zur Laufrichtung dreht.
@export var turn_speed: float = 16.0

@export_group("Schwerkraft")
@export var gravity: float = 30.0
## Stärkere Schwerkraft beim Fallen für knackigere Sprünge.
@export var fall_gravity_multiplier: float = 1.6
@export var max_fall_speed: float = 30.0

@export_group("Rückstoß")
## Abbau des Rückstoßes am Boden (m/s²).
@export var knockback_friction_ground: float = 20.0
## Abbau des Rückstoßes in der Luft (m/s²).
@export var knockback_friction_air: float = 4.0
## Anteil der Laufkontrolle, solange die Figur nach einem Treffer betäubt ist.
@export_range(0.0, 1.0) var stunned_control: float = 0.15
@export var hit_rumble_strength: float = 0.7

## Waagerechte Bewegung (Minispiele können sie abschalten, Springen bleibt eigene Fähigkeit).
var movement_enabled: bool = true
## Blickrichtung in der Ebene, Länge 1.
var facing: Vector3 = Vector3.FORWARD
var slot: PlayerSlot = null

var _walk: Vector3 = Vector3.ZERO
var _knockback: Vector3 = Vector3.ZERO
var _stun_time: float = 0.0
var _was_on_floor: bool = true
var _abilities: Array[PlayerAbility] = []

@onready var visual: PlayerVisual = $Visual
@onready var tag_label: Label3D = $Tag
@onready var jump_ability: JumpAbility = $JumpAbility
@onready var push_ability: PushAbility = $PushAbility


func _ready() -> void:
	add_to_group(GROUP)
	for child: Node in get_children():
		if child is PlayerAbility:
			_abilities.append(child as PlayerAbility)
	if slot != null:
		_apply_slot()


## Verknüpft die Figur mit einem Spielerplatz (Farbe, Name, Eingabe). Vor oder nach add_child aufrufbar.
func setup(p_slot: PlayerSlot) -> void:
	slot = p_slot
	if is_node_ready():
		_apply_slot()


func get_input() -> InputSource:
	if slot == null:
		return null
	return slot.source


func set_tag_text(text: String) -> void:
	tag_label.text = text


func _apply_slot() -> void:
	visual.set_color(slot.color)
	tag_label.text = slot.get_tag()
	tag_label.modulate = slot.color.lightened(0.3)


func _physics_process(delta: float) -> void:
	var source: InputSource = get_input()
	var move_input: Vector2 = Vector2.ZERO
	if source != null and movement_enabled:
		move_input = source.get_move()
	var direction: Vector3 = _to_world_direction(move_input)
	var on_floor: bool = is_on_floor()

	_stun_time -= delta
	var control: float = stunned_control if _stun_time > 0.0 else 1.0
	var acceleration: float = air_acceleration
	if on_floor:
		acceleration = ground_acceleration if direction != Vector3.ZERO else ground_deceleration
	_walk = _walk.move_toward(direction * move_speed, acceleration * control * delta)

	var friction: float = knockback_friction_ground if on_floor else knockback_friction_air
	_knockback = _knockback.move_toward(Vector3.ZERO, friction * delta)

	if not on_floor:
		var g: float = gravity * (fall_gravity_multiplier if velocity.y < 0.0 else 1.0)
		velocity.y = maxf(velocity.y - g * delta, -max_fall_speed)

	for ability: PlayerAbility in _abilities:
		if ability.enabled:
			ability.physics_update(delta)

	velocity.x = _walk.x + _knockback.x
	velocity.z = _walk.z + _knockback.z

	if direction.length() > 0.1 and _stun_time <= 0.0:
		var target_yaw: float = atan2(-direction.x, -direction.z)
		visual.rotation.y = lerp_angle(visual.rotation.y, target_yaw, clampf(turn_speed * delta, 0.0, 1.0))
		facing = Vector3.FORWARD.rotated(Vector3.UP, visual.rotation.y)

	var fall_speed: float = -velocity.y
	move_and_slide()
	on_floor = is_on_floor()
	if on_floor and not _was_on_floor:
		visual.play_land(fall_speed)
	_was_on_floor = on_floor
	visual.update_motion(Vector2(_walk.x, _walk.z).length() / maxf(move_speed, 0.01), on_floor, delta)


## Fügt waagerechten Rückstoß hinzu (z. B. Ausfallschritt beim Schubsen).
func add_knockback(impulse: Vector3) -> void:
	_knockback += Vector3(impulse.x, 0.0, impulse.z)


## Wird von PushAbility eines anderen Spielers aufgerufen.
func receive_push(impulse: Vector3, lift: float, stun_time: float, by: Player) -> void:
	_knockback = Vector3(impulse.x, 0.0, impulse.z)
	_walk = Vector3.ZERO
	velocity.y = maxf(velocity.y, lift)
	_stun_time = stun_time
	visual.play_hit(impulse)
	var source: InputSource = get_input()
	if source != null:
		source.rumble(0.0, hit_rumble_strength, 0.2)
	was_pushed.emit(by)


## Dreht die Figur sofort in eine Richtung auf der Ebene (z. B. zur Kamera beim Erscheinen).
func face(direction: Vector3) -> void:
	direction.y = 0.0
	if direction.length_squared() < 0.0001:
		return
	facing = direction.normalized()
	visual.rotation.y = atan2(-facing.x, -facing.z)


## Setzt die Figur an eine Position zurück und löscht jede Bewegung.
func respawn(at: Vector3) -> void:
	global_position = at
	velocity = Vector3.ZERO
	_walk = Vector3.ZERO
	_knockback = Vector3.ZERO
	_stun_time = 0.0
	visual.play_spawn()


## Wandelt die Stick-Eingabe relativ zur aktiven Kamera in eine Richtung auf der Ebene um.
func _to_world_direction(move_input: Vector2) -> Vector3:
	if move_input == Vector2.ZERO:
		return Vector3.ZERO
	var forward: Vector3 = Vector3.FORWARD
	var right: Vector3 = Vector3.RIGHT
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera != null:
		var cam_forward: Vector3 = -camera.global_basis.z
		cam_forward.y = 0.0
		if cam_forward.length_squared() > 0.001:
			forward = cam_forward.normalized()
			right = forward.cross(Vector3.UP)
	var world: Vector3 = right * move_input.x + forward * -move_input.y
	return world.limit_length(1.0)
