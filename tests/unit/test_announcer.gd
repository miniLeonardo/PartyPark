extends TestCase
## Tests für den Ansager (WP 4.4): Spruchlisten, Platzhalter, keine direkte Wiederholung.

const EVENTS: Array[String] = ["round_start", "countdown", "close_call", "win", "bad_luck", "coop_lost", "draw", "tournament_end"]


func _make() -> Node:
	var announcer: Node = (load("res://core/announcer/announcer.gd") as GDScript).new()
	announcer.call("_ready")
	return announcer


func test_every_event_has_lines() -> void:
	var announcer: Node = _make()
	for event: String in EVENTS:
		var lines: Array = announcer.call("get_lines", StringName(event))
		assert_true(lines.size() >= 3, "%s hat mindestens 3 Sprüche" % event)
	announcer.free()


func test_events_used_in_code_exist() -> void:
	var announcer: Node = _make()
	var events: Array = announcer.call("get_events")
	var regex := RegEx.create_from_string("Announcer\\.say\\(&\"([a-z_]+)\"")
	var found: int = 0
	for path: String in ["res://core/minigame/match_flow.gd", "res://modes/tournament/tournament_ceremony.gd", "res://minigames/bumper_cars/bumper_cars.gd", "res://minigames/giant_vs_dwarfs/giant_vs_dwarfs.gd"]:
		for match: RegExMatch in regex.search_all(FileAccess.get_file_as_string(path)):
			found += 1
			assert_true(events.has(StringName(match.get_string(1))), "%s: Ereignis %s hat Sprüche" % [path, match.get_string(1)])
	assert_true(found >= 6, "Aufrufe gefunden (%d)" % found)
	announcer.free()


func test_placeholders_are_filled_and_no_direct_repeat() -> void:
	var announcer: Node = _make()
	var previous: String = ""
	for i: int in 30:
		announcer.call("stop")
		announcer.call("say", &"win", {"winner": "Spieler 3"})
		var line: String = announcer.get("last_line")
		assert_true(line.contains("Spieler 3"), "Name eingesetzt: %s" % line)
		assert_true(not line.contains("{"), "kein offener Platzhalter: %s" % line)
		assert_true(line != previous, "keine direkte Wiederholung")
		previous = line
	announcer.free()


func test_more_important_line_interrupts() -> void:
	var announcer: Node = _make()
	announcer.call("say", &"bad_luck", {"player": "X"})
	announcer.call("say", &"win", {"winner": "Y"})
	assert_eq(announcer.get("last_event"), &"win", "Sieg unterbricht Pech")
	announcer.call("say", &"countdown")
	assert_eq(announcer.get("last_event"), &"win", "Unwichtiges unterbricht nicht")
	announcer.free()
