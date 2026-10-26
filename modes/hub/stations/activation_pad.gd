class_name HubActivationPad
extends Node3D
## Aktivierungs-Plattform für Attraktionen und Minispiele (D101, D111).
## Stehen alle anwesenden menschlichen Spieler auf der Plattform,
## läuft ein 3-Sekunden-Countdown mit Tonsignalen; beim Verlassen bricht er ab.
## Alternativ kann ein Spieler auf der Plattform per [A] den Sofort-Start auslösen.

signal activated
signal countdown_started
signal countdown_cancelled

enum State { IDLE, COUNTING, TRIGGERED, LOCKED, COOLDOWN }

@export var pad_radius: float = 2.4
@export var countdown_seconds: float = 3.0

var state: State = State.IDLE

var _players_inside: Array[Player] = []
var _time_left: float = 0.0
var _last_tick_second: int = -1
var _cooldown_timer: float = 0.0

var _pad_mesh: MeshInstance3D
var _pad_mat: StandardMaterial3D
var _label_3d: Label3D
var _ring_mesh: MeshInstance3D
var _trigger_area: Area3D

## Abwärtskompatibilität für Smoke-Tests
var _is_counting: bool:
	get:
		return state == State.COUNTING
	set(val):
		if val:
			_start_countdown()
		else:
			_cancel_countdown()


func _ready() -> void:
	_build_pad()
	_build_trigger()


func _physics_process(delta: float) -> void:
	# Spielerbereinigung
	for i: int in range(_players_inside.size() - 1, -1, -1):
		if not is_instance_valid(_players_inside[i]) or not _players_inside[i].is_inside_tree():
			_players_inside.remove_at(i)

	match state:
		State.LOCKED:
			return

		State.COOLDOWN:
			_cooldown_timer -= delta
			if _cooldown_timer <= 0.0:
				_set_state(State.IDLE)
			return

		State.IDLE:
			var human_count: int = _count_humans_present()
			var total_humans: int = _total_active_humans()

			if human_count > 0:
				if human_count >= total_humans:
					_start_countdown()
				else:
					# Nicht alle da: Zeige Hinweis und erlaube Sofort-Start per A
					if _label_3d != null:
						_label_3d.visible = true
						_label_3d.text = "%d/%d\n[A] Start" % [human_count, total_humans]
						_label_3d.modulate = Color("#ffd75e")
					# Sofort-Start per A prüfen
					for p: Player in _players_inside:
						if p.slot != null and p.slot.is_human():
							var src: InputSource = p.get_input()
							if src != null and src.just_pressed(InputBindings.CONFIRM):
								Log.info("HUB", "Pad '%s': Sofort-Start durch Spieler %d" % [name, p.slot.index + 1])
								_start_countdown()
								break
			else:
				if _label_3d != null and _label_3d.visible:
					_label_3d.visible = false

		State.COUNTING:
			var human_count: int = _count_humans_present()
			if human_count == 0:
				_cancel_countdown()
				return

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


func _count_humans_present() -> int:
	var count: int = 0
	for p: Player in _players_inside:
		if p.slot != null and p.slot.is_human() and not p.slot.disconnected:
			count += 1
	return count


func _total_active_humans() -> int:
	var total: int = 0
	for slot: PlayerSlot in PlayerRoster.get_human_slots():
		if not slot.disconnected:
			total += 1
	return maxi(1, total)


func _start_countdown() -> void:
	_set_state(State.COUNTING)
	_time_left = countdown_seconds
	_last_tick_second = -1
	countdown_started.emit()
	Log.info("HUB", "Pad '%s' Countdown gestartet (%.1f s)" % [name, countdown_seconds])

	if _label_3d != null:
		_label_3d.visible = true
		_label_3d.text = "3"
		_label_3d.modulate = Color("#2ecc71")

	if _pad_mat != null:
		_pad_mat.albedo_color = Color("#2ecc71")
		_pad_mat.emission = Color("#2ecc71")


func _cancel_countdown() -> void:
	_set_state(State.IDLE)
	_time_left = 0.0
	_last_tick_second = -1
	countdown_cancelled.emit()
	Log.info("HUB", "Pad '%s' Countdown abgebrochen" % name)

	Sfx.play(&"leave", global_position, 0.0, 1.2)
	_reset_visuals()


func _complete_activation() -> void:
	_set_state(State.TRIGGERED)
	Log.info("HUB", "Pad '%s' Aktivierung abgeschlossen -> Spielstart!" % name)
	Sfx.play(&"countdown_go", global_position)
	Fx.burst(&"confetti", global_position + Vector3.UP * 0.8, Color("#2ecc71"), 1.2)

	if _label_3d != null:
		_label_3d.text = "LOS!"
		_label_3d.modulate = Color("#ffd75e")
		_label_3d.visible = true

	# Pad sperren, damit es während des Spiels nicht weiterfeuert
	lock()
	activated.emit()


func lock() -> void:
	_set_state(State.LOCKED)
	if _label_3d != null:
		_label_3d.visible = false
	if _pad_mat != null:
		_pad_mat.albedo_color = Color("#4a5568")
		_pad_mat.emission = Color("#2d3748")
		_pad_mat.emission_energy_multiplier = 0.3


func unlock(cooldown_time: float = 2.5) -> void:
	_players_inside.clear()
	_cooldown_timer = cooldown_time
	_set_state(State.COOLDOWN)
	_reset_visuals()
	Log.info("HUB", "Pad '%s' entsperrt mit Cooldown %.1fs" % [name, cooldown_time])


func _set_state(new_state: State) -> void:
	state = new_state


func _reset_visuals() -> void:
	if _label_3d != null:
		_label_3d.visible = false
		_label_3d.text = ""

	if _pad_mat != null:
		_pad_mat.albedo_color = Color("#00a8ff")
		_pad_mat.emission = Color("#00a8ff")
		_pad_mat.emission_energy_multiplier = 0.6


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
	_trigger_area = Area3D.new()
	_trigger_area.name = "PadTrigger"
	_trigger_area.collision_mask = 1 # Players
	add_child(_trigger_area)

	var shape := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = pad_radius * 0.95
	cyl.height = 1.2
	shape.shape = cyl
	shape.position = Vector3(0, 0.6, 0)
	_trigger_area.add_child(shape)

	_trigger_area.body_entered.connect(_on_body_entered)
	_trigger_area.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	var player := body as Player
	if player != null and not _players_inside.has(player):
		_players_inside.append(player)


func _on_body_exited(body: Node3D) -> void:
	var player := body as Player
	if player != null and _players_inside.has(player):
		_players_inside.erase(player)
