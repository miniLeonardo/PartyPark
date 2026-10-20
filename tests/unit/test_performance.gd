extends TestCase
## Tests für Leistungsanzeige und Messmodus (WP 4.5).


func test_frame_stats_average_and_low() -> void:
	var times := PackedFloat32Array()
	for i: int in 99:
		times.append(10.0)
	times.append(50.0)
	var stats: Dictionary = PerfOverlay.frame_stats(times)
	assert_true(absf(float(stats["avg_ms"]) - 10.4) < 0.01, "Durchschnitt 10,4 ms")
	assert_true(absf(float(stats["low_fps"]) - 20.0) < 0.01, "1 % tief = schlechtester Frame (50 ms → 20 fps)")


func test_quality_tables_have_three_levels() -> void:
	var settings_script := load("res://core/settings.gd") as GDScript
	var constants: Dictionary = settings_script.get_script_constant_map()
	for key: String in ["QUALITY_NAMES", "QUALITY_3D_SCALE", "QUALITY_SHADOW_ATLAS"]:
		assert_eq((constants[key] as Array).size(), 3, "%s hat drei Stufen" % key)
