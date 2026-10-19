extends Node
## Autoload Settings: Optionen (D39), gespeichert in user://settings.cfg.

signal changed

const PATH: String = "user://settings.cfg"
const DIFFICULTY_NAMES: Array[String] = ["Leicht", "Mittel", "Schwer"]
const ROUND_CHOICES: Array[int] = [5, 10]

## Computer-Stärke 0 leicht, 1 mittel, 2 schwer (D38).
var cpu_difficulty: int = 1
var vibration_enabled: bool = true
var fullscreen: bool = false
## Vorauswahl der Turnierlänge im Hauptmenü.
var tournament_rounds: int = 5


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_settings()
	apply_display()


func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(PATH) != OK:
		return
	cpu_difficulty = clampi(int(config.get_value("game", "cpu_difficulty", cpu_difficulty)), 0, 2)
	vibration_enabled = bool(config.get_value("input", "vibration", vibration_enabled))
	fullscreen = bool(config.get_value("display", "fullscreen", fullscreen))
	var rounds: int = int(config.get_value("game", "tournament_rounds", tournament_rounds))
	tournament_rounds = rounds if ROUND_CHOICES.has(rounds) else 5


func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("game", "cpu_difficulty", cpu_difficulty)
	config.set_value("game", "tournament_rounds", tournament_rounds)
	config.set_value("input", "vibration", vibration_enabled)
	config.set_value("display", "fullscreen", fullscreen)
	config.save(PATH)
	changed.emit()


func apply_display() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var mode: DisplayServer.WindowMode = DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	if DisplayServer.window_get_mode() != mode:
		DisplayServer.window_set_mode(mode)
