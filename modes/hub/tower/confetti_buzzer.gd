class_name HubConfettiBuzzer
extends Node3D
## Konfetti-Buzzer auf der Turmspitze (D100).
## Ein riesiger roter Buzzer-Knopf, der bei Betreten Konfetti regnen lässt
## und eine Siegesfanfare abspielt.

var _button_mesh: MeshInstance3D
var _cooldown: float = 0.0
var _is_pressed: bool = false


func _ready() -> void:
	_build_visuals()
	_build_trigger()


func _physics_process(delta: float) -> void:
	if _cooldown > 0.0:
		_cooldown -= delta


func _build_visuals() -> void:
	var base_mat: Material = Look.surface(Color("#f0ede6"), Look.Kind.STONE)
	var ring_mat: Material = Look.surface(Color("#ffd75e"), Look.Kind.METAL)
	var red_mat: Material = Look.surface(Color("#e74c3c"), Look.Kind.GLOSSY)

	# 1. Sockel
	var base := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 1.2
	cyl.bottom_radius = 1.4
	cyl.height = 0.5
	base.mesh = cyl
	base.material_override = base_mat
	base.position = Vector3(0, 0.25, 0)
	add_child(base)

	# Goldener Ring
	var trim := MeshInstance3D.new()
	var trim_geo := TorusMesh.new()
	trim_geo.inner_radius = 1.15
	trim_geo.outer_radius = 1.28
	trim_geo.rings = 24
	trim_geo.ring_segments = 6
	trim.mesh = trim_geo
	trim.material_override = ring_mat
	trim.position = Vector3(0, 0.5, 0)
	trim.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(trim)

	# 2. Roter Druckknopf (Pilzkappe)
	_button_mesh = MeshInstance3D.new()
	var cap := CylinderMesh.new()
	cap.top_radius = 1.05
	cap.bottom_radius = 1.05
	cap.height = 0.35
	_button_mesh.mesh = cap
	_button_mesh.material_override = red_mat
	_button_mesh.position = Vector3(0, 0.65, 0)
	add_child(_button_mesh)


func _build_trigger() -> void:
	var area := Area3D.new()
	area.name = "BuzzerTrigger"
	area.collision_mask = 1 # Players
	add_child(area)

	var shape := CollisionShape3D.new()
	var cyl_shape := CylinderShape3D.new()
	cyl_shape.radius = 1.15
	cyl_shape.height = 0.6
	shape.shape = cyl_shape
	shape.position = Vector3(0, 0.7, 0)
	area.add_child(shape)

	area.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	var player := body as Player
	if player == null or _cooldown > 0.0:
		return

	_cooldown = 1.8
	_trigger_buzzer(player)


func _trigger_buzzer(player: Player) -> void:
	# Knopf-Animation (Eindrücken & Zurückfedern)
	var tween := create_tween()
	tween.tween_property(_button_mesh, "position:y", 0.45, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(_button_mesh, "position:y", 0.65, 0.25).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	# Konfetti & Jubel
	Fx.burst(&"confetti", global_position + Vector3.UP * 1.5, Color.WHITE, 1.8)
	Fx.burst(&"stars", global_position + Vector3.UP * 1.0, Color("#ffd75e"), 1.2)
	Fx.shake(0.3)
	Sfx.play(&"win", global_position, 0.0, 1.1)

	Announcer.say(&"win", {"player": "Spieler %d" % (player.slot.index + 1)}, 0.9)

	var source: InputSource = player.get_input()
	if source != null:
		source.rumble(0.4, 0.8, 0.35)
