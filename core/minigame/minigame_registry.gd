extends Node
## Autoload MinigameRegistry: findet beim Start alle Minispiele in `res://minigames/*/info.tres`.

var infos: Array[MinigameInfo] = []


func _ready() -> void:
	infos = MinigameCatalog.scan()
	print("MinigameRegistry: %d Minispiele gefunden" % infos.size())


func get_info(id: StringName) -> MinigameInfo:
	for info: MinigameInfo in infos:
		if info.id == id:
			return info
	return null


func filter(format: int, participants: int) -> Array[MinigameInfo]:
	return MinigameCatalog.filter(infos, format, participants)


func available_formats(participants: int) -> Array[int]:
	return MinigameCatalog.available_formats(infos, participants)
