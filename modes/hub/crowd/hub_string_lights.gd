class_name HubStringLights
extends Node3D
## Dynamisch pulsierende Lichterketten für den Freizeitpark (D116).
## Erzeugt sanft schwingende Lichteffekte an den bunten Birnen.
## Am Tag dezent glimmend, in der Abendstimmung hell leuchtend.

@export var pulse_speed: float = 2.4
@export var base_energy: float = 1.0

var _bulb_materials: Array[StandardMaterial3D] = []
var _phase_offsets: Array[float] = []


func _ready() -> void:
	_setup_materials()


func _setup_materials() -> void:
	_bulb_materials.clear()
	_phase_offsets.clear()

	var bulbs: Array[Node] = find_children("*", "MeshInstance3D", true, false)
	for node: Node in bulbs:
		var mi := node as MeshInstance3D
		if mi == null or mi.mesh is CylinderMesh:
			continue # Draht überspringen

		var mat: Material = mi.material_override
		if mat is StandardMaterial3D:
			# Eigene Duplikat-Instanz erstellen, damit die Glühbirnen unabhängig pulsieren können
			var dup: StandardMaterial3D = mat.duplicate() as StandardMaterial3D
			mi.material_override = dup
			_bulb_materials.append(dup)
			_phase_offsets.append(randf() * TAU)


func _process(_delta: float) -> void:
	var t: float = Time.get_ticks_msec() * 0.001
	var is_evening: bool = (Look.mood == Look.Mood.EVENING)
	var mood_multiplier: float = 2.8 if is_evening else 1.2

	for i: int in _bulb_materials.size():
		var mat: StandardMaterial3D = _bulb_materials[i]
		var phase: float = _phase_offsets[i]
		var pulse: float = sin(t * pulse_speed + phase) * 0.4 + 0.9
		mat.emission_energy_multiplier = base_energy * pulse * mood_multiplier
