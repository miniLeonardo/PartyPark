extends Node
## Autoload PlayerRoster: die 4 festen Spielerplätze mit Eingabequelle, Farbe und Computer-Status.

signal player_joined(slot: PlayerSlot)
signal player_left(slot: PlayerSlot)
signal player_disconnected(slot: PlayerSlot)
signal player_reconnected(slot: PlayerSlot)
## Irgendetwas an den Plätzen hat sich geändert (für Anzeigen).
signal roster_changed

const MAX_PLAYERS: int = 4

## Spielerfarben, Platzhalter auf Basis der farbsehschwächen-sicheren Okabe-Ito-Palette
## (Blau, Zinnoberrot, Gelb, Blaugrün). Endgültige Farben sind Design, siehe DECISIONS.
const PLAYER_COLORS: Array[Color] = [
	Color("#1f7ae0"),
	Color("#e5531a"),
	Color("#f2d72e"),
	Color("#14a37f"),
]

var slots: Array[PlayerSlot] = []
## Fehlende Plätze beim Start mit Computergegnern auffüllen (D19).
var cpu_fill_enabled: bool = true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i: int in MAX_PLAYERS:
		slots.append(PlayerSlot.new(i, PLAYER_COLORS[i], "Spieler %d" % (i + 1)))
	InputRouter.source_disconnected.connect(_on_source_disconnected)
	InputRouter.source_connected.connect(_on_source_connected)


func has_source(source: InputSource) -> bool:
	return get_slot_for_source(source) != null


func get_slot_for_source(source: InputSource) -> PlayerSlot:
	for slot: PlayerSlot in slots:
		if slot.source == source:
			return slot
	return null


## Belegt den ersten Platz ohne Menschen. Gibt null zurück, wenn alles voll ist.
func join(source: InputSource) -> PlayerSlot:
	if has_source(source):
		return get_slot_for_source(source)
	for slot: PlayerSlot in slots:
		if slot.is_human():
			continue
		if slot.is_cpu:
			_remove_cpu(slot)
		slot.source = source
		slot.is_cpu = false
		slot.disconnected = false
		player_joined.emit(slot)
		roster_changed.emit()
		return slot
	return null


func leave(slot: PlayerSlot) -> void:
	if slot.is_empty():
		return
	if slot.is_cpu:
		_remove_cpu(slot)
	slot.source = null
	slot.is_cpu = false
	slot.disconnected = false
	player_left.emit(slot)
	roster_changed.emit()


## Übergibt einen getrennten Platz an eine neue Quelle.
func reassign(slot: PlayerSlot, source: InputSource) -> void:
	slot.source = source
	slot.disconnected = false
	player_reconnected.emit(slot)
	roster_changed.emit()


## Belegte Plätze (Menschen und Computer), aufsteigend nach Index.
func get_active_slots() -> Array[PlayerSlot]:
	var result: Array[PlayerSlot] = []
	for slot: PlayerSlot in slots:
		if not slot.is_empty():
			result.append(slot)
	return result


func get_human_slots() -> Array[PlayerSlot]:
	var result: Array[PlayerSlot] = []
	for slot: PlayerSlot in slots:
		if slot.is_human():
			result.append(slot)
	return result


func human_count() -> int:
	return get_human_slots().size()


func get_disconnected_slots() -> Array[PlayerSlot]:
	var result: Array[PlayerSlot] = []
	for slot: PlayerSlot in slots:
		if slot.disconnected:
			result.append(slot)
	return result


## Füllt alle freien Plätze mit Computergegnern auf.
func fill_with_cpu() -> void:
	for slot: PlayerSlot in slots:
		if slot.is_empty():
			var ai := AIInput.new(slot.index)
			InputRouter.register_source(ai)
			slot.source = ai
			slot.is_cpu = true
	roster_changed.emit()


## Entfernt alle Computergegner (z. B. bei Rückkehr zum Beitrittsbildschirm).
func clear_cpus() -> void:
	for slot: PlayerSlot in slots:
		if slot.is_cpu:
			_remove_cpu(slot)
			slot.source = null
			slot.is_cpu = false
	roster_changed.emit()


func _remove_cpu(slot: PlayerSlot) -> void:
	if slot.source != null:
		InputRouter.unregister_source(slot.source)


func _on_source_disconnected(source: InputSource) -> void:
	var slot: PlayerSlot = get_slot_for_source(source)
	if slot == null:
		return
	slot.disconnected = true
	player_disconnected.emit(slot)
	roster_changed.emit()


## Steckt derselbe Controller-Typ an derselben Geräte-ID wieder an, übernimmt er den Platz automatisch.
func _on_source_connected(source: InputSource) -> void:
	if not source is GamepadInput:
		return
	var pad := source as GamepadInput
	for slot: PlayerSlot in slots:
		if not slot.disconnected or not slot.source is GamepadInput:
			continue
		var old := slot.source as GamepadInput
		if old.device == pad.device and old.guid == pad.guid:
			reassign(slot, pad)
			return
