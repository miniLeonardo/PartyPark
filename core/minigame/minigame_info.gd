class_name MinigameInfo
extends Resource
## Beschreibungsdatei eines Minispiels (`minigames/<id>/info.tres`). Die Registry findet sie automatisch.

@export var id: StringName = &""
@export var display_name: String = ""
## Unterstützte Teamformate (Werte aus TeamFormat.Format).
@export var formats: Array[int] = []
@export var min_players: int = 2
@export var max_players: int = 4
## Ungefähre Dauer in Sekunden (für Anzeige und Zeitlimit).
@export var duration_sec: float = 60.0
## Ziel in einem Satz für den Regelbildschirm.
@export_multiline var goal_text: String = ""
## Steuerung: Aktion (move, jump, action, push, special) → Beschreibung.
@export var controls: Dictionary = {}
## Nur 1 gegen 3: Ziel und Steuerung des Solo-Spielers, falls abweichend.
@export_multiline var solo_goal_text: String = ""
@export var solo_controls: Dictionary = {}
## Nur 1 gegen 3: Rollennamen, z. B. „Riese“ und „Zwerge“.
@export var solo_role_name: String = ""
@export var team_role_name: String = ""
## Pfad zur Szene des Minispiels (Wurzel erbt von Minigame).
@export_file("*.tscn") var scene_path: String = ""


func supports(format: int, participants: int) -> bool:
	if not formats.has(format):
		return false
	if participants < maxi(min_players, TeamFormat.min_participants(format)):
		return false
	return participants <= mini(max_players, TeamFormat.max_participants(format))
