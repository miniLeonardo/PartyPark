extends TestCase
## Tests für das Gerüst-Skript tools/new_minigame.gd (WP 4.7): erzeugt in user:// und prüft das Ergebnis.

const BASE: String = "user://scaffold_test"


func test_validate_rejects_bad_input() -> void:
	var tool_script := load("res://tools/new_minigame.gd") as GDScript
	assert_true(not String(tool_script.call("validate", "Bad Id", "X", PackedStringArray(["ffa"]))).is_empty(), "Leerzeichen in ID abgelehnt")
	assert_true(not String(tool_script.call("validate", "ok_id", "", PackedStringArray(["ffa"]))).is_empty(), "fehlender Name abgelehnt")
	assert_true(not String(tool_script.call("validate", "ok_id", "X", PackedStringArray(["3v1"]))).is_empty(), "unbekanntes Format abgelehnt")
	assert_true(String(tool_script.call("validate", "ok_id", "X", PackedStringArray(["ffa", "2v2"]))).is_empty(), "gültige Eingabe angenommen")


func test_creates_loadable_minigame_and_registers_id() -> void:
	var tool_script := load("res://tools/new_minigame.gd") as GDScript
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(BASE))
	var registry := BASE + "/test_registry.gd"
	var file := FileAccess.open(registry, FileAccess.WRITE)
	file.store_string("\tassert_eq(ids, [\"alpha\", \"zeta\"], \"x\")\n")
	file.close()
	var formats: Array[int] = [1, 2]
	var result: int = tool_script.call("create", "mid_game", "Mittelspiel", formats, BASE, registry)
	assert_eq(result, OK, "Gerüst angelegt")
	var info := ResourceLoader.load(BASE + "/mid_game/info.tres", "", ResourceLoader.CACHE_MODE_IGNORE) as MinigameInfo
	assert_true(info != null, "info.tres lädt als MinigameInfo")
	if info != null:
		assert_eq(info.id, &"mid_game", "ID gesetzt")
		assert_eq(info.min_players, 4, "2 gegen 2 braucht 4 Spieler")
	var script := ResourceLoader.load(BASE + "/mid_game/mid_game.gd", "", ResourceLoader.CACHE_MODE_IGNORE) as GDScript
	assert_true(script != null and script.can_instantiate(), "Skript kompiliert")
	assert_true(FileAccess.get_file_as_string(registry).contains("[\"alpha\", \"mid_game\", \"zeta\"]"), "ID sortiert in den Registry-Test eingetragen")
	_remove(BASE)


func _remove(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	for sub: String in dir.get_directories():
		_remove(path.path_join(sub))
	for name: String in dir.get_files():
		dir.remove(name)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
