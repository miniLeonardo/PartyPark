class_name HubCarousel
extends Node3D
## Begehbares Rummel-Karussell für den Freizeitpark (D105).
## Dreht sich kontinuierlich und erzeugt spürbare Zentrifugalkraft:
## Spieler spüren die Fliehkraft nach außen und können sich Duelle liefern.

@export var radius: float = 5.5
@export var rotation_speed: float = 1.25

var _rotating_root: Node3D
var _platform_body: AnimatableBody3D
var _riding_players: Array[Player] = []


func _ready() -> void:
	_build_carousel()
	_build_trigger()


func _physics_process(delta: float) -> void:
	var rot_delta: float = rotation_speed * delta
	if _rotating_root != null:
		_rotating_root.rotate_y(rot_delta)
	if _platform_body != null:
		_platform_body.rotate_y(rot_delta)

	# Fliehkraft auf mitfahrende Figuren anwenden (D105)
	for player: Player in _riding_players:
		if not is_instance_valid(player):
			continue
		var to_player := player.global_position - global_position
		to_player.y = 0.0
		var dist: float = to_player.length()

		if dist > 0.4:
			var outward := to_player.normalized()
			# Zentrifugalkraft = omega² * r
			var cent_force: float = rotation_speed * rotation_speed * dist
			player.velocity += outward * (cent_force * 0.65 * delta)

			# Tangential-Mitnahme
			var tangent := Vector3(-outward.z, 0.0, outward.x)
			player.velocity += tangent * (rotation_speed * dist * 0.25 * delta)


func _build_carousel() -> void:
	_rotating_root = Node3D.new()
	_rotating_root.name = "RotatingRoot"
	add_child(_rotating_root)

	var frame_mat: Material = Look.surface(Color("#f0ede6"), Look.Kind.WOOD)
	var floor_mat: Material = Look.surface(Color("#ff5d73"), Look.Kind.PLASTIC)
	var gold_mat: Material = Look.surface(Color("#ffd75e"), Look.Kind.METAL)
	var roof_mat: Material = Look.surface(Color("#8e44ad"), Look.Kind.FABRIC)

	# 1. Drehscheiben-Boden (AnimatableBody3D für solide physikalische Mitnahme)
	_platform_body = AnimatableBody3D.new()
	_platform_body.name = "CarouselFloor"
	_platform_body.sync_to_physics = true
	add_child(_platform_body)

	var cyl_mesh := CylinderMesh.new()
	cyl_mesh.top_radius = radius
	cyl_mesh.bottom_radius = radius
	cyl_mesh.height = 0.4
	cyl_mesh.radial_segments = 32

	var floor_mesh := MeshInstance3D.new()
	floor_mesh.mesh = cyl_mesh
	floor_mesh.material_override = floor_mat
	floor_mesh.position = Vector3(0, 0.2, 0)
	_platform_body.add_child(floor_mesh)

	var floor_col := CollisionShape3D.new()
	var col_shape := CylinderShape3D.new()
	col_shape.radius = radius
	col_shape.height = 0.4
	floor_col.shape = col_shape
	floor_col.position = Vector3(0, 0.2, 0)
	_platform_body.add_child(floor_col)

	# 2. Zentrale Ziersäule
	var center_post := MeshInstance3D.new()
	var post_mesh := CylinderMesh.new()
	post_mesh.top_radius = 0.8
	post_mesh.bottom_radius = 1.1
	post_mesh.height = 4.2
	center_post.mesh = post_mesh
	center_post.material_override = gold_mat
	center_post.position = Vector3(0, 2.1, 0)
	center_post.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_rotating_root.add_child(center_post)

	# 3. Baldachin / Karussell-Dach oben
	var roof := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.2
	cone.bottom_radius = radius + 0.4
	cone.height = 1.8
	roof.mesh = cone
	roof.material_override = roof_mat
	roof.position = Vector3(0, 4.8, 0)
	_rotating_root.add_child(roof)

	# 4. Haltestangen mit Reittieren / Sitzen
	var seat_count: int = 6
	for i: int in seat_count:
		var angle: float = TAU * float(i) / float(seat_count)
		var pole_pos := Vector3(cos(angle) * (radius * 0.65), 2.2, sin(angle) * (radius * 0.65))

		var pole := MeshInstance3D.new()
		var p_cyl := CylinderMesh.new()
		p_cyl.top_radius = 0.06
		p_cyl.bottom_radius = 0.06
		p_cyl.height = 3.6
		pole.mesh = p_cyl
		pole.material_override = gold_mat
		pole.position = pole_pos
		pole.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_rotating_root.add_child(pole)

		# Sitzplatz / bunte Kapsel
		var seat := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.9, 0.7, 1.4)
		seat.mesh = box
		var colors: Array[Color] = [Color("#ffcf3f"), Color("#41c7a9"), Color("#5aa8ff"), Color("#ff5d73")]
		seat.material_override = Look.surface(colors[i % colors.size()], Look.Kind.PLASTIC)
		seat.position = Vector3(pole_pos.x, 0.9, pole_pos.z)
		seat.rotation.y = angle + PI * 0.5
		_rotating_root.add_child(seat)


func _build_trigger() -> void:
	var area := Area3D.new()
	area.name = "CarouselTrigger"
	area.collision_mask = 1 # Players
	add_child(area)

	var shape := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = radius + 0.2
	cyl.height = 3.5
	shape.shape = cyl
	shape.position = Vector3(0, 2.0, 0)
	area.add_child(shape)

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	var player := body as Player
	if player != null and not _riding_players.has(player):
		_riding_players.append(player)


func _on_body_exited(body: Node3D) -> void:
	var player := body as Player
	if player != null and _riding_players.has(player):
		_riding_players.erase(player)
