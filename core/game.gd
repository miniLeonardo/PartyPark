extends Node
## Autoload Game: Szenenwechsel zwischen Titel, Beitritt, Hauptmenü und Spielarten (D29),
## Pause-Menü und Verbindungs-Pause während eines Spiels.

signal match_started
signal returned_to_menu

const TITLE_SCENE: String = "res://ui/title_screen/title_screen.tscn"
const JOIN_SCENE: String = "res://ui/join_screen/join_screen.tscn"
const MAIN_MENU_SCENE: String = "res://ui/main_menu/main_menu.tscn"
const OPTIONS_SCENE: String = "res://ui/options_menu/options_menu.tscn"
const ARENA_SCENE: String = "res://modes/test_arena/test_arena.tscn"
const TOURNAMENT_SCENE: String = "res://modes/tournament/tournament.tscn"
const FREE_PLAY_SCENE: String = "res://modes/free_play/free_play.tscn"
const HUB_SCENE: String = "res://modes/hub/hub.tscn"
const PAUSE_MENU_SCENE: PackedScene = preload("res://ui/pause_menu/pause_menu.tscn")
const DISCONNECT_OVERLAY_SCENE: PackedScene = preload("res://ui/disconnect_overlay/disconnect_overlay.tscn")

## Läuft gerade eine Spielart (Arena, Turnier, Freies Spiel)? Nur dann gibt es Pause und Verbindungs-Pause.
var match_running: bool = false
## Gewählte Rundenzahl für das nächste Schnellturnier.
var tournament_rounds: int = 5

var pause_menu: PauseMenu
var disconnect_overlay: DisconnectOverlay
var _unpause_pending: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	tournament_rounds = Settings.tournament_rounds
	pause_menu = PAUSE_MENU_SCENE.instantiate() as PauseMenu
	add_child(pause_menu)
	disconnect_overlay = DISCONNECT_OVERLAY_SCENE.instantiate() as DisconnectOverlay
	add_child(disconnect_overlay)
	add_child(PerfOverlay.new())
	PlayerRoster.player_disconnected.connect(_on_player_disconnected)
	# Messmodus (WP 4.5) auch in exportierten Spielen
	if OS.get_cmdline_user_args().has("--bench") or OS.get_cmdline_args().has("--bench"):
		add_child((load("res://core/bench/bench_runner.gd") as GDScript).new())
	PlayerRoster.roster_changed.connect(_update_pause_state)
	if OS.is_debug_build():
		var args: PackedStringArray = OS.get_cmdline_user_args()
		for arg: String in args:
			if arg.begins_with("--smoke-"):
				var path: String = "res://tests/smoke/%s_smoke.gd" % arg.trim_prefix("--smoke-")
				if ResourceLoader.exists(path):
					add_child((load(path) as GDScript).new())
			elif arg.begins_with("--tool-"):
				# Entwicklerwerkzeuge mit Autoloads, z. B. --tool-asset_audit (nicht im Export enthalten)
				var tool_path: String = "res://tools/%s.gd" % arg.trim_prefix("--tool-")
				if ResourceLoader.exists(tool_path):
					add_child((load(tool_path) as GDScript).new())
		var all_cmd_args: PackedStringArray = OS.get_cmdline_args()
		all_cmd_args.append_array(OS.get_cmdline_user_args())
		for arg: String in all_cmd_args:
			if arg.begins_with("--play="):
				add_child(MinigamePlayRunner.new())
				break
			elif arg == "--hub" or arg == "--lobby":
				_start_hub_quickstart.call_deferred()
				break


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


# --- Szenenwechsel ---

func goto_title() -> void:
	_leave_match()
	get_tree().change_scene_to_file(TITLE_SCENE)


func goto_join() -> void:
	_leave_match()
	get_tree().change_scene_to_file(JOIN_SCENE)


func goto_main_menu() -> void:
	_leave_match()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
	returned_to_menu.emit()


func goto_options() -> void:
	_leave_match()
	get_tree().change_scene_to_file(OPTIONS_SCENE)


func start_test_arena() -> void:
	_start_mode(ARENA_SCENE)


func start_tournament(rounds: int) -> void:
	tournament_rounds = rounds
	_start_mode(TOURNAMENT_SCENE)


func start_free_play() -> void:
	_start_mode(FREE_PLAY_SCENE)


func start_hub() -> void:
	_start_mode(HUB_SCENE)


func _start_hub_quickstart() -> void:
	if not ResourceLoader.exists(HUB_SCENE):
		printerr("[Schnellstart] Hub-Szene '%s' existiert noch nicht." % HUB_SCENE)
		return
	if get_tree().current_scene != null:
		get_tree().current_scene.queue_free()
		await get_tree().process_frame
	PlayerRoster.clear_cpus()
	for source: InputSource in InputRouter.get_sources():
		if source is GamepadInput and source.is_available():
			PlayerRoster.join(source)
	if PlayerRoster.get_human_slots().is_empty():
		for source: InputSource in InputRouter.get_sources():
			if source is KeyboardInput and source.key == "kb:left":
				PlayerRoster.join(source)
				break
	PlayerRoster.fill_with_cpu()
	start_hub()


## Kompatibel zu M1: startet die Testarena.
func start_match() -> void:
	start_test_arena()


## Pause-Menü „Zum Hauptmenü“.
func return_to_main_menu() -> void:
	goto_main_menu()


func quit_game() -> void:
	get_tree().quit()


func _start_mode(scene_path: String) -> void:
	if PlayerRoster.cpu_fill_enabled:
		PlayerRoster.fill_with_cpu()
	match_running = true
	get_tree().paused = false
	get_tree().change_scene_to_file(scene_path)
	match_started.emit()


func _leave_match() -> void:
	Announcer.stop()
	pause_menu.close()
	match_running = false
	Engine.time_scale = 1.0
	for slot: PlayerSlot in PlayerRoster.get_disconnected_slots():
		PlayerRoster.leave(slot)
	PlayerRoster.clear_cpus()
	_update_pause_state()
	get_tree().paused = false


# --- Pause ---

func open_pause(by: PlayerSlot) -> void:
	Sfx.play_ui(&"pause")
	pause_menu.open(by)
	_update_pause_state()


func resume() -> void:
	pause_menu.close()
	_update_pause_state()


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
		# In Menüs verlässt ein getrennter Spieler einfach seinen Platz.
		PlayerRoster.leave(slot)
	_update_pause_state()
