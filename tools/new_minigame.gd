extends SceneTree
## Gerüst für ein neues Minispiel (WP 4.7). Legt Ordner, info.tres, Skript, Szene an und trägt die ID
## in tests/unit/test_registry.gd ein. Danach `--import` und die Tests laufen lassen.
##
## Aufruf:
##   godot --headless --path . --script res://tools/new_minigame.gd -- --id=coaster_brake --name="Achterbahn-Bremser" --formats=ffa
## Formate (Komma-getrennt): coop, ffa, 2v2, 1v3
## Ablauf und Regeln: docs/MINIGAME_GUIDE.md

const FORMATS: Dictionary = {"coop": 0, "ffa": 1, "2v2": 2, "1v3": 3}
const REGISTRY_TEST: String = "res://tests/unit/test_registry.gd"


func _initialize() -> void:
	var args: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--") and arg.contains("="):
			var parts: PackedStringArray = arg.trim_prefix("--").split("=", true, 1)
			args[parts[0]] = parts[1]
	var id: String = String(args.get("id", ""))
	var display_name: String = String(args.get("name", ""))
	var format_names: PackedStringArray = String(args.get("formats", "ffa")).split(",", false)
	var error: String = validate(id, display_name, format_names)
	if not error.is_empty():
		print("FEHLER  %s" % error)
		quit(1)
		return
	var formats: Array[int] = []
	for format_name: String in format_names:
		formats.append(int(FORMATS[format_name.strip_edges()]))
	var result: Error = create(id, display_name, formats)
	quit(0 if result == OK else 1)


## Prüft die Eingaben; leerer Text = in Ordnung.
static func validate(id: String, display_name: String, format_names: PackedStringArray) -> String:
	if id.is_empty() or not RegEx.create_from_string("^[a-z][a-z0-9_]*$").search(id):
		return "--id fehlt oder ist kein snake_case (z. B. coaster_brake)"
	if display_name.is_empty():
		return "--name fehlt (Anzeigename, z. B. \"Achterbahn-Bremser\")"
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path("res://minigames/%s" % id)):
		return "minigames/%s gibt es schon" % id
	if format_names.is_empty():
		return "--formats fehlt (coop, ffa, 2v2, 1v3)"
	for format_name: String in format_names:
		if not FORMATS.has(format_name.strip_edges()):
			return "unbekanntes Format %s (erlaubt: coop, ffa, 2v2, 1v3)" % format_name
	return ""


static func create(id: String, display_name: String, formats: Array[int], base_dir: String = "res://minigames", registry_test: String = REGISTRY_TEST) -> Error:
	var dir: String = "%s/%s" % [base_dir, id]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var class_title: String = id.to_pascal_case()
	var min_players: int = 4 if formats.has(2) or formats.has(3) else 2
	var files: Dictionary = {
		"%s/info.tres" % dir: _info_text(id, display_name, formats, min_players, dir),
		"%s/%s.tscn" % [dir, id]: _scene_text(id, class_title, dir),
		"%s/%s.gd" % [dir, id]: _script_text(display_name),
	}
	for path: String in files:
		var file := FileAccess.open(path, FileAccess.WRITE)
		if file == null:
			print("FEHLER  %s nicht schreibbar" % path)
			return ERR_CANT_CREATE
		file.store_string(files[path])
		file.close()
		print("ok      %s" % path)
	if FileAccess.file_exists(registry_test):
		_add_to_registry_test(registry_test, id)
	print("Fertig. Nächste Schritte: godot --headless --path . --import, dann Tests (docs/MINIGAME_GUIDE.md).")
	return OK


static func _add_to_registry_test(path: String, id: String) -> void:
	var text: String = FileAccess.get_file_as_string(path)
	var regex := RegEx.create_from_string("assert_eq\\(ids, \\[([^\\]]*)\\]")
	var found: RegExMatch = regex.search(text)
	if found == null:
		print("Hinweis: ID-Liste in %s nicht gefunden, bitte %s von Hand ergänzen" % [path, id])
		return
	var ids: PackedStringArray = []
	for part: String in found.get_string(1).split(",", false):
		ids.append(part.strip_edges().trim_prefix("\"").trim_suffix("\""))
	if ids.has(id):
		return
	ids.append(id)
	ids.sort()
	var quoted: PackedStringArray = []
	for value: String in ids:
		quoted.append("\"%s\"" % value)
	text = text.substr(0, found.get_start(1)) + ", ".join(quoted) + text.substr(found.get_end(1))
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()
	print("ok      %s (ID %s ergänzt)" % [path, id])


