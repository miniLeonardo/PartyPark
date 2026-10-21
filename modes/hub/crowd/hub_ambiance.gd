class_name HubAmbiance
extends Node
## Zonenabhängige Audio-Atmosphäre für den Freizeitpark (D117).
## Steuert Park-Gemurmel, Kirmes-Glocken im Rummel und Wind in Turmhöhe.

var _global_timer: float = 3.0
var _rummel_timer: float = 5.0
var _tower_timer: float = 4.0

var _hub: Hub


func _ready() -> void:
	_hub = get_parent() as Hub


func _process(delta: float) -> void:
	if _hub == null or not Game.match_running or _hub.active_flow != null:
		return

	var current_zone: int = _hub._current_zone
	var max_player_y: float = 0.0
	for p: Player in _hub.players:
		max_player_y = maxf(max_player_y, p.global_position.y)

	# 1. Globales Parkgemurmel & Heiterkeit (alle Zonen)
	_global_timer -= delta
	if _global_timer <= 0.0:
		_global_timer = randf_range(8.0, 14.0)
		# Dezent heitere Parkgeräusche
		if randf() < 0.4:
			Sfx.play(&"cheer")

	# 2. Rummelplatz-Ambiente (Ost-Zone: Glocken & Bimmeln, D117)
	if current_zone == Hub.ParkZone.RUMMEL:
		_rummel_timer -= delta
		if _rummel_timer <= 0.0:
			_rummel_timer = randf_range(5.0, 9.0)
			Sfx.play(&"bell")
	else:
		_rummel_timer = 4.0

	# 3. Turm-Wind & Kletterhöhe (Nord-Zone / Höhe > 6.0 m, D117)
	if current_zone == Hub.ParkZone.PARKOUR or max_player_y > 6.0:
		_tower_timer -= delta
		if _tower_timer <= 0.0:
			_tower_timer = randf_range(5.0, 8.0)
			Sfx.play(&"breeze")
	else:
		_tower_timer = 3.0
