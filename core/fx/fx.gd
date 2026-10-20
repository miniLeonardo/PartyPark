extends Node
## Autoload Fx: zentraler Zugang zum Effekt-Baukasten (WP 4.2).
## Kamera-Wackeln (CameraShaker), lokaler Hitstop an Figuren, Partikel-Stöße aus einem Objekt-Pool.
## Stärken nach D55/D56 als Konstanten, damit alle Minispiele gleich reagieren.
##
## Beispiele:
##   Fx.shake(Fx.SHAKE_STRONG)                       # Rausfallen, Ausscheiden
##   Fx.burst(&"dust", position)                     # Staubwolke
##   Fx.burst(&"stars", position, player.slot.color)  # Sterne in Spielerfarbe
##   Fx.hitstop([player_a, player_b])                # Treffer kurz einfrieren
##   Fx.squash(player, 0.8)                          # Figur stauchen (rein optisch, D16)

## Trauma-Werte (Ausschlag wächst mit Trauma², D56).
const SHAKE_STRONG: float = 0.9
const SHAKE_MEDIUM: float = 0.65
const SHAKE_LIGHT: float = 0.45
## Hitstop-Dauer in echten Sekunden (D56).
const HITSTOP_TIME: float = 0.06

## Partikel-Vorlagen und wie viele Instanzen jede im Pool hat.
const BURSTS: Dictionary = {
	&"dust": ["res://core/fx/particles/dust.tscn", 10],
	&"dust_ring": ["res://core/fx/particles/dust_ring.tscn", 4],
	&"splash": ["res://core/fx/particles/splash.tscn", 6],
	&"confetti": ["res://core/fx/particles/confetti.tscn", 4],
	&"stars": ["res://core/fx/particles/stars.tscn", 10],
	&"mud": ["res://core/fx/particles/mud.tscn", 8],
	&"chunks": ["res://core/fx/particles/chunks.tscn", 4],
}
## Feste Obergrenze gleichzeitig lebender Partikel (Leistungsbudget Radeon 780M).
const MAX_LIVE_PARTICLES: int = 700

## Platz für Tests: Anzahl Stöße, die wegen der Obergrenze ausgelassen wurden.
var skipped_bursts: int = 0

var _pools: Dictionary = {}
var _next_index: Dictionary = {}
var _pool_root: Node3D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_pool_root = Node3D.new()
	_pool_root.name = "Particles"
	# Partikel frieren in der Pause ein, laufen in Zeitlupe langsamer (gewollt)
	_pool_root.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(_pool_root)
	for kind: StringName in BURSTS:
		var entry: Array = BURSTS[kind]
		var scene := load(String(entry[0])) as PackedScene
		var list: Array[FxBurst] = []
		for i: int in int(entry[1]):
			var burst := scene.instantiate() as FxBurst
			_pool_root.add_child(burst)
			list.append(burst)
		_pools[kind] = list
		_next_index[kind] = 0


# --- Kamera ---

## Wackelt alle aktiven Kameras (Hauptansicht und Splitscreen-Kameras in der Gruppe "fx_cameras").
func shake(trauma: float, camera: Camera3D = null) -> void:
	if camera != null:
		_shaker_for(camera).add_trauma(trauma)
		return
	for cam: Camera3D in _cameras():
		_shaker_for(cam).add_trauma(trauma)


## Stärkste aktuelle Wackelstärke (für Tests).
func current_shake() -> float:
	var best: float = 0.0
	for cam: Camera3D in _cameras():
		var shaker := cam.get_node_or_null("CameraShaker") as CameraShaker
		if shaker != null:
			best = maxf(best, shaker.get_shake())
	return best


func _cameras() -> Array[Camera3D]:
	var list: Array[Camera3D] = []
	var main: Camera3D = get_viewport().get_camera_3d()
	if main != null:
		list.append(main)
	for node: Node in get_tree().get_nodes_in_group(&"fx_cameras"):
		var cam := node as Camera3D
		if cam != null and not list.has(cam):
			list.append(cam)
	return list


func _shaker_for(camera: Camera3D) -> CameraShaker:
	var shaker := camera.get_node_or_null("CameraShaker") as CameraShaker
	if shaker == null:
		shaker = CameraShaker.new()
		shaker.name = "CameraShaker"
		camera.add_child(shaker)
	return shaker


# --- Partikel ---

## Startet einen Partikel-Stoß. Farbe mit Alpha 0 = Grundfarbe der Vorlage.
func burst(kind: StringName, world_position: Vector3, color: Color = Color(0, 0, 0, 0), size_factor: float = 1.0) -> void:
	var list: Array = _pools.get(kind, [])
	if list.is_empty():
		push_warning("Fx: unbekannte Partikel-Vorlage %s" % kind)
		return
	var index: int = int(_next_index[kind])
	var particles: FxBurst = list[index]
	# Wird die älteste Instanz neu gestartet, fallen ihre Partikel weg; sonst kommt die Menge hinzu.
	var added: int = particles.amount if not particles.emitting else 0
	if live_particles() + added > MAX_LIVE_PARTICLES:
		skipped_bursts += 1
		return
	_next_index[kind] = (index + 1) % list.size()
	particles.emit_at(world_position, color, size_factor)


## Grobe Zahl gerade lebender Partikel (Summe der laufenden Stöße).
func live_particles() -> int:
	var total: int = 0
	for kind: StringName in _pools:
		for particles: FxBurst in _pools[kind]:
			if particles.emitting:
				total += particles.amount
	return total


## Größtmögliche Partikelzahl aller Pools (zur Dokumentation des Budgets).
func pool_capacity() -> int:
	var total: int = 0
	for kind: StringName in _pools:
		for particles: FxBurst in _pools[kind]:
			total += particles.amount
	return total


## Stoppt alle Partikel und Wackler (beim Verlassen eines Minispiels).
func clear() -> void:
	for kind: StringName in _pools:
		for particles: FxBurst in _pools[kind]:
			particles.emitting = false
			particles.visible = false


# --- Figuren ---

## Friert die Figuren kurz ein (lokal, ohne Engine.time_scale, D42/D56).
func hitstop(targets: Array, duration: float = HITSTOP_TIME) -> void:
	for target: Variant in targets:
		var player := target as Player
		if player != null and is_instance_valid(player):
			player.apply_hitstop(duration)


## Squash-Impuls an der Figur (positiv = stauchen, negativ = strecken), rein optisch (D16).
func squash(player: Player, amount: float) -> void:
	if player != null and is_instance_valid(player):
		player.visual.punch_squash(amount)