static func _info_text(id: String, display_name: String, formats: Array[int], min_players: int, dir: String) -> String:
	var format_list: PackedStringArray = []
	for format: int in formats:
		format_list.append(str(format))
	return """[gd_resource type="Resource" script_class="MinigameInfo" load_steps=2 format=3]

[ext_resource type="Script" path="res://core/minigame/minigame_info.gd" id="1_info"]

[resource]
script = ExtResource("1_info")
id = &"%s"
display_name = "%s"
formats = Array[int]([%s])
min_players = %d
max_players = 4
duration_sec = 60.0
goal_text = "TODO: Ziel in einem Satz."
controls = {
"move": "Laufen",
"jump": "Springen",
"push": "Schubsen"
}
solo_goal_text = ""
solo_controls = {}
solo_role_name = ""
team_role_name = ""
scene_path = "%s/%s.tscn"
""" % [id, display_name, ", ".join(format_list), min_players, dir, id]


static func _scene_text(id: String, class_title: String, dir: String) -> String:
	return """[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="%s/%s.gd" id="1_game"]

[node name="%s" type="Node3D"]
script = ExtResource("1_game")
""" % [dir, id, class_title]


static func _script_text(display_name: String) -> String:
	return """extends Minigame
## %s: TODO Spielidee in zwei Sätzen und Verweis auf die Designentscheidung (Dxx).
## Anleitung: docs/MINIGAME_GUIDE.md

@export_group("Regeln")
## TODO: alle Spielwerte als @export, damit sie im Editor einstellbar sind.
@export var arena_radius: float = 10.0

## Platzindizes in der Reihenfolge des Ausscheidens.
var eliminated: Array[int] = []


func _init() -> void:
	time_limit = 60.0


func _build_arena() -> void:
	super._build_arena()
	StageKit.add_cylinder(self, arena_radius, 1.0, Vector3(0, -0.5, 0), Color("#7cc66a"))
	var camera := ArenaCamera.new()
	add_child(camera)
	camera.current = true


func _spawn_position(i: int, _slot: PlayerSlot) -> Vector3:
	var angle: float = TAU * float(i) / float(maxi(2, context.slots.size()))
	return Vector3(sin(angle) * 4.0, 0.3, cos(angle) * 4.0)


func _configure_player(_player: Player, _slot: PlayerSlot) -> void:
	pass


func _after_setup() -> void:
	_update_hud()


func _round_process(_delta: float) -> void:
	# TODO: Spielregeln, Effekte (Fx), Geräusche (Sfx), Siegbedingung
	for player: Player in players:
		if not eliminated.has(player.slot.index) and player.global_position.y < -3.0:
			eliminated.append(player.slot.index)
			player.set_active(false)
			Fx.shake(Fx.SHAKE_STRONG)
			Sfx.play(&"eliminated", player.global_position)
			Announcer.say(&"bad_luck", {"player": player.slot.display_name}, 0.6)
			_update_hud()
	if eliminated.size() >= context.slots.size() - 1 and context.slots.size() > 1:
		finish(_ranking())


func _ranking() -> MinigameResult:
	var groups: Array = []
	var alive: Array[int] = []
	for slot: PlayerSlot in context.slots:
		if not eliminated.has(slot.index):
			alive.append(slot.index)
	if not alive.is_empty():
		groups.append(alive)
	for i: int in range(eliminated.size() - 1, -1, -1):
		groups.append([eliminated[i]])
	return MinigameResult.from_ranking(groups)


func _on_time_up() -> void:
	finish(_ranking())


func _update_hud() -> void:
	for slot: PlayerSlot in context.slots:
		hud.set_status(slot, "%%s  %%s" %% [slot.get_tag(), "raus" if eliminated.has(slot.index) else "dabei"])


## Für den Smoke-Test `--smoke-games`.
func debug_summary() -> String:
	return "raus %%d" %% eliminated.size()


# --- Computergegner ---

func _update_ai(player: Player, ai: AIInput, _delta: float) -> void:
	# TODO: Verhalten; Stärke über AIProfile (reaction_time, aim_error, skill, speed)
	ai_steer_to(player, ai, Vector3.ZERO, AIProfile.speed(context.difficulty))
""" % display_name
