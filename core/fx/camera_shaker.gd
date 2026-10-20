class_name CameraShaker
extends Node
## Kamera-Wackeln nach dem Trauma-Prinzip („The Art of Screenshake“): Trauma 0 bis 1 wird addiert,
## der Ausschlag ist proportional zu Trauma², gesteuert über Rauschen statt Zufall und klingt in
## unskalierter Zeit ab (läuft also auch in Zeitlupe und Pause sauber aus).
## Kind einer Camera3D. Verschiebung über h_offset/v_offset, Neigung über eine Drehung um die
## Blickachse; funktioniert mit ArenaCamera (setzt ihre Lage jeden Frame neu) und festen Kameras.

## Höchstausschlag seitlich und hoch (Meter, D55: dezent).
@export var max_offset: float = 0.25
## Höchste Neigung um die Blickachse (Grad, D55: dezent).
@export var max_roll_deg: float = 1.5
## Trauma-Abbau pro Sekunde.
@export var decay: float = 1.6
## Rauschfrequenz (höher = hektischer).
@export var frequency: float = 18.0

var trauma: float = 0.0

var _camera: Camera3D
var _noise := FastNoiseLite.new()
var _time: float = 0.0
var _applied_roll: float = 0.0
var _written_basis: Basis = Basis.IDENTITY
var _last_ticks: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_priority = 100
	_camera = get_parent() as Camera3D
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.frequency = 1.0
	_noise.seed = randi()
	_last_ticks = Time.get_ticks_usec()


## Trauma hinzufügen (0 bis 1, wird auf 1 begrenzt).
func add_trauma(amount: float) -> void:
	trauma = clampf(trauma + amount, 0.0, 1.0)


## Aktuelle Wackelstärke (Trauma²), für Tests.
func get_shake() -> float:
	return trauma * trauma


func _process(_delta: float) -> void:
	var now: int = Time.get_ticks_usec()
	var real_delta: float = minf(float(now - _last_ticks) / 1_000_000.0, 0.1)
	_last_ticks = now
	if _camera == null:
		return
	_time += real_delta
	trauma = maxf(0.0, trauma - decay * real_delta)
	var shake: float = trauma * trauma if Settings.screen_shake else 0.0
	var t: float = _time * frequency
	_camera.h_offset = max_offset * shake * _noise.get_noise_2d(t, 0.0)
	_camera.v_offset = max_offset * shake * _noise.get_noise_2d(t, 100.0)
	var roll: float = deg_to_rad(max_roll_deg) * shake * _noise.get_noise_2d(t, 200.0)
	# Hat niemand die Kamera seit unserem letzten Schreiben neu ausgerichtet, alte Neigung entfernen.
	if _camera.basis.is_equal_approx(_written_basis):
		_camera.rotate_object_local(Vector3.BACK, -_applied_roll)
	_applied_roll = 0.0
	if absf(roll) > 0.00001:
		_camera.rotate_object_local(Vector3.BACK, roll)
		_applied_roll = roll
	_written_basis = _camera.basis
