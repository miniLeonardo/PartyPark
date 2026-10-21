class_name HubCamera
extends ArenaCamera
## Großraum-Kamera für den Freizeitpark-Hub (D99).
## Hält alle aktiven Spieler im Bild, erlaubt großflächiges Erkunden der Zonen
## und federt Höhenunterschiede (Kletterturm) sanft ab.


func _ready() -> void:
	pitch_deg = 48.0
	yaw_deg = 0.0
	min_distance = 14.0
	max_distance = 48.0
	padding = 5.0
	follow_smoothing = 4.0
	zoom_smoothing = 2.5
	target_offset = Vector3(0.0, 1.2, 0.0)
	ignore_below_height = -5.0
	super._ready()
