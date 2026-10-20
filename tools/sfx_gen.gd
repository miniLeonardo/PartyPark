extends SceneTree
## Effekt-Generator nach dem sfxr-Prinzip (WP 4.3, D59): erzeugt alle Geräusche headless aus der
## Rezeptliste in `tools/sfx_recipes.gd` und speichert sie als .wav nach `assets/audio/sfx/`.
## Selbst erzeugt, keine Lizenzfrage; Rezepte bleiben im Repo, damit Klänge reproduzierbar sind.
##
## Aufruf (alle):        godot --headless --path . --script res://tools/sfx_gen.gd
## Nur bestimmte:        godot --headless --path . --script res://tools/sfx_gen.gd -- --only=bump,jump
## Danach einmal importieren: godot --headless --path . --import
##
## Ein Rezept besteht aus einer oder mehreren Schichten (`layers`), die gemischt werden. Jede Schicht:
##   wave        "sine" | "triangle" | "square" | "saw" | "noise"
##   freq        Starttonhöhe in Hz
##   freq_end    Endtonhöhe in Hz (exponentieller Verlauf), optional
##   vibrato     [Tiefe in Halbtönen, Geschwindigkeit in Hz], optional
##   arp         [Zeitpunkt in s, Faktor], Tonsprung, optional
##   attack, sustain, decay   Hüllkurve in Sekunden
##   punch       zusätzliche Lautstärke am Anfang des Haltens (0 bis 1)
##   duty        Pulsbreite der Rechteckwelle (0 bis 1)
##   lowpass, highpass        Filter-Eckfrequenz in Hz, optional
##   noise       Anteil beigemischten Rauschens (0 bis 1), optional
##   delay       Startverzögerung der Schicht in s (für Akkorde und Melodien)
##   volume      Lautstärke der Schicht (0 bis 1)
## Auf Rezeptebene: `volume` (Gesamt) und `seed` (Rauschen reproduzierbar).

const OUT_DIR: String = "res://assets/audio/sfx"
const SAMPLE_RATE: int = 44100


func _initialize() -> void:
	var only: PackedStringArray = []
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--only="):
			only = arg.trim_prefix("--only=").split(",", false)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var recipes: Dictionary = (load("res://tools/sfx_recipes.gd") as GDScript).call("all")
	var count: int = 0
	for name: String in recipes:
		if not only.is_empty() and not only.has(name):
			continue
		var stream: AudioStreamWAV = render(recipes[name])
		var path: String = ProjectSettings.globalize_path("%s/%s.wav" % [OUT_DIR, name])
		var error: Error = stream.save_to_wav(path)
		if error != OK:
			print("FEHLER  %s: %s" % [name, error_string(error)])
			continue
		count += 1
		print("ok      %s.wav (%.2f s)" % [name, float(stream.data.size()) / 2.0 / SAMPLE_RATE])
	print("SFX: %d Dateien erzeugt in %s" % [count, OUT_DIR])
	quit(0)


