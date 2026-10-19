class_name Minigame
extends Node3D
## Basisklasse aller Minispiele. Ein Minispiel kennt keine Menüs: Es bekommt in setup() einen Kontext,
## baut Arena und Figuren, läuft ab start_round() und meldet über finish() ein Ergebnis.
## Unterklassen überschreiben die Methoden mit Unterstrich unten.

signal finished(result: MinigameResult)

const PLAYER_SCENE: PackedScene = preload("res://player/player.tscn")

## Zeitlimit in Sekunden, 0 = keins.
@export var time_limit: float = 60.0

var context: MinigameContext
var info: MinigameInfo
var players: Array[Player] = []
var running: bool = false
var elapsed: float = 0.0
var hud: MinigameHud
var rng := RandomNumberGenerator.new()

var _ended: bool = false


## Baut Arena und Figuren auf; Steuerung bleibt bis start_round() aus.
func setup(ctx: MinigameContext, p_info: MinigameInfo) -> void:
	context = ctx
	info = p_info
	rng.randomize()
	_build_arena()
	for i: int in ctx.slots.size():
		var slot: PlayerSlot = ctx.slots[i]
		var player := PLAYER_SCENE.instantiate() as Player
		player.setup(slot)
		player.name = "Player%d" % (slot.index + 1)
		add_child(player)
		player.respawn(_spawn_position(i, slot))
		player.face(_spawn_facing(i, slot))
		if TeamFormat.is_team_format(ctx.format):
			player.set_team_ring(ctx.team_color(ctx.team_of(slot.index)))
		player.push_ability.team_check = ctx.are_teammates
		_configure_player(player, slot)
		players.append(player)
	hud = MinigameHud.new()
	add_child(hud)
	set_controls_enabled(false)
	_after_setup()


func start_round() -> void:
	running = true
	elapsed = 0.0
	set_controls_enabled(true)
	_on_round_started()


func _physics_process(delta: float) -> void:
	if not running:
		return
	elapsed += delta
	for player: Player in players:
		if player.slot.is_cpu and player.is_physics_processing() and player.slot.source is AIInput:
			_update_ai(player, player.slot.source as AIInput, delta)
	_round_process(delta)
	if time_limit > 0.0 and running:
		hud.set_timer(maxf(0.0, time_limit - elapsed))
		if elapsed >= time_limit:
			_on_time_up()


## Beendet die Runde genau einmal und meldet das Ergebnis.
func finish(result: MinigameResult) -> void:
	if _ended:
		return
	_ended = true
	running = false
	set_controls_enabled(false)
	for player: Player in players:
		if player.slot.source is AIInput:
			(player.slot.source as AIInput).release_all()
	finished.emit(result)


func is_ended() -> bool:
	return _ended


func set_controls_enabled(enabled: bool) -> void:
	for player: Player in players:
		player.controls_enabled = enabled


func get_player(slot_index: int) -> Player:
	for player: Player in players:
		if player.slot.index == slot_index:
			return player
	return null


func time_left() -> float:
	return maxf(0.0, time_limit - elapsed)


## Ziel für Computergegner: Stick in Richtung eines Punkts, mit Tempo-Faktor.
func ai_steer_to(player: Player, ai: AIInput, target: Vector3, speed_factor: float = 1.0) -> void:
	var direction: Vector3 = target - player.global_position
	direction.y = 0.0
	if direction.length() < 0.15:
		ai.move = Vector2.ZERO
		return
	ai.move = player.world_to_input(direction.normalized()) * speed_factor


# --- Für Unterklassen ---

## Arena, Kamera, Licht bauen.
func _build_arena() -> void:
	StageKit.add_environment(self)


## Startposition der i-ten Figur.
func _spawn_position(i: int, _slot: PlayerSlot) -> Vector3:
	return Vector3(-4.5 + 3.0 * i, 0.5, 0.0)


func _spawn_facing(_i: int, _slot: PlayerSlot) -> Vector3:
	return Vector3.BACK


## Fähigkeiten und Größe pro Figur einstellen.
func _configure_player(_player: Player, _slot: PlayerSlot) -> void:
	pass


func _after_setup() -> void:
	pass


func _on_round_started() -> void:
	pass


func _round_process(_delta: float) -> void:
	pass


## Computergegner steuern: ai.move setzen, ai.tap()/ai.hold() nutzen.
func _update_ai(_player: Player, _ai: AIInput, _delta: float) -> void:
	pass


## Standard bei Zeitablauf: Unentschieden.
func _on_time_up() -> void:
	finish(MinigameResult.draw(context.indices()))
