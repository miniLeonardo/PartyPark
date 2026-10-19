class_name TestCase
extends RefCounted
## Basisklasse für Tests in tests/unit. Fehler werden gesammelt statt abzubrechen.

var failures: PackedStringArray = []


func assert_true(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		failures.append("%s (erwartet %s, erhalten %s)" % [message, str(expected), str(actual)])


func make_rng(seed_value: int = 1234) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng
