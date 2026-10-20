class_name PushAbility
extends PlayerAbility
## Schubsen: trifft alle Figuren in einem Kegel vor der Figur und gibt ihnen Rückstoß.

signal pushed(target: Node3D)

## Gruppe für Nicht-Spieler, die man schubsen kann (z. B. Wolf). Sie brauchen receive_push(impulse, lift, stun, by).
const PUSHABLE_GROUP: StringName = &"pushable"

## Reichweite ab Figurmitte in Metern.
@export var push_range: float = 1.6
## Öffnungswinkel des Trefferkegels in Grad.
@export_range(10.0, 360.0) var push_angle_deg: float = 110.0
## Waagerechte Rückstoßgeschwindigkeit des Getroffenen (m/s).
@export var push_strength: float = 12.0
## Senkrechter Hüpfer des Getroffenen (m/s).
@export var push_lift: float = 4.5
## So lange hat der Getroffene kaum Kontrolle (Sekunden).
@export var push_stun_time: float = 0.35
## Mindestabstand zwischen zwei Schubsern (Sekunden).
@export var push_cooldown: float = 0.45
## Kleiner Ausfallschritt des Schubsenden (m/s).
@export var lunge_speed: float = 4.0
## Höhenunterschied, bis zu dem noch getroffen wird (Meter).
@export var max_height_difference: float = 1.2

## Teammitglieder schubsen? Aus, wenn ein Minispiel team_check setzt und das nicht will.
var friendly_fire: bool = true
## Optional: Callable(a: int, b: int) -> bool, true wenn beide im selben Team sind.
var team_check: Callable = Callable()

var _cooldown: float = 0.0


func physics_update(delta: float) -> void:
	_cooldown -= delta
	var source: InputSource = player.get_input()
	if source == null or _cooldown > 0.0 or not source.just_pressed(InputBindings.PUSH):
		return
	_cooldown = push_cooldown
	player.visual.play_push()
	Sfx.play(&"push", player.global_position, -3.0)
	player.add_knockback(player.facing * lunge_speed)
	var hit_any: bool = false
	var targets: Array[Node] = player.get_tree().get_nodes_in_group(Player.GROUP)
	targets.append_array(player.get_tree().get_nodes_in_group(PUSHABLE_GROUP))
	for node: Node in targets:
		var other := node as Node3D
		if other == null or other == player or not other.has_method("receive_push"):
			continue
		if node is Player and not friendly_fire and player.slot != null and (node as Player).slot != null and team_check.is_valid() and team_check.call(player.slot.index, (node as Player).slot.index):
			continue
		var offset: Vector3 = other.global_position - player.global_position
		if absf(offset.y) > max_height_difference:
			continue
		offset.y = 0.0
		var distance: float = offset.length()
		if distance > push_range:
			continue
		var direction: Vector3 = player.facing if distance < 0.01 else offset / distance
		if rad_to_deg(player.facing.angle_to(direction)) > push_angle_deg * 0.5:
			continue
		other.call("receive_push", direction * push_strength, push_lift, push_stun_time, player)
		pushed.emit(other)
		hit_any = true
	if hit_any:
		source.rumble(0.35, 0.0, 0.12)
