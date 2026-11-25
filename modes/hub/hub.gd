class_name Hub
extends Node3D
## Interaktive 3D-Lobby: Der Freizeitpark (D98, D99).
## Dient als begehbarer Knotenpunkt zwischen den Minispielen mit Bewegungsspaß,
## Parkour, Attraktionen und Spielzeugen für bis zu 4 Spieler.
## Im Park laufen nur menschliche Spieler (D124); Minispiele starten in eigener Szene (D125).

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
## Kamera-Leine (D121): So weit (m, waagerecht) dürfen sich Spieler von der Mitte der Gruppe entfernen.
## x = links/rechts im Bild, y = nach vorne/hinten (Tiefe). Größer = mehr Freiheit, kleinere Figuren.
@export var leash_half_extent: Vector2 = Vector2(14.0, 9.0)
## Kanten bis zu dieser Höhe laufen Figuren im Park ohne Sprung hinauf (Wege, Zonenböden, Podeste).
@export var park_step_height: float = 0.45

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

	if PlayerRoster.get_human_slots().is_empty() and OS.is_debug_build():
		_debug_autojoin()

	Game.match_running = true

	var humans: Array[PlayerSlot] = PlayerRoster.get_human_slots()
	for i: int in humans.size():
		var slot: PlayerSlot = humans[i]
		var player := PLAYER_SCENE.instantiate() as Player
		player.setup(slot)
		player.name = "Player%d" % (slot.index + 1)
		player.step_height = park_step_height
		add_child(player)
		player.respawn(_spawn_position(i, humans.size()))
		player.face(Vector3.FORWARD)
		players.append(player)
	Game.has_hub_return_position = false

	_build_hud()
	if camera != null:
		camera.snap_to_targets()

	Log.info("HUB", "Lobby mit %d menschlichen Spielern gestartet" % players.size())

	Announcer.say(&"round_start", {"game": "Freizeitpark"})
	_connect_stations()
	_setup_ambiance()
	_setup_crown_hunt()


## Startplatz: nach einem Minispiel neben der Bude, sonst auf der Plaza.
func _spawn_position(order: int, count: int) -> Vector3:
	if Game.has_hub_return_position:
		var offset: float = (float(order) - float(count - 1) * 0.5) * 1.6
		return Game.hub_return_position + Vector3(offset, 0.4, 0.0)
	return spawn_points[order % spawn_points.size()]


func _setup_ambiance() -> void:
	var amb := HubAmbiance.new()
	amb.name = "Ambiance"
	add_child(amb)


## Kronenjagd (P2, D134): startet, wenn jemand die Krone von der Turmspitze holt.
var crown_hunt: HubCrownHunt


func _setup_crown_hunt() -> void:
	var crowns: Array[Node] = find_children("*", "HubCrown", true, false)
	if crowns.is_empty():
		return
	crown_hunt = HubCrownHunt.new()
	crown_hunt.name = "CrownHunt"
	add_child(crown_hunt)
	crown_hunt.setup(crowns[0] as HubCrown, players)


func _connect_stations() -> void:
	for station: HubMinigameStation in find_children("*", "HubMinigameStation", true, false):
		station.activated.connect(_on_station_activated.bind(station))
	for pavilion: HubTournamentPavilion in find_children("*", "HubTournamentPavilion", true, false):
		pavilion.tournament_requested.connect(start_tournament_from_hub)


func _on_station_activated(info: MinigameInfo, station: HubMinigameStation) -> void:
	play_minigame(info, station.get_return_position())


## Startet ein Minispiel aus dem Park heraus in eigener Szene (D109, D125).
func play_minigame(info: MinigameInfo, return_position: Vector3 = Vector3(0.0, 0.2, 6.0)) -> void:
	if info == null:
		return
	Log.info("HUB", "Minispiel '%s' gestartet" % info.display_name)
	for pad: HubActivationPad in find_children("*", "HubActivationPad", true, false):
		pad.lock()
	Game.play_minigame_from_hub(info, return_position)


