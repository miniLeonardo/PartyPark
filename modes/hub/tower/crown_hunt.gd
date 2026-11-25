class_name HubCrownHunt
extends Node
## Kronenjagd im Park (P2, D134): Wer die Krone von der Turmspitze holt, startet eine Jagd.
## Gezählt wird die Tragezeit je Spieler, die anderen schubsen sie ihm vom Kopf.
## Reine Wartespielerei ohne Turnierpunkte. Zähler stehen über den Köpfen, am Ende ein Banner
## und Jubel der Parkbesucher; danach kehrt die Krone auf die Turmspitze zurück.

signal hunt_started(starter: Player)
signal hunt_finished(winner: Player, seconds: float)

## Dauer einer Jagd in Sekunden.
@export var duration: float = 60.0
## Mindestanzahl menschlicher Spieler im Park, damit die Jagd startet.
@export var min_players: int = 2
## So lange (s) steht das Ergebnis-Banner, bevor die Krone zurück auf den Turm fliegt.
@export var banner_time: float = 4.0
## Ab dieser Restzeit (s) tickt die Uhr hörbar.
@export var final_seconds: int = 5

var crown: HubCrown
var running: bool = false
var time_left: float = 0.0
## Tragezeit in Sekunden je Spielerplatz (Index).
var carry_times: Dictionary = {}

var _players: Array[Player] = []
var _labels: Dictionary = {}
var _hud: CanvasLayer
var _clock: Label
var _banner: Label
var _banner_timer: float = 0.0
var _last_tick: int = -1


func setup(p_crown: HubCrown, p_players: Array[Player]) -> void:
	crown = p_crown
	_players = p_players
	crown.taken.connect(_on_crown_taken)


func _ready() -> void:
	_build_hud()


## Gewinner nach Tragezeit; bei Gleichstand der niedrigere Platz. -1, wenn niemand die Krone hatte.
static func leader_of(times: Dictionary) -> int:
	var best: int = -1
	var best_time: float = 0.0
	var keys: Array = times.keys()
	keys.sort()
	for index: int in keys:
		var t: float = times[index]
		if t > best_time + 0.0001:
			best = index
			best_time = t
	return best


func _on_crown_taken(player: Player, from_summit: bool) -> void:
	if running or not from_summit or _banner_timer > 0.0:
		return
	if _players.size() < min_players:
		return
	start(player)


func start(starter: Player) -> void:
	running = true
	time_left = duration
	carry_times.clear()
	_last_tick = -1
	for p: Player in _players:
		carry_times[p.slot.index] = 0.0
		_attach_label(p)
	_clock.visible = true
	_banner.visible = false
	Announcer.say(&"round_start", {"game": "Kronenjagd"})
	Sfx.play_ui(&"bell")
	Log.info("HUB", "Kronenjagd gestartet von %s" % starter.slot.display_name)
	hunt_started.emit(starter)


func _process(delta: float) -> void:
	if _banner_timer > 0.0:
		_banner_timer -= delta
		if _banner_timer <= 0.0:
			_banner.visible = false
			if crown != null and not running:
				crown.reset_to_summit()
	if not running:
		return
	time_left -= delta
	if crown.current_state == HubCrown.State.WORN and is_instance_valid(crown.wearer):
		var index: int = crown.wearer.slot.index
		carry_times[index] = float(carry_times.get(index, 0.0)) + delta
	_update_labels()
	var secs: int = ceili(maxf(time_left, 0.0))
	_clock.text = "KRONENJAGD  %d" % secs
	if secs <= final_seconds and secs != _last_tick and secs > 0:
		_last_tick = secs
		Sfx.play_ui(&"tick")
	if time_left <= 0.0:
		finish()


func finish() -> void:
	running = false
	_clock.visible = false
	for label: Label3D in _labels.values():
		if is_instance_valid(label):
			label.queue_free()
	_labels.clear()
	var winner_index: int = leader_of(carry_times)
	var winner: Player = null
	for p: Player in _players:
		if p.slot.index == winner_index:
			winner = p
	if winner == null:
		_banner.text = "Kronenjagd vorbei: Niemand hat die Krone gehalten"
		_banner.modulate = Color.WHITE
	else:
		var secs: float = carry_times[winner_index]
		_banner.text = "%s ist König des Parks!  %d s mit Krone" % [winner.slot.display_name, roundi(secs)]
		_banner.modulate = winner.slot.color.lightened(0.3)
		Announcer.say(&"win", {"winner": winner.slot.display_name})
		Fx.burst(&"confetti", winner.global_position + Vector3.UP * 2.0, winner.slot.color, 1.5)
		Sfx.play(&"cheer", winner.global_position)
		_cheer_visitors()
	_banner.visible = true
	_banner_timer = banner_time
	Log.info("HUB", "Kronenjagd beendet: %s" % str(carry_times))
	hunt_finished.emit(winner, float(carry_times.get(winner_index, 0.0)))


func _cheer_visitors() -> void:
	for visitor: ParkVisitor in get_tree().root.find_children("*", "ParkVisitor", true, false):
		visitor.cheer()


func _attach_label(p: Player) -> void:
	var label := Label3D.new()
	label.name = "CrownHuntTime"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.fixed_size = true
	label.pixel_size = 0.0022
	label.font_size = 28
	label.outline_size = 8
	label.modulate = p.slot.color.lightened(0.35)
	label.position = Vector3(0.0, 2.45 * p.body_scale, 0.0)
	p.add_child(label)
	_labels[p.slot.index] = label


func _update_labels() -> void:
	var leader: int = leader_of(carry_times)
	for p: Player in _players:
		var label: Label3D = _labels.get(p.slot.index)
		if label == null or not is_instance_valid(label):
			continue
		var crown_mark: String = "♛ " if p.slot.index == leader else ""
		label.text = "%s%.0f s" % [crown_mark, float(carry_times.get(p.slot.index, 0.0))]


func _build_hud() -> void:
	_hud = CanvasLayer.new()
	_hud.name = "CrownHuntHud"
	add_child(_hud)
	_clock = UiStyle.make_label("KRONENJAGD", 30, Color("#ffd75e"))
	_clock.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_clock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_clock.position.y = 100.0
	_clock.visible = false
	_hud.add_child(_clock)
	_banner = UiStyle.make_label("", 40, Color.WHITE)
	_banner.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_banner.visible = false
	_hud.add_child(_banner)