## Rechnet ein Rezept in einen Mono-16-Bit-Klang um.
static func render(recipe: Dictionary) -> AudioStreamWAV:
	var layers: Array = recipe.get("layers", [recipe])
	var rng := RandomNumberGenerator.new()
	rng.seed = int(recipe.get("seed", 1))
	var length: float = 0.0
	for layer: Dictionary in layers:
		length = maxf(length, float(layer.get("delay", 0.0)) + _layer_length(layer))
	var total: int = int(ceil(length * SAMPLE_RATE)) + 32
	var mix := PackedFloat32Array()
	mix.resize(total)
	for layer: Dictionary in layers:
		_render_layer(layer, mix, rng)
	# Normalisieren auf die Rezeptlautstärke, weiches Begrenzen gegen Übersteuern
	var peak: float = 0.0001
	for value: float in mix:
		peak = maxf(peak, absf(value))
	var gain: float = float(recipe.get("volume", 0.8)) / peak
	var data := PackedByteArray()
	data.resize(total * 2)
	for i: int in total:
		var value: float = tanh(mix[i] * gain * 1.2) / tanh(1.2)
		data.encode_s16(i * 2, int(clampf(value, -1.0, 1.0) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = data
	return stream


static func _layer_length(layer: Dictionary) -> float:
	return float(layer.get("attack", 0.005)) + float(layer.get("sustain", 0.05)) + float(layer.get("decay", 0.15))


static func _render_layer(layer: Dictionary, mix: PackedFloat32Array, rng: RandomNumberGenerator) -> void:
	var wave: String = layer.get("wave", "sine")
	var f0: float = float(layer.get("freq", 440.0))
	var f1: float = float(layer.get("freq_end", f0))
	var vibrato: Array = layer.get("vibrato", [0.0, 0.0])
	var arp: Array = layer.get("arp", [-1.0, 1.0])
	var attack: float = maxf(0.001, float(layer.get("attack", 0.005)))
	var sustain: float = float(layer.get("sustain", 0.05))
	var decay: float = maxf(0.001, float(layer.get("decay", 0.15)))
	var punch: float = float(layer.get("punch", 0.0))
	var duty: float = float(layer.get("duty", 0.5))
	var noise_mix: float = float(layer.get("noise", 0.0))
	var volume: float = float(layer.get("volume", 1.0))
	var start: int = int(float(layer.get("delay", 0.0)) * SAMPLE_RATE)
	var duration: float = attack + sustain + decay
	var samples: int = int(duration * SAMPLE_RATE)
	var lowpass: float = float(layer.get("lowpass", 0.0))
	var highpass: float = float(layer.get("highpass", 0.0))
	var lp_a: float = 1.0 - exp(-TAU * lowpass / SAMPLE_RATE) if lowpass > 0.0 else 1.0
	var hp_a: float = 1.0 - exp(-TAU * highpass / SAMPLE_RATE) if highpass > 0.0 else 0.0
	var lp_state: float = 0.0
	var hp_state: float = 0.0
	var phase: float = 0.0
	var noise_value: float = rng.randf_range(-1.0, 1.0)
	for i: int in samples:
		var t: float = float(i) / SAMPLE_RATE
		var progress: float = t / duration
		var freq: float = f0 * pow(f1 / f0, progress) if f1 != f0 else f0
		if float(vibrato[0]) != 0.0:
			freq *= pow(2.0, float(vibrato[0]) * sin(TAU * float(vibrato[1]) * t) / 12.0)
		if float(arp[0]) >= 0.0 and t >= float(arp[0]):
			freq *= float(arp[1])
		var previous_phase: float = phase
		phase = fposmod(phase + freq / SAMPLE_RATE, 1.0)
		var sample: float
		match wave:
			"triangle":
				sample = 4.0 * absf(phase - 0.5) - 1.0
			"square":
				sample = 1.0 if phase < duty else -1.0
			"saw":
				sample = 2.0 * phase - 1.0
			"noise":
				# sfxr-Rauschen: neuer Zufallswert je halber Periode, dadurch tonal färbbar
				if phase < previous_phase or (previous_phase < 0.5 and phase >= 0.5):
					noise_value = rng.randf_range(-1.0, 1.0)
				sample = noise_value
			_:
				sample = sin(TAU * phase)
		if noise_mix > 0.0:
			sample = lerpf(sample, rng.randf_range(-1.0, 1.0), noise_mix)
		# Hüllkurve: Anstieg, Halten mit Punch, weiches Abklingen
		var env: float
		if t < attack:
			env = t / attack
		elif t < attack + sustain:
			env = 1.0 + punch * (1.0 - (t - attack) / maxf(sustain, 0.001))
		else:
			var d: float = (t - attack - sustain) / decay
			env = pow(maxf(0.0, 1.0 - d), 2.0)
		sample *= env
		if lowpass > 0.0:
			lp_state += lp_a * (sample - lp_state)
			sample = lp_state
		if highpass > 0.0:
			hp_state += hp_a * (sample - hp_state)
			sample -= hp_state
		var index: int = start + i
		if index < mix.size():
			mix[index] += sample * volume
