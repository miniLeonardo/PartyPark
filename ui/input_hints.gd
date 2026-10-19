class_name InputHints
extends RefCounted
## Baut Tastenhinweise passend zu den Geräten, mit denen gerade gespielt wird (D28).
## Beispiel: „Esc (Tastatur links) · Start (Controller)“.

const SEPARATOR: String = "  ·  "


## Eine Aktion für mehrere Quellen; gleiche Beschriftung auf gleicher Geräteart erscheint nur einmal.
static func for_sources(sources: Array[InputSource], action: StringName) -> String:
	var parts: PackedStringArray = []
	for source: InputSource in sources:
		var part: String = "%s (%s)" % [source.get_action_label(action), source.get_kind_name()]
		if not parts.has(part):
			parts.append(part)
	return SEPARATOR.join(parts)


## Eine Aktion für alle beigetretenen, verbundenen Menschen.
static func for_humans(action: StringName) -> String:
	return for_sources(human_sources(), action)


static func human_sources() -> Array[InputSource]:
	var result: Array[InputSource] = []
	for slot: PlayerSlot in PlayerRoster.get_human_slots():
		if not slot.disconnected:
			result.append(slot.source)
	return result


## Freie Quellen, die jetzt beitreten könnten.
static func joinable_sources() -> Array[InputSource]:
	var result: Array[InputSource] = []
	for source: InputSource in InputRouter.get_sources():
		if source.is_joinable() and source.is_available() and not PlayerRoster.has_source(source):
			result.append(source)
	return result
