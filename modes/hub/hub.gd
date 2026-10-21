class_name Hub
extends Node3D
## Interaktive 3D-Lobby: Der Freizeitpark (D98, D99).
## Dient als begehbarer Knotenpunkt zwischen den Minispielen mit Bewegungsspaß,
## Parkour, Attraktionen und Spielzeugen für bis zu 4 Spieler.

const PLAYER_SCENE: PackedScene = preload("res://player/player.tscn")

enum ParkZone {
	PLAZA,
	PARKOUR,
	RUMMEL,
	ATTRAKTIONEN,
	SPIELZEUG_WIESE,
}

const ZONE_NAMES: Dictionary = {
	ParkZone.PLAZA: "Zentraler Festplatz",
	ParkZone.PARKOUR: "Kletterturm & Parkour",
	ParkZone.RUMMEL: "Rummelplatz & Karussells",
	ParkZone.ATTRAKTIONEN: "Attraktions-Boulevard",
	ParkZone.SPIELZEUG_WIESE: "Spielzeug-Wiese",
}

## Unterhalb dieser Höhe gilt eine Figur als abgestürzt.
@export var kill_height: float = -6.0
## Spawn-Punkte auf der zentralen Plaza.
@export var spawn_points: Array[Vector3] = [
	Vector3(-3.0, 0.4, 4.0),
	Vector3(-1.0, 0.4, 4.0),
	Vector3(1.0, 0.4, 4.0),
	Vector3(3.0, 0.4, 4.0),
]

var players: Array[Player] = []
var _zone_label: Label
var _hint_label: Label
var _current_zone: int = ParkZone.PLAZA
var _zone_display_timer: float = 0.0

@onready var camera: HubCamera = $HubCamera


func _ready() -> void:
	# Stimmung je nach Einstellungen setzen
	Look.use_mood(Look.menu_mood())
	StageKit.add_environment(self)
	HubProps.build_hub_world(self)
	_build_hud()

	if PlayerRoster.get_active_slots().is_empty() and OS.is_debug_build():
		_debug_autojoin()

	Game.match_running = true

	for slot: PlayerSlot in PlayerRoster.get_active_slots():
		var player := PLAYER_SCENE.instantiate() as Player
		player.setup(slot)
		player.name = "Player%d" % (slot.index + 1)
		add_child(player)
		var spawn_pos: Vector3 = spawn_points[slot.index % spawn_points.size()]
		player.respawn(spawn_pos)
		player.face(Vector3.FORWARD)
		players.append(player)

	Announcer.say(&"round_start", {"game": "Freizeitpark"})
	_connect_stations()


func _connect_stations() -> void:
	for station: HubMinigameStation in find_children("*", "HubMinigameStation", true, false):
		station.activated.connect(play_minigame)
	for pavilion: HubTournamentPavilion in find_children("*", "HubTournamentPavilion", true, false):
		pavilion.tournament_requested.connect(start_tournament_from_hub)


var active_flow: MatchFlow = null


## Startet ein Minispiel direkt aus dem Park heraus (D109).
func play_minigame(info: MinigameInfo) -> void:
	if active_flow != null or info == null:
		return

	var format: int = info.formats[0]
	var player_indices: Array[int] = []
	for slot: PlayerSlot in PlayerRoster.get_active_slots():
		player_indices.append(slot.index)
	var assignment: TeamAssigner.Assignment = TeamAssigner.assign(RandomNumberGenerator.new(), format, player_indices, {})
	var context: MinigameContext = MinigameContext.from_assignment(assignment, PlayerRoster.get_active_slots(), Settings.cpu_difficulty)

	# Spielerfiguren im Hub für die Dauer des Spiels pausieren
	for p: Player in players:
		p.visible = false
		p.controls_enabled = false

	var hud: Node = get_node_or_null("Hud")
	if hud != null:
		(hud as CanvasLayer).visible = false
	if camera != null:
		camera.current = false

	active_flow = MatchFlow.new()
	add_child(active_flow)
	active_flow.completed.connect(_on_flow_completed)
	active_flow.start(info, context, info.display_name, false)


func _on_flow_completed(_result: MinigameResult, _points: Dictionary) -> void:
	if active_flow != null:
		active_flow.queue_free()
		active_flow = null

	for p: Player in players:
		p.visible = true
		p.controls_enabled = true

	var hud: Node = get_node_or_null("Hud")
	if hud != null:
		(hud as CanvasLayer).visible = true
	if camera != null:
		camera.current = true

	Look.use_mood(Look.menu_mood())
	StageKit.add_environment(self)
	Game.match_running = true


