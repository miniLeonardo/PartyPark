extends Node
## Autoload Game: Szenenwechsel, Pause, Verbindungsabbrüche während eines Spiels.

signal match_started
signal returned_to_join

const JOIN_SCENE: String = "res://ui/join_screen/join_screen.tscn"
const ARENA_SCENE: String = "res://modes/test_arena/test_arena.tscn"
const PAUSE_MENU_SCENE: PackedScene = preload("res://ui/pause_menu/pause_menu.tscn")
const DISCONNECT_OVERLAY_SCENE: PackedScene = preload("res://ui/disconnect_overlay/disconnect_overlay.tscn")

## Läuft gerade Gameplay (Arena oder Minispiel)? Nur dann gibt es Pause und Verbindungs-Pause.
var match_running: bool = false

var pause_menu: PauseMenu
var disconnect_overlay: DisconnectOverlay
var _unpause_pending: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu = PAUSE_MENU_SCENE.instantiate() as PauseMenu
	add_child(pause_menu)
	disconnect_overlay = DISCONNECT_OVERLAY_SCENE.instantiate() as DisconnectOverlay
	add_child(disconnect_overlay)
	PlayerRoster.player_disconnected.connect(_on_player_disconnected)
	PlayerRoster.roster_changed.connect(_update_pause_state)
	if OS.is_debug_build() and OS.get_cmdline_user_args().has("--smoke-m1"):
		var smoke: Node = (load("res://tests/smoke/m1_smoke.gd") as GDScript).new()
		add_child(smoke)


func _physics_process(_delta: float) -> void:
	if not match_running:
		return
	# Getrennte Plätze per A auf einem freien Controller übernehmen.
	var waiting: Array[PlayerSlot] = PlayerRoster.get_disconnected_slots()
	if not waiting.is_empty():
		for source: InputSource in InputRouter.poll_join_requests():
			if waiting.is_empty():
				break
			var slot: PlayerSlot = waiting.pop_front()
			PlayerRoster.reassign(slot, source)
			source.rumble(0.4, 0.2, 0.15)
	if not pause_menu.is_open:
		for slot: PlayerSlot in PlayerRoster.get_human_slots():
			if not slot.disconnected and slot.source.just_pressed(InputBindings.PAUSE):
				open_pause(slot)
				break
	_update_pause_state()


## Füllt ggf. Computergegner auf und lädt die Spielszene.
func start_match() -> void:
	if PlayerRoster.cpu_fill_enabled:
		PlayerRoster.fill_with_cpu()
	match_running = true
	get_tree().change_scene_to_file(ARENA_SCENE)
	match_started.emit()


func open_pause(by: PlayerSlot) -> void:
	pause_menu.open(by)
	_update_pause_state()


func resume() -> void:
	pause_menu.close()
	_update_pause_state()


func return_to_join() -> void:
	pause_menu.close()
	match_running = false
	for slot: PlayerSlot in PlayerRoster.get_disconnected_slots():
		PlayerRoster.leave(slot)
	PlayerRoster.clear_cpus()
	_update_pause_state()
	get_tree().paused = false
	get_tree().change_scene_to_file(JOIN_SCENE)
	returned_to_join.emit()


func quit_game() -> void:
	get_tree().quit()


func is_waiting_for_controller() -> bool:
	return match_running and not PlayerRoster.get_disconnected_slots().is_empty()


func _update_pause_state() -> void:
	var waiting: bool = is_waiting_for_controller()
	disconnect_overlay.set_waiting(waiting)
	var should_pause: bool = match_running and (pause_menu.is_open or waiting)
	if should_pause:
		get_tree().paused = true
	elif get_tree().paused and not _unpause_pending:
		# Erst am Frame-Ende fortsetzen, damit der Tastendruck zum Schließen nicht im Spiel ankommt.
		_unpause_pending = true
		_unpause_deferred.call_deferred()


func _unpause_deferred() -> void:
	_unpause_pending = false
	if not (match_running and (pause_menu.is_open or is_waiting_for_controller())):
		get_tree().paused = false


func _on_player_disconnected(slot: PlayerSlot) -> void:
	if not match_running:
		# Im Beitrittsbildschirm verlässt ein getrennter Spieler einfach seinen Platz.
		PlayerRoster.leave(slot)
	_update_pause_state()
