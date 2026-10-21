class_name ParkVisitor
extends Node3D
## Lebendiger Parkbesucher (Kenney Mini Characters, D115).
## Zeigt weiche Idle-Animationen (Wippen, Winken, Kopfbewegung)
## und reagiert freudig mit Hüpfern und Jubel, wenn Spieler nahe kommen.

const CHARACTER_MODELS: Array[String] = [
	"res://assets/third_party/kenney_mini-characters/character-female-a.glb",
	"res://assets/third_party/kenney_mini-characters/character-female-b.glb",
	"res://assets/third_party/kenney_mini-characters/character-female-c.glb",
	"res://assets/third_party/kenney_mini-characters/character-female-d.glb",
	"res://assets/third_party/kenney_mini-characters/character-female-e.glb",
	"res://assets/third_party/kenney_mini-characters/character-female-f.glb",
	"res://assets/third_party/kenney_mini-characters/character-male-a.glb",
	"res://assets/third_party/kenney_mini-characters/character-male-b.glb",
	"res://assets/third_party/kenney_mini-characters/character-male-c.glb",
	"res://assets/third_party/kenney_mini-characters/character-male-d.glb",
	"res://assets/third_party/kenney_mini-characters/character-male-e.glb",
	"res://assets/third_party/kenney_mini-characters/character-male-f.glb",
]

@export var model_index: int = -1
var _model_node: Node3D
var _base_y: float = 0.0
var _anim_phase: float = 0.0
var _hop_time: float = 0.0
var _cheer_cooldown: float = 0.0
var _idle_variation: float = 0.0
var _target_yaw: float = 0.0
var _base_yaw: float = 0.0


func _ready() -> void:
	_base_y = position.y
	_base_yaw = rotation.y
	_target_yaw = _base_yaw
	_anim_phase = randf() * TAU
	_idle_variation = randf()

	_load_character()


func _load_character() -> void:
	var idx: int = model_index
	if idx < 0 or idx >= CHARACTER_MODELS.size():
		idx = randi() % CHARACTER_MODELS.size()

	var scene: PackedScene = load(CHARACTER_MODELS[idx]) as PackedScene
	if scene == null:
		return

	_model_node = scene.instantiate() as Node3D
	add_child(_model_node)
	_model_node.scale = Vector3(0.9, 0.9, 0.9)

	# Schatten ausschalten für Performance-Budget (D41, 60 fps)
	for child: Node in _model_node.find_children("*", "VisualInstance3D", true, false):
		var vi := child as VisualInstance3D
		if vi != null:
			vi.set("cast_shadow", GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)


func _process(delta: float) -> void:
	var t: float = Time.get_ticks_msec() * 0.001 + _anim_phase

	if _cheer_cooldown > 0.0:
		_cheer_cooldown -= delta

	# Spieler in der Nähe prüfen (D115)
	var players: Array[Node] = get_tree().get_nodes_in_group(&"players")
	var nearest_player: Player = null
	var min_dist: float = 3.2

	for node: Node in players:
		var p := node as Player
		if p == null or not p.is_inside_tree():
			continue
		var d: float = global_position.distance_to(p.global_position)
		if d < min_dist:
			min_dist = d
			nearest_player = p

	# Reaktionslogik bei Spielernähe (D115)
	if nearest_player != null:
		# Zum Spieler blicken
		var to_player: Vector3 = nearest_player.global_position - global_position
		to_player.y = 0
		if to_player.length_squared() > 0.01:
			_target_yaw = atan2(to_player.x, to_player.z)

		# Jubel-Reaktion auslösen
		if min_dist < 2.0 and _cheer_cooldown <= 0.0:
			_cheer_cooldown = 4.0
			_hop_time = 0.6
			Fx.burst(&"stars", global_position + Vector3(0, 1.2, 0), Color("#ffd75e"))
			if randf() < 0.4:
				Sfx.play(&"cheer")
	else:
		# Sanft zurück zur Grundausrichtung drehen
		_target_yaw = _base_yaw

	# Sanfte Drehung
	rotation.y = lerp_angle(rotation.y, _target_yaw, clampf(4.0 * delta, 0.0, 1.0))

	# Hüpf- / Jubelanimation
	var hop_offset: float = 0.0
	if _hop_time > 0.0:
		_hop_time -= delta
		var hop_norm: float = 1.0 - clampf(_hop_time / 0.6, 0.0, 1.0)
		hop_offset = sin(hop_norm * PI) * 0.45
		# Schnelleres Wackeln bei Jubel
		rotation.z = sin(t * 18.0) * 0.12
	else:
		# Weiche Idle-Animation
		var bob: float = sin(t * 2.5) * 0.03
		var sway: float = sin(t * 1.5) * 0.04
		hop_offset = bob
		rotation.z = sway

	position.y = _base_y + hop_offset
