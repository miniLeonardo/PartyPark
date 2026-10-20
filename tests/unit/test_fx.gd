extends TestCase
## Tests für den Effekt-Baukasten (WP 4.2): Trauma-Wackeln. Die Partikel-Obergrenze prüft --smoke-games.


func test_shake_is_trauma_squared_and_clamped() -> void:
	var shaker := CameraShaker.new()
	shaker.add_trauma(0.5)
	assert_true(is_equal_approx(shaker.get_shake(), 0.25), "Ausschlag wächst mit Trauma²")
	shaker.add_trauma(2.0)
	assert_eq(shaker.trauma, 1.0, "Trauma ist auf 1 begrenzt")
	shaker.free()


func test_shake_levels_are_ordered() -> void:
	var fx_script := load("res://core/fx/fx.gd") as GDScript
	var constants: Dictionary = fx_script.get_script_constant_map()
	assert_true(float(constants["SHAKE_STRONG"]) > float(constants["SHAKE_MEDIUM"]), "stark > mittel")
	assert_true(float(constants["SHAKE_MEDIUM"]) > float(constants["SHAKE_LIGHT"]), "mittel > leicht")
	assert_true(float(constants["SHAKE_STRONG"]) <= 1.0, "höchstens 1")