## Startet das Schnellturnier am Pavillon (D110).
func start_tournament_from_hub(rounds: int) -> void:
	Game.start_tournament(rounds)


func _physics_process(delta: float) -> void:
	for player: Player in players:
		# Absturz-Sicherung: Zurück zur Plaza teleportieren
		if player.global_position.y < kill_height or player.global_position.length() > 55.0:
			var safe_pos: Vector3 = spawn_points[player.slot.index % spawn_points.size()] + Vector3.UP * 1.5
			player.respawn(safe_pos)
			var source: InputSource = player.get_input()
			if source != null:
				source.rumble(0.4, 0.4, 0.2)

		# Einfaches KI-Verhalten für Computergegner in der Lobby
		if player.slot.is_cpu:
			_update_cpu_wander(player, delta)

	_update_zone_detection(delta)


func _update_zone_detection(delta: float) -> void:
	if players.is_empty():
		return

	# Zone anhand des ersten menschlichen Spielers (oder erstem Spieler) ermitteln
	var ref_player: Player = players[0]
	for p: Player in players:
		if not p.slot.is_cpu:
			ref_player = p
			break

	var pos: Vector3 = ref_player.global_position
	var new_zone: int = ParkZone.PLAZA

	if pos.z < -13.0 and absf(pos.x) < 14.0:
		new_zone = ParkZone.PARKOUR
	elif pos.x > 13.0 and absf(pos.z) < 14.0:
		new_zone = ParkZone.RUMMEL
	elif pos.z > 13.0 and absf(pos.x) < 14.0:
		new_zone = ParkZone.ATTRAKTIONEN
	elif pos.x < -13.0 and absf(pos.z) < 14.0:
		new_zone = ParkZone.SPIELZEUG_WIESE
	else:
		new_zone = ParkZone.PLAZA

	if new_zone != _current_zone:
		_current_zone = new_zone
		_zone_display_timer = 3.5
		if _zone_label != null:
			_zone_label.text = ZONE_NAMES[_current_zone]
			_zone_label.visible = true

	if _zone_display_timer > 0.0:
		_zone_display_timer -= delta
		if _zone_display_timer <= 0.0 and _zone_label != null:
			# Ausblenden oder dezent halten
			_zone_label.text = ZONE_NAMES[_current_zone]


func _update_cpu_wander(player: Player, _delta: float) -> void:
	var ai: AIInput = player.slot.source as AIInput
	if ai == null:
		return

	# Computer laufen in der Nähe der menschlichen Spieler oder im Kreis auf der Plaza
	var target_pos: Vector3 = Vector3.ZERO
	var human_found: bool = false
	for p: Player in players:
		if not p.slot.is_cpu:
			target_pos = p.global_position
			human_found = true
			break

	if not human_found:
		target_pos = Vector3(sin(Time.get_ticks_msec() * 0.001 + player.slot.index) * 6.0, 0, cos(Time.get_ticks_msec() * 0.001 + player.slot.index) * 6.0)

	var to_target: Vector3 = target_pos - player.global_position
	var dist: float = to_target.length()

	if dist > 4.5:
		var dir := Vector2(to_target.x, to_target.z).normalized()
		ai.move = dir * 0.7
	elif dist < 2.0:
		# Etwas Abstand halten
		var dir := Vector2(-to_target.x, -to_target.z).normalized()
		ai.move = dir * 0.5
	else:
		ai.move = Vector2.ZERO


func _debug_autojoin() -> void:
	for source: InputSource in InputRouter.get_sources():
		if source.is_joinable() and source.is_available():
			PlayerRoster.join(source)
	PlayerRoster.fill_with_cpu()


func _build_hud() -> void:
	var hud := CanvasLayer.new()
	hud.name = "Hud"
	add_child(hud)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_bottom", 24)
	hud.add_child(margin)

	var top_box := VBoxContainer.new()
	top_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_box.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	margin.add_child(top_box)

	var title := UiStyle.make_label("PARTYPARK LOBBY", 32, Color("#ffd75e"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top_box.add_child(title)

	_zone_label = UiStyle.make_label(ZONE_NAMES[ParkZone.PLAZA], 24, Color.WHITE)
	_zone_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top_box.add_child(_zone_label)

	var bottom_box := HBoxContainer.new()
	bottom_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_box.size_flags_vertical = Control.SIZE_SHRINK_END
	margin.add_child(bottom_box)

	_hint_label = UiStyle.make_label("A: Springen  •  X: Schubsen  •  Start: Pause", 20, Color(1, 1, 1, 0.8))
	bottom_box.add_child(_hint_label)
