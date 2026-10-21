class_name MenuBackdrop
extends Node3D
## 3D-Hintergrund für Menüs: Himmel, Wiese, ein paar Freizeitpark-Platzhalter und hüpfende Figuren.

const PLAYER_SCENE: PackedScene = preload("res://player/player.tscn")

## Figuren in den Farben der beigetretenen Spieler zeigen (sonst alle vier Farben).
@export var show_joined_only: bool = false
@export var hop_interval: float = 1.6

var figures: Array[Player] = []
var _hop_timer: float = 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	Look.use_mood(Look.menu_mood())
	StageKit.add_environment(self)
	StageKit.add_box(self, Vector3(60, 1, 40), Vector3(0, -0.5, -8), Color("#7cc66a"))
	# Platzhalter-Kulisse: Riesenrad-Andeutung und Buden
	StageKit.add_cylinder(self, 3.5, 0.4, Vector3(-9, 5.5, -14), Color("#f2d72e")).rotation_degrees = Vector3(90, 0, 0)
	StageKit.add_box(self, Vector3(0.5, 6, 0.5), Vector3(-9, 2.8, -14.6), Color("#9aa3ad"))
	StageKit.add_box(self, Vector3(4, 3, 3), Vector3(9, 1.5, -12), Color("#e5531a"))
	StageKit.add_box(self, Vector3(4.4, 0.4, 3.4), Vector3(9, 3.2, -12), Color("#ffffff"))
	StageKit.add_box(self, Vector3(3, 2.4, 3), Vector3(4, 1.2, -15), Color("#1f7ae0"))
	var camera := Camera3D.new()
	camera.fov = 45.0
	add_child(camera)
	camera.position = Vector3(0, 3.0, 10.0)
	camera.look_at(Vector3(0, 1.4, 0), Vector3.UP)
	camera.current = true
	_spawn_figures()


func _spawn_figures() -> void:
	var colors: Array[Color] = []
	var tags: Array[String] = []
	if show_joined_only:
		for slot: PlayerSlot in PlayerRoster.get_human_slots():
			colors.append(slot.color)
			tags.append(slot.get_tag())
	if colors.is_empty():
		colors.assign(PlayerRoster.PLAYER_COLORS)
		tags.assign(["", "", "", ""])
	for i: int in colors.size():
		var figure := PLAYER_SCENE.instantiate() as Player
		add_child(figure)
		figure.visual.set_color(colors[i])
		figure.set_tag_text(tags[i])
		figure.respawn(Vector3(-3.6 + 2.4 * i + (2.4 * (4 - colors.size()) * 0.5), 0.2, 1.5))
		figure.face(Vector3.BACK)
		figures.append(figure)


func _physics_process(delta: float) -> void:
	_hop_timer -= delta
	if _hop_timer > 0.0 or figures.is_empty():
		return
	_hop_timer = hop_interval * _rng.randf_range(0.4, 1.0)
	var figure: Player = figures[_rng.randi_range(0, figures.size() - 1)]
	if figure.is_on_floor():
		figure.velocity.y = 8.0
		figure.visual.play_jump()
