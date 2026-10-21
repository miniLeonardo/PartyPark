extends Node3D
## Testarena für M1: Boden, Hindernisse, Abgrund mit Respawn, ArenaCamera für alle Spieler.
## Geometrie ist Platzhalter und wird per Code gebaut (übersichtlicher als eine große .tscn).

const PLAYER_SCENE: PackedScene = preload("res://player/player.tscn")

## Unterhalb dieser Höhe gilt eine Figur als abgestürzt.
@export var kill_height: float = -12.0
## Respawn so hoch über dem Startpunkt (Meter).
@export var respawn_drop_height: float = 3.0
## Startpunkte der Plätze 1 bis 4.
@export var spawn_points: Array[Vector3] = [
	Vector3(-4.5, 0.5, 3.0),
	Vector3(-1.5, 0.5, 3.0),
	Vector3(1.5, 0.5, 3.0),
	Vector3(4.5, 0.5, 3.0),
]

var players: Array[Player] = []

var _hint: Label

@onready var camera: ArenaCamera = $ArenaCamera


func _ready() -> void:
	Look.use_mood(Look.mood_for_progress(0.0))
	StageKit.add_environment(self)
	_build_level()
	_build_hud()
	if PlayerRoster.get_active_slots().is_empty() and OS.is_debug_build():
		_debug_autojoin()
	for slot: PlayerSlot in PlayerRoster.get_active_slots():
		var player := PLAYER_SCENE.instantiate() as Player
		player.setup(slot)
		player.name = "Player%d" % (slot.index + 1)
		add_child(player)
		player.respawn(spawn_points[slot.index])
		player.face(Vector3.BACK)
		players.append(player)


func _physics_process(_delta: float) -> void:
	for player: Player in players:
		if player.global_position.y < kill_height:
			player.respawn(spawn_points[player.slot.index] + Vector3.UP * respawn_drop_height)
			var source: InputSource = player.get_input()
			if source != null:
				source.rumble(0.5, 0.5, 0.25)


## Szene direkt im Editor gestartet (F6): alle Eingabequellen beitreten lassen, Rest mit Computer auffüllen.
func _debug_autojoin() -> void:
	for source: InputSource in InputRouter.get_sources():
		if source.is_joinable() and source.is_available():
			PlayerRoster.join(source)
	PlayerRoster.fill_with_cpu()
	Game.match_running = true


func get_player(slot_index: int) -> Player:
	for player: Player in players:
		if player.slot.index == slot_index:
			return player
	return null


func _build_level() -> void:
	var level := Node3D.new()
	level.name = "Level"
	add_child(level)
	var grass := Color("#7cc66a")
	var sand := Color("#e8c77a")
	var lilac := Color("#a58bd6")
	var crate := Color("#d98c3a")
	var stone := Color("#9aa3ad")
	# Hauptfläche, ringsum Abgrund
	StageKit.add_box(level, Vector3(20, 1, 14), Vector3(0, -0.5, 0), grass)
	# Insel hinter einer 3 m breiten Lücke
	StageKit.add_box(level, Vector3(6, 1, 6), Vector3(16, -0.5, 0), sand)
	# Stufen zum Hochspringen
	StageKit.add_box(level, Vector3(4, 1, 4), Vector3(-6, 0.5, -3.5), lilac)
	StageKit.add_box(level, Vector3(3, 2, 3), Vector3(-6, 1.0, -6.5), lilac.darkened(0.15))
	# Rampe
	StageKit.add_box(level, Vector3(3, 0.4, 6), Vector3(4.5, 0.75, -3.5), stone, Vector3(14, 0, 0))
	# Kisten und Säule als Hindernisse
	StageKit.add_box(level, Vector3(1, 1, 1), Vector3(1.5, 0.5, 0.0), crate)
	StageKit.add_box(level, Vector3(1, 1, 1), Vector3(-1.5, 0.5, -1.0), crate)
	StageKit.add_box(level, Vector3(1.2, 1.2, 1.2), Vector3(7.5, 0.6, 3.5), crate)
	StageKit.add_cylinder(level, 0.6, 2.5, Vector3(0, 1.25, -4.5), stone)


func _build_hud() -> void:
	var hud := CanvasLayer.new()
	hud.name = "Hud"
	add_child(hud)
	_hint = UiStyle.make_label("", 28, Color(1, 1, 1, 0.9))
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_MINSIZE, 32)
	_hint.grow_vertical = Control.GROW_DIRECTION_BEGIN
	hud.add_child(_hint)
	_update_hint()
	PlayerRoster.roster_changed.connect(_update_hint)


func _exit_tree() -> void:
	if PlayerRoster.roster_changed.is_connected(_update_hint):
		PlayerRoster.roster_changed.disconnect(_update_hint)


## Hinweiszeile mit den Pause-Tasten der Geräte, die gerade mitspielen (D28).
func _update_hint() -> void:
	_hint.text = "Testarena (Platzhalter)\nPause: " + InputHints.for_humans(InputBindings.PAUSE)
