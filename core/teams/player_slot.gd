class_name PlayerSlot
extends RefCounted
## Ein fester Spielerplatz (1 bis 4). Gehört PlayerRoster.

var index: int = 0
var color: Color = Color.WHITE
var display_name: String = ""
## Eingabequelle; null bedeutet, der Platz ist frei.
var source: InputSource = null
var is_cpu: bool = false
## Controller wurde während des Spiels getrennt, Platz wartet auf Übernahme.
var disconnected: bool = false
## Gesamtpunkte im laufenden Turnier (ab M2).
var total_score: int = 0


func _init(p_index: int, p_color: Color, p_name: String) -> void:
	index = p_index
	color = p_color
	display_name = p_name


func is_empty() -> bool:
	return source == null


func is_human() -> bool:
	return source != null and not is_cpu


## Kurzname für Anzeigen über der Figur.
func get_tag() -> String:
	return "CPU" if is_cpu else "P%d" % (index + 1)
