extends Node
## Lädt alle Skripte und Szenen des Projekts einmal (mit Autoloads), damit Parse- und Ladefehler sichtbar werden.
## Start: godot --headless --path . -- --smoke-compile

const SKIP_DIRS: Array[String] = [".godot", "builds", "docs", ".git", "_incoming"]

var _failures: int = 0
var _count: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_scan("res://")
	print("SMOKE COMPILE: %d Dateien geladen, %d Fehler" % [_count, _failures])
	get_tree().quit(0 if _failures == 0 else 1)


func _scan(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	for sub: String in dir.get_directories():
		if SKIP_DIRS.has(sub):
			continue
		_scan(path.path_join(sub))
	for file: String in dir.get_files():
		if file.ends_with(".gd") or file.ends_with(".tscn") or file.ends_with(".tres"):
			_count += 1
			var full: String = path.path_join(file)
			var resource: Resource = load(full)
			if resource == null:
				_failures += 1
				print("  FEHLER beim Laden: %s" % full)
			elif resource is GDScript and not (resource as GDScript).can_instantiate() and not file.begins_with("test_"):
				_failures += 1
				print("  FEHLER im Skript: %s" % full)
