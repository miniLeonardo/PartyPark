extends TestCase
## Tests für das Finden und Filtern der Minispiele (MinigameCatalog).


func _make(id: StringName, formats: Array[int], min_players: int, max_players: int) -> MinigameInfo:
	var info := MinigameInfo.new()
	info.id = id
	info.formats = formats
	info.min_players = min_players
	info.max_players = max_players
	return info


func test_scan_finds_all_shipped_minigames() -> void:
	var infos: Array[MinigameInfo] = MinigameCatalog.scan()
	var ids: Array = []
	for info: MinigameInfo in infos:
		ids.append(String(info.id))
		assert_true(ResourceLoader.exists(info.scene_path), "Szene von %s existiert" % info.id)
		assert_true(not info.goal_text.is_empty(), "%s hat einen Zieltext" % info.id)
	ids.sort()
	assert_eq(ids, ["blaster_brawl", "bumper_cars", "giant_vs_dwarfs", "hex_fall", "hot_potato", "sheep_herding", "tug_of_war"], "alle Minispiele gefunden")


func test_filter_by_format_and_players() -> void:
	var infos: Array[MinigameInfo] = [
		_make(&"ffa", [TeamFormat.Format.FFA], 2, 4),
		_make(&"pairs", [TeamFormat.Format.TWO_VS_TWO], 4, 4),
		_make(&"coop", [TeamFormat.Format.COOP_VS_CPU], 1, 4),
	]
	assert_eq(MinigameCatalog.filter(infos, TeamFormat.Format.FFA, 3).size(), 1, "FFA mit 3 Spielern")
	assert_eq(MinigameCatalog.filter(infos, TeamFormat.Format.TWO_VS_TWO, 3).size(), 0, "2v2 braucht 4")
	assert_eq(MinigameCatalog.filter(infos, TeamFormat.Format.TWO_VS_TWO, 4).size(), 1, "2v2 mit 4")
	assert_eq(MinigameCatalog.filter(infos, TeamFormat.Format.FFA, 1).size(), 0, "FFA braucht mindestens 2")


func test_available_formats_depend_on_player_count() -> void:
	var infos: Array[MinigameInfo] = MinigameCatalog.scan()
	var with_four: Array[int] = MinigameCatalog.available_formats(infos, 4)
	assert_eq(with_four.size(), 4, "mit 4 Spielern alle Formate")
	var with_two: Array[int] = MinigameCatalog.available_formats(infos, 2)
	assert_true(with_two.has(TeamFormat.Format.FFA) and with_two.has(TeamFormat.Format.COOP_VS_CPU), "mit 2 Spielern FFA und Koop")
	assert_true(not with_two.has(TeamFormat.Format.TWO_VS_TWO), "mit 2 Spielern kein 2v2")
	var with_one: Array[int] = MinigameCatalog.available_formats(infos, 1)
	assert_eq(with_one, [TeamFormat.Format.COOP_VS_CPU], "allein nur Koop")
