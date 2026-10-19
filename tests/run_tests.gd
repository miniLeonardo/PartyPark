extends SceneTree
## Testläufer: lädt alle tests/unit/test_*.gd, ruft jede Methode mit Präfix test_ auf und beendet sich
## mit Exit-Code 0 (alles grün) oder 1. Start: godot --headless --path . --script res://tests/run_tests.gd
## Testklassen erben von TestCase (tests/test_case.gd) und nutzen assert_true/assert_eq.

const TEST_DIR: String = "res://tests/unit"


func _initialize() -> void:
	var failures: int = 0
	var passed: int = 0
	var dir := DirAccess.open(TEST_DIR)
	var files: PackedStringArray = dir.get_files() if dir != null else PackedStringArray()
	files.sort()
	for file: String in files:
		if not (file.begins_with("test_") and file.ends_with(".gd")):
			continue
		var script := load(TEST_DIR.path_join(file)) as GDScript
		if script == null or not script.can_instantiate():
			print("FEHLER  %s lässt sich nicht laden" % file)
			failures += 1
			continue
		for method: Dictionary in script.get_script_method_list():
			var method_name: String = method["name"]
			if not method_name.begins_with("test_"):
				continue
			var case: TestCase = script.new()
			case.call(method_name)
			if case.failures.is_empty():
				passed += 1
				print("ok      %s.%s" % [file.get_basename(), method_name])
			else:
				failures += 1
				print("FEHLER  %s.%s" % [file.get_basename(), method_name])
				for message: String in case.failures:
					print("        %s" % message)
	print("TESTS: %d bestanden, %d fehlgeschlagen" % [passed, failures])
	quit(0 if failures == 0 else 1)