## Startet das Schnellturnier am Pavillon (D110).
func start_tournament_from_hub(rounds: int) -> void:
	Log.info("HUB", "Schnellturnier gestartet (%d Runden)" % rounds)
	Game.start_tournament(rounds)
	Game.launched_from_hub = true


func _physics_process(delta: float) -> void:
	for player: Player in players:
		if not player.is_inside_tree() or not player.visible:
			continue
		# Absturz-Sicherung: Zurück zur Plaza teleportieren
		if player.global_position.y < kill_height or player.global_position.length() > 55.0:
			var safe_pos: Vector3 = spawn_points[player.slot.index % spawn_points.size()] + Vector3.UP * 1.5
			player.respawn(safe_pos)
			var source: InputSource = player.get_input()
			if source != null:
				source.rumble(0.4, 0.4, 0.2)
	_apply_leash()
	_update_zone_detection(delta)


## Kamera-Leine (D121): Wer zu weit von der Gruppenmitte entfernt ist, kann nicht weiter nach außen laufen.
## Der Hub läuft vor seinen Figuren (Eltern zuerst), deshalb wirkt das noch im selben Bild.
func _apply_leash() -> void:
	if players.size() < 2:
		return
	var min_x: float = INF
	var max_x: float = -INF
	var min_z: float = INF
	var max_z: float = -INF
	for player: Player in players:
		var p: Vector3 = player.global_position
		min_x = minf(min_x, p.x)
		max_x = maxf(max_x, p.x)
		min_z = minf(min_z, p.z)
		max_z = maxf(max_z, p.z)
	var center := Vector2((min_x + max_x) * 0.5, (min_z + max_z) * 0.5)
	for player: Player in players:
		var dx: float = player.global_position.x - center.x
		var dz: float = player.global_position.z - center.y
		if dx > leash_half_extent.x:
			player.leash_blocks.append(Vector3.RIGHT)
		elif dx < -leash_half_extent.x:
			player.leash_blocks.append(Vector3.LEFT)
		if dz > leash_half_extent.y:
			player.leash_blocks.append(Vector3.BACK)
		elif dz < -leash_half_extent.y:
			player.leash_blocks.append(Vector3.FORWARD)


func _update_zone_detection(delta: float) -> void:
	if players.is_empty():
		return

	var pos: Vector3 = players[0].global_position
	var new_zone: int = ParkZone.PLAZA

	if pos.z < -13.0 and absf(pos.x) < 14.0:
		new_zone = ParkZone.PARKOUR
	elif pos.x > 13.0 and absf(pos.z) < 14.0:
		new_zone = ParkZone.RUMMEL
	elif pos.z > 13.0 and absf(pos.x) < 14.0:
		new_zone = ParkZone.ATTRAKTIONEN
	elif pos.x < -13.0 and absf(pos.z) < 14.0:
		new_zone = ParkZone.SPIELZEUG_WIESE

	if new_zone != _current_zone:
		_current_zone = new_zone
		_zone_display_timer = 3.5
		if _zone_label != null:
			_zone_label.text = ZONE_NAMES[_current_zone]
			_zone_label.visible = true

	if _zone_display_timer > 0.0:
		_zone_display_timer -= delta


func _debug_autojoin() -> void:
	for source: InputSource in InputRouter.get_sources():
		if source.is_joinable() and source.is_available():
			PlayerRoster.join(source)


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
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
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

	# Tastenhinweise je Gerät (D28) statt fester Xbox-Beschriftung
	var hint: String = "Springen: %s     Schubsen: %s     Pause: %s     Minispiel: alle auf die blaue Platte einer Bude" % [
		InputHints.for_humans(InputBindings.JUMP),
		InputHints.for_humans(InputBindings.PUSH),
		InputHints.for_humans(InputBindings.PAUSE),
	]
	_hint_label = UiStyle.make_label(hint, 18, Color(1, 1, 1, 0.8))
	_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_box.add_child(_hint_label)
