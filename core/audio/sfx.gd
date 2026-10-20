extends Node
## Autoload Sfx (WP 4.3): spielt die selbst erzeugten Geräusche aus `assets/audio/sfx/<name>.wav`.
## Stimmen-Pool (kein Knoten pro Geräusch), Positionsklang mit Stereo-Panorama ohne Abschwächung über
## die Entfernung (Partykamera ist weit weg), Tonhöhen-Streuung ±6 % (D60).
##
## Beispiele:
##   Sfx.play(&"bump", position)          # im Spiel, mit Panorama
##   Sfx.play_ui(&"ui_confirm")           # Menü, läuft auch bei pausiertem Spiel
##   Sfx.play(&"voice_2", Vector3.INF, 0.0, 1.3, Sfx.BUS_VOICE)   # Ansager-Silbe

const SFX_DIR: String = "res://assets/audio/sfx"
const BUS_SFX: StringName = &"Sfx"
const BUS_VOICE: StringName = &"Voice"
const BUS_MUSIC: StringName = &"Music"
## Tonhöhen-Streuung (Anteil, D60).
const PITCH_SPREAD: float = 0.06
const POSITIONAL_VOICES: int = 24
const FLAT_VOICES: int = 12
## Gleiches Geräusch höchstens so oft gleichzeitig und nicht öfter als alle X Sekunden.
const MAX_SAME_SOUND: int = 3
const MIN_REPEAT_TIME: float = 0.035

## Für Tests: wie oft wurde abgespielt bzw. wegen Drosselung ausgelassen.
var played_count: int = 0
var throttled_count: int = 0
var missing: PackedStringArray = []

var _streams: Dictionary = {}
var _positional: Array[AudioStreamPlayer3D] = []
var _flat: Array[AudioStreamPlayer] = []
var _next_positional: int = 0
var _next_flat: int = 0
var _last_played: Dictionary = {}
var _rng := RandomNumberGenerator.new()
## Ohne Audiogerät (headless, Smoke-Tests) wird nur gezählt, nicht abgespielt; sonst bleiben
## Wiedergaben im Dummy-Treiber hängen und Godot meldet beim Beenden Lecks.
var _audio_active: bool = true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rng.randomize()
	_audio_active = AudioServer.get_driver_name() != "Dummy"
	var game_voices := Node3D.new()
	game_voices.name = "GameVoices"
	# Geräusche im Spiel pausieren mit dem Spiel; Menügeräusche (flach) laufen immer
	game_voices.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(game_voices)
	for i: int in POSITIONAL_VOICES:
		var player := AudioStreamPlayer3D.new()
		player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_DISABLED
		player.panning_strength = 0.6
		player.bus = BUS_SFX
		game_voices.add_child(player)
		_positional.append(player)
	for i: int in FLAT_VOICES:
		var player := AudioStreamPlayer.new()
		player.bus = BUS_SFX
		add_child(player)
		_flat.append(player)
	_load_streams()


func _exit_tree() -> void:
	# Laufende Wiedergaben vor dem Beenden stoppen, sonst meldet Godot hängende Ressourcen
	for player: AudioStreamPlayer3D in _positional:
		player.stop()
		player.stream = null
	for player: AudioStreamPlayer in _flat:
		player.stop()
		player.stream = null
	_streams.clear()


func _load_streams() -> void:
	var dir := DirAccess.open(SFX_DIR)
	if dir == null:
		return
	for file: String in dir.get_files():
		# Exportierte Spiele enthalten nur .import-Verweise, deshalb beide Endungen beachten
		var name: String = file.trim_suffix(".import")
		if not name.ends_with(".wav"):
			continue
		var id := StringName(name.get_basename())
		if _streams.has(id):
			continue
		var stream := load("%s/%s" % [SFX_DIR, name]) as AudioStream
		if stream != null:
			_streams[id] = stream


func has_sound(id: StringName) -> bool:
	return _streams.has(id)


## Geräusch im Spiel. Mit Position (Vector3) im Raum, ohne (Vector3.INF) mittig.
## Pausiert mit dem Spiel. pitch wird zusätzlich um ±6 % gestreut.
func play(id: StringName, position: Vector3 = Vector3.INF, volume_db: float = 0.0, pitch: float = 1.0, bus: StringName = BUS_SFX) -> void:
	var stream: AudioStream = _get_stream(id)
	if stream == null or not _allowed(id):
		return
	var final_pitch: float = pitch * (1.0 + _rng.randf_range(-PITCH_SPREAD, PITCH_SPREAD))
	if position == Vector3.INF or get_viewport().get_camera_3d() == null:
		_play_flat(stream, volume_db, final_pitch, bus, false)
		return
	var player: AudioStreamPlayer3D = _positional[_next_positional]
	_next_positional = (_next_positional + 1) % _positional.size()
	player.stream = stream
	player.bus = bus
	player.volume_db = volume_db
	player.pitch_scale = final_pitch
	player.global_position = position
	if _audio_active:
		player.play()
	_mark(id)


## Menügeräusch: mittig, ohne Streuung, läuft auch bei pausiertem Spiel.
func play_ui(id: StringName, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	var stream: AudioStream = _get_stream(id)
	if stream == null or not _allowed(id):
		return
	_play_flat(stream, volume_db, pitch, BUS_SFX, true)
	_mark(id)


## Ansager-Silbe auf dem Stimm-Bus, exakte Tonhöhe (die Streuung macht der Ansager selbst).
func play_voice(id: StringName, pitch: float, volume_db: float = 0.0) -> void:
	var stream: AudioStream = _get_stream(id)
	if stream == null:
		return
	_play_flat(stream, volume_db, pitch, BUS_VOICE, true)
	played_count += 1


func _play_flat(stream: AudioStream, volume_db: float, pitch: float, bus: StringName, always: bool) -> void:
	var player: AudioStreamPlayer = _flat[_next_flat]
	_next_flat = (_next_flat + 1) % _flat.size()
	player.process_mode = Node.PROCESS_MODE_ALWAYS if always else Node.PROCESS_MODE_PAUSABLE
	player.stream = stream
	player.bus = bus
	player.volume_db = volume_db
	player.pitch_scale = pitch
	if _audio_active:
		player.play()


func _get_stream(id: StringName) -> AudioStream:
	var stream: AudioStream = _streams.get(id)
	if stream == null and not missing.has(String(id)):
		missing.append(String(id))
		push_warning("Sfx: Geräusch %s fehlt (tools/sfx_gen.gd ausführen)" % id)
	return stream


## Drosselung: dasselbe Geräusch nicht im selben Moment mehrfach und nie mehr als MAX_SAME_SOUND gleichzeitig.
func _allowed(id: StringName) -> bool:
	var now: float = Time.get_ticks_msec() / 1000.0
	var entry: Array = _last_played.get(id, [-10.0, 0])
	var playing: int = 0
	for player: AudioStreamPlayer3D in _positional:
		if player.playing and player.stream == _streams.get(id):
			playing += 1
	if now - float(entry[0]) < MIN_REPEAT_TIME or playing >= MAX_SAME_SOUND:
		throttled_count += 1
		return false
	return true


func _mark(id: StringName) -> void:
	_last_played[id] = [Time.get_ticks_msec() / 1000.0, 0]
	played_count += 1
