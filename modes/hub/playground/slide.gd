class_name HubSlide
extends Node3D
## Spielplatz-Rutsche für den Freizeitpark (D104).
## Bietet eine steile Null-Reibungs-Gleitfläche mit voller Trägheitsphysik:
## Spieler beschleunigen rasant bergab und werden am Schanzen-Ende emporgeworfen.

@export var slide_length: float = 12.0
@export var slide_height: float = 6.0
@export var slide_width: float = 2.4

var _sliding_players: Array[Player] = []


func _ready() -> void:
	_build_structure()
	_build_trigger()


func _physics_process(delta: float) -> void:
	for player: Player in _sliding_players:
		if not is_instance_valid(player):
			continue
		# Hangabtriebskraft in Rutschrichtung (-Z)
		var forward := -global_transform.basis.z.normalized()
		player.velocity.x += forward.x * 22.0 * delta
		player.velocity.z += forward.z * 22.0 * delta
		player.velocity.y = minf(player.velocity.y, -4.0)

		# Leichtes Gegenlenken über Eingabe erlauben (D104)
		var source: InputSource = player.get_input()
		if source != null:
			var move: Vector2 = source.get_move()
			var steer_side := global_transform.basis.x.normalized()
			player.velocity += steer_side * (move.x * 12.0 * delta)

		if Engine.get_physics_frames() % 6 == 0:
			Fx.burst(&"dust", player.global_position, Color("#42a5f5"), 0.5)


func _build_structure() -> void:
	var plastic_mat: Material = Look.surface(Color("#00a8ff"), Look.Kind.GLOSSY)
	var wood_mat: Material = Look.surface(Color("#a67c52"), Look.Kind.WOOD)
	var steel_mat: Material = Look.surface(Color("#d1d8e0"), Look.Kind.METAL)

	# 1. Start-Turm / Podest oben
	var tower := StageKit.add_box(self, Vector3(slide_width + 1.2, slide_height, slide_width + 1.2), Vector3(0, slide_height * 0.5, slide_length * 0.5), Color("#8c6239"), Vector3.ZERO, Look.Kind.WOOD)
	tower.name = "SlideTower"

	# Leiter / Treppenstufen zum Turm
	var steps: int = 8
	for i: int in steps:
		var step_y: float = (slide_height / float(steps)) * float(i + 1)
		var step_z: float = slide_length * 0.5 + 1.2 + float(i) * 0.4
		StageKit.add_box(self, Vector3(slide_width, 0.25, 0.5), Vector3(0, step_y - 0.12, step_z), Color("#c49a6c"), Vector3.ZERO, Look.Kind.WOOD)

	# 2. Rutschbahn (Schiefe Ebene mit Seitenwangen)
	var angle_rad: float = atan2(slide_height - 0.4, slide_length)
	var ramp_length: float = sqrt((slide_height - 0.4) * (slide_height - 0.4) + slide_length * slide_length)

	var ramp_body := StageKit.add_box(
		self,
		Vector3(slide_width, 0.3, ramp_length),
		Vector3(0, slide_height * 0.5, 0),
		Color("#00a8ff"),
		Vector3(rad_to_deg(angle_rad), 0, 0),
		Look.Kind.GLOSSY
	)
	ramp_body.name = "RampSurface"

	# Seitenwangen (Schutzborde links & rechts)
	for side: float in [-slide_width * 0.5, slide_width * 0.5]:
		var border := StageKit.add_box(
			self,
			Vector3(0.2, 0.7, ramp_length),
			Vector3(side, slide_height * 0.5 + 0.3, 0),
			Color("#ffd75e"),
			Vector3(rad_to_deg(angle_rad), 0, 0),
			Look.Kind.PLASTIC
		)
		border.name = "SlideBorder"

	# 3. Schanze / Auslauf am Ende (bei Z = -slide_length * 0.5)
	var ramp_exit := StageKit.add_box(
		self,
		Vector3(slide_width, 0.35, 2.2),
		Vector3(0, 0.3, -slide_length * 0.5 - 1.0),
		Color("#ff5d73"),
		Vector3(-14.0, 0, 0),
		Look.Kind.PLASTIC
	)
	ramp_exit.name = "RampExit"


func _build_trigger() -> void:
	var area := Area3D.new()
	area.name = "SlideTrigger"
	area.collision_mask = 1 # Players
	add_child(area)

	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(slide_width + 0.4, slide_height + 1.0, slide_length + 2.0)
	shape.shape = box
	shape.position = Vector3(0, slide_height * 0.5 + 0.5, 0)
	area.add_child(shape)

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	var player := body as Player
	if player != null and not _sliding_players.has(player):
		_sliding_players.append(player)
		Sfx.play(&"turbo", global_position, 0.0, 1.3)


func _on_body_exited(body: Node3D) -> void:
	var player := body as Player
	if player != null and _sliding_players.has(player):
		_sliding_players.erase(player)
		# Schanzen-Katapult am Ende der Rutsche
		var forward := -global_transform.basis.z.normalized()
		player.launch(8.0, forward * 16.0)
		Sfx.play(&"jump", global_position, 0.0, 1.2)
		Fx.burst(&"dust", player.global_position, Color("#ff5d73"), 1.0)
