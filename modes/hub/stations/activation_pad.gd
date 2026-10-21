class_name HubActivationPad
extends Node3D
## Aktivierungs-Plattform für Attraktionen und Minispiele (D101, D111).
## Stehen alle anwesenden menschlichen Spieler auf der Plattform,
## läuft ein 3-Sekunden-Countdown mit Tonsignalen; beim Verlassen bricht er ab.

signal activated
signal countdown_started
signal countdown_cancelled

@export var pad_radius: float = 2.4
@export var countdown_seconds: float = 3.0

var _players_inside: Array[Player] = []
var _is_counting: bool = false
var _time_left: float = 0.0
var _last_tick_second: int = -1

var _pad_mesh: MeshInstance3D
var _pad_mat: StandardMaterial3D
var _label_3d: Label3D
var _ring_mesh: MeshInstance3D


func _ready() -> void:
	_build_pad()
	_build_trigger()


func _physics_process(delta: float) -> void:
	# Spielerbereinigung
	for i: int in range(_players_inside.size() - 1, -1, -1):
		if not is_instance_valid(_players_inside[i]):
			_players_inside.remove_at(i)

	var all_ready: bool = _check_all_humans_present()

	if all_ready and not _is_counting:
		_start_countdown()
	elif not all_ready and _is_counting:
		_cancel_countdown()

	if _is_counting:
		_time_left -= delta
		var sec_int: int = ceili(_time_left)
		if sec_int != _last_tick_second and sec_int > 0:
			_last_tick_second = sec_int
			Sfx.play(&"countdown_tick", global_position, 0.0, 1.0 + (3.0 - float(sec_int)) * 0.15)
			if _label_3d != null:
				_label_3d.text = str(sec_int)
				_label_3d.modulate = Color("#2ecc71")

		# Pulsierendes Glühen während des Countdowns
		if _pad_mat != null:
			var pulse: float = 1.0 + sin(Time.get_ticks_msec() * 0.015) * 0.5
			_pad_mat.emission_energy_multiplier = pulse * 2.5

		if _time_left <= 0.0:
			_complete_activation()


func _check_all_humans_present() -> bool:
	var human_slots: Array[PlayerSlot] = PlayerRoster.get_human_slots()
	if human_slots.is_empty():
		return false

	for slot: PlayerSlot in human_slots:
		if slot.disconnected:
			continue
		var found: bool = false
		for p: Player in _players_inside:
			if p.slot == slot:
				found = true
				break
		if not found:
			return false
	return true


func _start_countdown() -> void:
	_is_counting = true
	_time_left = countdown_seconds
	_last_tick_second = -1
	countdown_started.emit()

	if _label_3d != null:
		_label_3d.visible = true
		_label_3d.text = "3"

	if _pad_mat != null:
		_pad_mat.albedo_color = Color("#2ecc71")
		_pad_mat.emission = Color("#2ecc71")


func _cancel_countdown() -> void:
	_is_counting = false
	_time_left = 0.0
	_last_tick_second = -1
	countdown_cancelled.emit()

	Sfx.play(&"leave", global_position, 0.0, 1.2)

	if _label_3d != null:
		_label_3d.visible = false

	if _pad_mat != null:
		_pad_mat.albedo_color = Color("#00a8ff")
		_pad_mat.emission = Color("#00a8ff")
		_pad_mat.emission_energy_multiplier = 0.6


func _complete_activation() -> void:
	_is_counting = false
	Sfx.play(&"countdown_go", global_position)
	Fx.burst(&"confetti", global_position + Vector3.UP * 0.8, Color("#2ecc71"), 1.2)

	if _label_3d != null:
		_label_3d.text = "LOS!"
		_label_3d.modulate = Color("#ffd75e")

	activated.emit()


func _build_pad() -> void:
	_pad_mat = StandardMaterial3D.new()
	_pad_mat.albedo_color = Color("#00a8ff")
	_pad_mat.roughness = 0.3
	_pad_mat.emission_enabled = true
	_pad_mat.emission = Color("#00a8ff")
	_pad_mat.emission_energy_multiplier = 0.6

	# Runde Bodenplatte
	_pad_mesh = MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = pad_radius
	cyl.bottom_radius = pad_radius
	cyl.height = 0.12
	cyl.radial_segments = 32
	_pad_mesh.mesh = cyl
	_pad_mesh.material_override = _pad_mat
	_pad_mesh.position = Vector3(0, 0.06, 0)
	add_child(_pad_mesh)

	# Zierring aus Gold außen
	_ring_mesh = MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = pad_radius - 0.1
	torus.outer_radius = pad_radius + 0.1
	torus.rings = 32
	torus.ring_segments = 6
	_ring_mesh.mesh = torus
	_ring_mesh.material_override = Look.surface(Color("#ffd75e"), Look.Kind.METAL)
	_ring_mesh.position = Vector3(0, 0.08, 0)
	_ring_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_ring_mesh)

	# Schwebendes 3D-Countdown-Label
	_label_3d = Label3D.new()
	_label_3d.text = "3"
	_label_3d.font_size = 72
	_label_3d.outline_size = 12
	_label_3d.modulate = Color("#2ecc71")
	_label_3d.outline_modulate = Color("#111111")
	_label_3d.position = Vector3(0, 2.2, 0)
	_label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label_3d.visible = false
	add_child(_label_3d)


func _build_trigger() -> void:
	var area := Area3D.new()
	area.name = "PadTrigger"
	area.collision_mask = 1 # Players
	add_child(area)

	var shape := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = pad_radius * 0.95
	cyl.height = 1.2
	shape.shape = cyl
	shape.position = Vector3(0, 0.6, 0)
	area.add_child(shape)

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	var player := body as Player
	if player != null and not _players_inside.has(player):
		_players_inside.append(player)


func _on_body_exited(body: Node3D) -> void:
	var player := body as Player
	if player != null and _players_inside.has(player):
		_players_inside.erase(player)
