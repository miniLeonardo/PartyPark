extends TestCase
## Tests für das Sound-Grundgerüst (WP 4.3): Generator und Rezepte.


func test_every_used_sound_has_a_recipe() -> void:
	var recipes: Dictionary = (load("res://tools/sfx_recipes.gd") as GDScript).call("all")
	var regex := RegEx.create_from_string("Sfx\\.play(?:_ui|_voice)?\\(&\"([a-z0-9_]+)\"")
	var found: int = 0
	for path: String in _scripts("res://"):
		var text: String = FileAccess.get_file_as_string(path)
		for match: RegExMatch in regex.search_all(text):
			var id: String = match.get_string(1)
			found += 1
			assert_true(recipes.has(id), "%s nutzt Geräusch %s ohne Rezept" % [path, id])
	assert_true(found > 20, "Aufrufe gefunden (%d), sonst prüft der Test nichts" % found)


func test_generator_renders_audible_sound() -> void:
	var generator := load("res://tools/sfx_gen.gd") as GDScript
	var recipe: Dictionary = {"wave": "sine", "freq": 440.0, "attack": 0.01, "sustain": 0.1, "decay": 0.1, "volume": 0.5}
	var stream: AudioStreamWAV = generator.call("render", recipe)
	var seconds: float = float(stream.data.size()) / 2.0 / float(stream.mix_rate)
	assert_true(seconds > 0.2 and seconds < 0.25, "Länge passt zur Hüllkurve (%.3f s)" % seconds)
	var peak: int = 0
	for i: int in range(0, stream.data.size(), 2):
		peak = maxi(peak, absi(stream.data.decode_s16(i)))
	assert_true(peak > 12000 and peak < 32767, "Pegel hörbar und nicht übersteuert (%d)" % peak)


func test_generator_is_reproducible() -> void:
	var generator := load("res://tools/sfx_gen.gd") as GDScript
	var recipe: Dictionary = {"wave": "noise", "freq": 800.0, "sustain": 0.05, "seed": 42}
	var a: AudioStreamWAV = generator.call("render", recipe)
	var b: AudioStreamWAV = generator.call("render", recipe)
	assert_eq(a.data, b.data, "gleiches Rezept ergibt gleichen Klang")


func _scripts(dir_path: String) -> PackedStringArray:
	var result: PackedStringArray = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return result
	for file: String in dir.get_files():
		if file.ends_with(".gd"):
			result.append(dir_path.path_join(file))
	for sub: String in dir.get_directories():
		if sub.begins_with(".") or sub in ["docs", "builds", "assets"]:
			continue
		result.append_array(_scripts(dir_path.path_join(sub)))
	return result
