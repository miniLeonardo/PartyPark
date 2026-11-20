class_name HubSlide
extends Node3D
## Spielplatz-Rutsche für den Freizeitpark (D104).
## Treppe hinauf zum Podest (+Z), Bahn fällt nach -Z ab, am Ende wirft eine Schanze die Figur hoch.
## Auf der Bahn wird die Figur immer schneller (über Player.push_velocity, weil die Figur ihre
## waagerechte Geschwindigkeit jedes Bild selbst neu setzt).

@export var slide_length: float = 12.0
@export var slide_height: float = 6.0
@export var slide_width: float = 2.4
## Beschleunigung auf der Bahn (m/s²) und Höchsttempo (m/s).
@export var slide_acceleration: float = 14.0
@export var slide_max_speed: float = 15.0
## Absprung an der Schanze: Aufwärtstempo (m/s) und Anteil des Rutschtempos nach vorne.
@export var jump_up_speed: float = 8.0
@export_range(0.0, 1.5) var jump_carry: float = 0.9

var _ramp: StaticBody3D
var _kicker: StaticBody3D
var _inside: Array[Player] = []
## Spieler → aktuelles Rutschtempo (m/s).
var _speed: Dictionary = {}


func _ready() -> void:
	_build_structure()
	_build_trigger()


func _physics_process(delta: float) -> void:
	var forward: Vector3 = -global_basis.z
	forward.y = 0.0
	forward = forward.normalized()
	for player: Player in _inside:
		if not is_instance_valid(player):
			continue
		var floor_body: Object = player.get_floor_collider()
		if floor_body == _ramp or floor_body == _kicker:
			var speed: float = minf(float(_speed.get(player, 2.0)) + slide_acceleration * delta, slide_max_speed)
			_speed[player] = speed
			player.push_velocity += forward * speed
			if Engine.get_physics_frames() % 6 == 0:
				Fx.burst(&"dust", player.global_position, Color("#42a5f5"), 0.5)
		elif _speed.has(player):
			if floor_body == null and to_local(player.global_position).z < -slide_length * 0.5:
				# Über die Schanze hinaus: Katapult
				var speed: float = float(_speed[player])
				player.launch(jump_up_speed, forward * speed * jump_carry)
				Sfx.play(&"jump", player.global_position, 0.0, 1.2)
				Fx.burst(&"dust", player.global_position, Color("#ff5d73"), 1.0)
			_speed.erase(player)


func _build_structure() -> void:
	var top_z: float = slide_length * 0.5 - 1.8
	# 1. Podest oben (spannt z von top_z bis top_z + 3.6)
	var platform_depth: float = slide_width + 1.2
	var tower := StageKit.add_box(self, Vector3(platform_depth, slide_height, platform_depth), Vector3(0, slide_height * 0.5, top_z + platform_depth * 0.5), Color("#8c6239"), Vector3.ZERO, Look.Kind.WOOD)
	tower.name = "SlideTower"

	# Treppe hinter dem Podest: 16 Stufen à 37,5 cm, die höchste grenzt an das Podest (begehbar mit Stufenhilfe)
	var steps: int = 16
	var rise: float = slide_height / float(steps)
	var back_z: float = top_z + platform_depth
	for i: int in steps:
		var top: float = rise * float(i + 1)
		var z: float = back_z + 0.25 + float(steps - 1 - i) * 0.5
		StageKit.add_box(self, Vector3(slide_width, top, 0.5), Vector3(0, top * 0.5, z), Color("#c49a6c"), Vector3.ZERO, Look.Kind.WOOD)

	# 2. Bahn: von der Podestkante (top_z, Höhe slide_height) hinab bis z = -slide_length/2 auf 0.4 m
	var end_z: float = -slide_length * 0.5
	var drop: float = slide_height - 0.4
	var run: float = top_z - end_z
	var angle_deg: float = rad_to_deg(atan2(drop, run))
	var ramp_length: float = sqrt(drop * drop + run * run)
	var thickness: float = 0.3
	var center := Vector3(0, (slide_height + 0.4) * 0.5 - thickness * 0.5, (top_z + end_z) * 0.5)
	# Negative Neigung um X hebt das +Z-Ende an (zum Podest)
	_ramp = StageKit.add_box(self, Vector3(slide_width, thickness, ramp_length + 0.2), center, Color("#00a8ff"), Vector3(-angle_deg, 0, 0), Look.Kind.GLOSSY)
	_ramp.name = "RampSurface"
	for side: float in [-slide_width * 0.5 - 0.1, slide_width * 0.5 + 0.1]:
		var border := StageKit.add_box(self, Vector3(0.2, 0.7, ramp_length), center + Vector3(side, 0.35, 0), Color("#ffd75e"), Vector3(-angle_deg, 0, 0), Look.Kind.PLASTIC)
		border.name = "SlideBorder"

	# 3. Schanze am Ende, steigt nach -Z leicht an
	_kicker = StageKit.add_box(self, Vector3(slide_width, 0.35, 2.2), Vector3(0, 0.4, end_z - 1.0), Color("#ff5d73"), Vector3(14.0, 0, 0), Look.Kind.PLASTIC)
	_kicker.name = "RampExit"


func _build_trigger() -> void:
	var area := Area3D.new()
	area.name = "SlideTrigger"
	area.collision_mask = 1 # Players
	add_child(area)

	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(slide_width + 2.0, slide_height + 3.0, slide_length + 8.0)
	shape.shape = box
	shape.position = Vector3(0, slide_height * 0.5 + 1.0, -1.5)
	area.add_child(shape)

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	var player := body as Player
	if player != null and not _inside.has(player):
		_inside.append(player)


func _on_body_exited(body: Node3D) -> void:
	var player := body as Player
	if player != null:
		_inside.erase(player)
		_speed.erase(player)
