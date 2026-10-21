class_name HubSeesaw
extends Node3D
## Physikalische Spielplatz-Wippe für den Park (D106).
## Reagiert dynamisch auf das Gewicht und die Position der Spieler auf dem Balken,
## kippt bis zu 22 Grad und federt in die Ruhelage zurück.

@export var plank_length: float = 8.0
@export var plank_width: float = 2.0
@export var max_tilt_deg: float = 22.0

var _plank_body: AnimatableBody3D
var _current_tilt: float = 0.0
var _tilt_velocity: float = 0.0
var _standing_players: Array[Player] = []


func _ready() -> void:
	_build_seesaw()
	_build_trigger()


func _physics_process(delta: float) -> void:
	# Gewichts-Drehmoment der anwesenden Spieler berechnen
	var torque: float = 0.0
	for player: Player in _standing_players:
		if not is_instance_valid(player):
			continue
		var local_p := to_local(player.global_position)
		# Z-Position auf dem Balken bestimmt Hebelarm
		torque += local_p.z * 1.8

	var target_tilt: float = clampf(deg_to_rad(torque * 3.5), -deg_to_rad(max_tilt_deg), deg_to_rad(max_tilt_deg))

	# Feder-Dämpfer-Berechnung für sauberes Schwingen
	var spring_force: float = (target_tilt - _current_tilt) * 18.0
	_tilt_velocity += spring_force * delta
	_tilt_velocity *= exp(-4.5 * delta) # Dämpfung
	_current_tilt += _tilt_velocity * delta

	if _plank_body != null:
		_plank_body.rotation.x = _current_tilt


func _build_seesaw() -> void:
	var wood_mat: Material = Look.surface(Color("#c29057"), Look.Kind.WOOD)
	var metal_mat: Material = Look.surface(Color("#7f8c8d"), Look.Kind.METAL)
	var bumper_mat: Material = Look.surface(Color("#e74c3c"), Look.Kind.RUBBER)

	# 1. Mittel-Stütze (Dreieck / Prisma-Lager)
	var stand := MeshInstance3D.new()
	var prism := PrismMesh.new()
	prism.size = Vector3(plank_width * 0.9, 1.2, 0.8)
	stand.mesh = prism
	stand.material_override = metal_mat
	stand.position = Vector3(0, 0.6, 0)
	stand.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(stand)

	# 2. Wipp-Balken (AnimatableBody3D für solide Spieler-Mitnahme)
	_plank_body = AnimatableBody3D.new()
	_plank_body.name = "Plank"
	_plank_body.position = Vector3(0, 1.25, 0)
	_plank_body.sync_to_physics = true
	add_child(_plank_body)

	var plank_mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(plank_width, 0.22, plank_length)
	plank_mesh.mesh = box
	plank_mesh.material_override = wood_mat
	_plank_body.add_child(plank_mesh)

	var plank_shape := CollisionShape3D.new()
	var col_box := BoxShape3D.new()
	col_box.size = Vector3(plank_width, 0.22, plank_length)
	plank_shape.shape = col_box
	_plank_body.add_child(plank_shape)

	# Gummipuffer an den Enden
	for side: float in [-1.0, 1.0]:
		var pad := MeshInstance3D.new()
		var p_box := BoxMesh.new()
		p_box.size = Vector3(plank_width * 0.8, 0.16, 0.4)
		pad.mesh = p_box
		pad.material_override = bumper_mat
		pad.position = Vector3(0, -0.15, side * (plank_length * 0.5 - 0.2))
		pad.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_plank_body.add_child(pad)


func _build_trigger() -> void:
	var area := Area3D.new()
	area.name = "SeesawTrigger"
	area.collision_mask = 1 # Players
	add_child(area)

	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(plank_width + 0.4, 2.5, plank_length + 0.4)
	shape.shape = box
	shape.position = Vector3(0, 2.0, 0)
	area.add_child(shape)

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	var player := body as Player
	if player != null and not _standing_players.has(player):
		_standing_players.append(player)


func _on_body_exited(body: Node3D) -> void:
	var player := body as Player
	if player != null and _standing_players.has(player):
		_standing_players.erase(player)
