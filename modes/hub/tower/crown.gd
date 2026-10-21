class_name HubCrown
extends Node3D
## Goldene Siegerkrone für den Kletterturm (D100, D108).
## Schwebt auf der Turmspitze. Wird sie getragen und der Träger geschubst,
## fliegt sie in weitem Bogen davon und kann von jedem im Gerangel neu aufgesammelt werden.

enum State { FLOATING, WORN, DROPPED }

@export var summit_home_position: Vector3 = Vector3(0.0, 20.8, -36.0)

var current_state: int = State.FLOATING
var wearer: Player = null

var _velocity: Vector3 = Vector3.ZERO
var _pickup_delay: float = 0.0
var _crown_mesh: MeshInstance3D
var _bob_timer: float = 0.0


func _ready() -> void:
	_build_visuals()
	_build_trigger()
	global_position = summit_home_position


func _physics_process(delta: float) -> void:
	_bob_timer += delta

	match current_state:
		State.FLOATING:
			rotate_y(1.5 * delta)
			position.y = summit_home_position.y + sin(_bob_timer * 3.0) * 0.15

		State.WORN:
			if is_instance_valid(wearer):
				global_position = wearer.global_position + Vector3(0.0, 1.7 * wearer.body_scale, 0.0)
				rotation.y = wearer.visual.rotation.y
				if Engine.get_physics_frames() % 15 == 0:
					Fx.burst(&"stars", global_position + Vector3(0, 0.2, 0), Color("#ffd75e"), 0.5)
			else:
				reset_to_summit()

		State.DROPPED:
			if _pickup_delay > 0.0:
				_pickup_delay -= delta

			# Physik-Bogenflug mit Schwerkraft & Bodenabprall
			_velocity.y -= 25.0 * delta
			global_position += _velocity * delta
			rotate_x(6.0 * delta)
			rotate_y(4.0 * delta)

			# Bodenkontakt prüfen (einfacher Sweep gegen Y = 0.3)
			if global_position.y <= 0.3:
				global_position.y = 0.3
				if absf(_velocity.y) > 2.0:
					_velocity.y = -_velocity.y * 0.45
					_velocity.x *= 0.7
					_velocity.z *= 0.7
					Sfx.play(&"bump", global_position, 0.0, 1.4)
				else:
					_velocity = Vector3.ZERO

			# Falls sie ins Leere fällt: Zurück zur Turmspitze
			if global_position.y < -4.0 or global_position.length() > 50.0:
				reset_to_summit()


func _build_visuals() -> void:
	var gold_mat: Material = Look.surface(Color("#ffd75e"), Look.Kind.METAL)
	var jewel_mat: Material = Look.surface(Color("#e74c3c"), Look.Kind.GLOSSY)

	_crown_mesh = MeshInstance3D.new()
	var ring := TorusMesh.new()
	ring.inner_radius = 0.32
	ring.outer_radius = 0.48
	ring.rings = 24
	ring.ring_segments = 6
	_crown_mesh.mesh = ring
	_crown_mesh.material_override = gold_mat
	add_child(_crown_mesh)

	# 5 Kronenzacken mit roten Juwelen
	for i: int in 5:
		var angle: float = TAU * float(i) / 5.0
		var pos := Vector3(cos(angle) * 0.4, 0.18, sin(angle) * 0.4)

		var spike := MeshInstance3D.new()
		var cone := CylinderMesh.new()
		cone.top_radius = 0.02
		cone.bottom_radius = 0.1
		cone.height = 0.35
		spike.mesh = cone
		spike.material_override = gold_mat
		spike.position = pos
		spike.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_crown_mesh.add_child(spike)

		var jewel := MeshInstance3D.new()
		var orb := SphereMesh.new()
		orb.radius = 0.06
		orb.height = 0.12
		jewel.mesh = orb
		jewel.material_override = jewel_mat
		jewel.position = pos + Vector3(0, 0.18, 0)
		jewel.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_crown_mesh.add_child(jewel)


func _build_trigger() -> void:
	var area := Area3D.new()
	area.name = "CrownTrigger"
	area.collision_mask = 1 # Players
	add_child(area)

	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 1.2
	shape.shape = sphere
	area.add_child(shape)

	area.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	var player := body as Player
	if player == null:
		return

	if current_state == State.FLOATING:
		attach_to_player(player)
	elif current_state == State.DROPPED and _pickup_delay <= 0.0:
		attach_to_player(player)


func attach_to_player(player: Player) -> void:
	if wearer != null and wearer.was_pushed.is_connected(_on_wearer_pushed):
		wearer.was_pushed.disconnect(_on_wearer_pushed)

	wearer = player
	current_state = State.WORN
	_velocity = Vector3.ZERO
	rotation = Vector3.ZERO

	if not wearer.was_pushed.is_connected(_on_wearer_pushed):
		wearer.was_pushed.connect(_on_wearer_pushed)

	Sfx.play(&"sparkle", global_position, 0.0, 1.2)
	Fx.burst(&"stars", global_position, Color("#ffd75e"), 1.2)

	var source: InputSource = player.get_input()
	if source != null:
		source.rumble(0.2, 0.5, 0.25)


func _on_wearer_pushed(by: Player) -> void:
	drop_from_push(by)


## Wird aufgerufen, wenn der Träger geschubst wird (D108: Physikalischer Kronenabwurf).
func drop_from_push(by: Player) -> void:
	if current_state != State.WORN or wearer == null:
		return

	if wearer.was_pushed.is_connected(_on_wearer_pushed):
		wearer.was_pushed.disconnect(_on_wearer_pushed)

	var push_dir := Vector3.FORWARD
	if is_instance_valid(by):
		push_dir = (wearer.global_position - by.global_position).normalized()
	push_dir.y = 0.0
	if push_dir.length_squared() < 0.01:
		push_dir = Vector3.BACK

	wearer = null
	current_state = State.DROPPED
	_pickup_delay = 0.4 # Kurze Zeitspanne, damit sie erst wegfliegt

	# Weit wegschleudern
	_velocity = push_dir * 10.0 + Vector3.UP * 9.0

	Sfx.play(&"slip", global_position, 0.0, 1.2)
	Fx.burst(&"dust", global_position, Color("#ffd75e"), 0.8)


func reset_to_summit() -> void:
	if wearer != null and wearer.was_pushed.is_connected(_on_wearer_pushed):
		wearer.was_pushed.disconnect(_on_wearer_pushed)
	wearer = null
	current_state = State.FLOATING
	_velocity = Vector3.ZERO
	global_position = summit_home_position
	rotation = Vector3.ZERO
