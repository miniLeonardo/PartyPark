class_name JumpAbility
extends PlayerAbility
## Springen mit variabler Höhe (früh loslassen = kürzer), Coyote-Zeit und Sprungpuffer.

signal jumped

## Absprunggeschwindigkeit in m/s. Sprunghöhe ≈ v² / (2 · Schwerkraft).
@export var jump_velocity: float = 10.0
## Faktor auf die Aufwärtsgeschwindigkeit, wenn die Taste früh losgelassen wird.
@export_range(0.0, 1.0) var jump_cut_multiplier: float = 0.45
## So lange nach dem Verlassen einer Kante darf noch gesprungen werden (Sekunden).
@export var coyote_time: float = 0.1
## So lange vor der Landung wird ein Sprungdruck gemerkt (Sekunden).
@export var jump_buffer_time: float = 0.12

var _coyote: float = 0.0
var _buffer: float = 0.0
var _rising: bool = false


func physics_update(delta: float) -> void:
	var source: InputSource = player.get_input()
	if player.is_on_floor():
		_coyote = coyote_time
	else:
		_coyote -= delta
	if source != null and source.just_pressed(InputBindings.JUMP):
		_buffer = jump_buffer_time
	else:
		_buffer -= delta
	if _buffer > 0.0 and _coyote > 0.0:
		player.velocity.y = jump_velocity
		_buffer = 0.0
		_coyote = 0.0
		_rising = true
		player.visual.play_jump()
		Sfx.play(&"jump", player.global_position, -4.0, 1.0 / sqrt(player.body_scale))
		jumped.emit()
	if _rising:
		if player.velocity.y <= 0.0:
			_rising = false
		elif source == null or not source.is_down(InputBindings.JUMP):
			player.velocity.y *= jump_cut_multiplier
			_rising = false
