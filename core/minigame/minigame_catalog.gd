class_name MinigameCatalog
extends RefCounted
## Sucht Minispiel-Beschreibungen in einem Ordner und filtert sie. Reine Logik, auch ohne Autoload testbar.

const DEFAULT_ROOT: String = "res://minigames"


## Lädt alle `<root>/<id>/info.tres`. Im Export heißen die Dateien ggf. `info.tres.remap`.
static func scan(root: String = DEFAULT_ROOT) -> Array[MinigameInfo]:
	var result: Array[MinigameInfo] = []
	var dir := DirAccess.open(root)
	if dir == null:
		return result
	var folders: PackedStringArray = dir.get_directories()
	folders.sort()
	for folder: String in folders:
		var path: String = root.path_join(folder).path_join("info.tres")
		if not ResourceLoader.exists(path):
			continue
		var info := load(path) as MinigameInfo
		if info != null and not String(info.id).is_empty():
			result.append(info)
	return result


## Minispiele, die das Format mit dieser Teilnehmerzahl unterstützen.
static func filter(infos: Array[MinigameInfo], format: int, participants: int) -> Array[MinigameInfo]:
	var result: Array[MinigameInfo] = []
	for info: MinigameInfo in infos:
		if info.supports(format, participants):
			result.append(info)
	return result


## Formate, für die es mindestens ein passendes Minispiel gibt.
static func available_formats(infos: Array[MinigameInfo], participants: int) -> Array[int]:
	var result: Array[int] = []
	for format: int in TeamFormat.ALL:
		if not filter(infos, format, participants).is_empty():
			result.append(format)
	return result
