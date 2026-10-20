extends Node
## Autoload Settings: Optionen (D39), gespeichert in user://settings.cfg.

signal changed

const PATH: String = "user://settings.cfg"
const DIFFICULTY_NAMES: Array[String] = ["Leicht", "Mittel", "Schwer"]
const ROUND_CHOICES: Array[int] = [5, 10]
## Grafikstufen (D69): Niedrig, Mittel, Hoch.
const QUALITY_NAMES: Array[String] = ["Niedrig", "Mittel", "Hoch"]
## 3D-Auflösung je Stufe (Anteil, darunter skaliert FSR hoch).
const QUALITY_3D_SCALE: Array[float] = [0.7, 0.85, 1.0]
const QUALITY_SHADOW_ATLAS: Array[int] = [1024, 2048, 4096]
## Lichter mit Schatten hängen in dieser Gruppe, damit ein Wechsel der Stufe sofort wirkt.
const STAGE_LIGHTS_GROUP: StringName = &"stage_lights"

## Computer-Stärke 0 leicht, 1 mittel, 2 schwer (D38).
var cpu_difficulty: int = 1
var vibration_enabled: bool = true
## Bildschirmwackeln bei großen Momenten (D55, Zugänglichkeit).
var screen_shake: bool = true
var fullscreen: bool = false
## Lautstärken 0 bis 1 je Bus (D61), Schritte von 0,1.
var volume_music: float = 0.6
var volume_sfx: float = 0.8
var volume_voice: float = 0.8
## Grafikstufe 0 Niedrig, 1 Mittel, 2 Hoch (D69).
var graphics_quality: int = 1
## Leistungsanzeige (fps, Frametime, Draw Calls), auch mit F3 umschaltbar (D69).
var show_performance: bool = false
## Vorauswahl der Turnierlänge im Hauptmenü.
var tournament_rounds: int = 5


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_settings()
	apply_display()
	apply_audio()
	apply_graphics()


func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(PATH) != OK:
		return
	cpu_difficulty = clampi(int(config.get_value("game", "cpu_difficulty", cpu_difficulty)), 0, 2)
	vibration_enabled = bool(config.get_value("input", "vibration", vibration_enabled))
	screen_shake = bool(config.get_value("display", "screen_shake", screen_shake))
	fullscreen = bool(config.get_value("display", "fullscreen", fullscreen))
	volume_music = clampf(float(config.get_value("audio", "music", volume_music)), 0.0, 1.0)
	volume_sfx = clampf(float(config.get_value("audio", "sfx", volume_sfx)), 0.0, 1.0)
	volume_voice = clampf(float(config.get_value("audio", "voice", volume_voice)), 0.0, 1.0)
	graphics_quality = clampi(int(config.get_value("display", "quality", graphics_quality)), 0, 2)
	show_performance = bool(config.get_value("display", "show_performance", show_performance))
	var rounds: int = int(config.get_value("game", "tournament_rounds", tournament_rounds))
	tournament_rounds = rounds if ROUND_CHOICES.has(rounds) else 5


func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("game", "cpu_difficulty", cpu_difficulty)
	config.set_value("game", "tournament_rounds", tournament_rounds)
	config.set_value("input", "vibration", vibration_enabled)
	config.set_value("display", "fullscreen", fullscreen)
	config.set_value("display", "screen_shake", screen_shake)
	config.set_value("display", "quality", graphics_quality)
	config.set_value("display", "show_performance", show_performance)
	config.set_value("audio", "music", volume_music)
	config.set_value("audio", "sfx", volume_sfx)
	config.set_value("audio", "voice", volume_voice)
	config.save(PATH)
	changed.emit()


## Überträgt die Lautstärken auf die Busse Music, Sfx und Voice (default_bus_layout.tres).
func apply_audio() -> void:
	for entry: Array in [[&"Music", volume_music], [&"Sfx", volume_sfx], [&"Voice", volume_voice]]:
		var bus: int = AudioServer.get_bus_index(entry[0])
		if bus < 0:
			continue
		var linear: float = float(entry[1])
		AudioServer.set_bus_mute(bus, linear <= 0.001)
		AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(linear, 0.001)))


## Ändert eine Lautstärke in 10-%-Schritten (für die Optionen).
static func step_volume(value: float, direction: int) -> float:
	return clampf(snappedf(value + 0.1 * float(direction), 0.1), 0.0, 1.0)


func shadows_enabled() -> bool:
	return graphics_quality >= 1


## Grafikstufe anwenden (D69): Schatten, MSAA, 3D-Auflösung mit FSR-Hochskalierung.
func apply_graphics() -> void:
	if not is_inside_tree():
		return
	apply_graphics_to_viewport(get_tree().root)
	RenderingServer.directional_shadow_atlas_set_size(QUALITY_SHADOW_ATLAS[graphics_quality], true)
	RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW if graphics_quality == 2 else RenderingServer.SHADOW_QUALITY_HARD)
	for node: Node in get_tree().get_nodes_in_group(STAGE_LIGHTS_GROUP):
		var light := node as Light3D
		if light != null:
			light.shadow_enabled = shadows_enabled()


## Auch für die Teilbildschirme des Splitscreens (SubViewport).
func apply_graphics_to_viewport(viewport: Viewport) -> void:
	viewport.scaling_3d_scale = QUALITY_3D_SCALE[graphics_quality]
	viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR if QUALITY_3D_SCALE[graphics_quality] < 1.0 else Viewport.SCALING_3D_MODE_BILINEAR
	viewport.msaa_3d = Viewport.MSAA_2X if graphics_quality == 2 else Viewport.MSAA_DISABLED


func apply_display() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var mode: DisplayServer.WindowMode = DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	if DisplayServer.window_get_mode() != mode:
		DisplayServer.window_set_mode(mode)
