extends TestCase
## Tests für TeamAssigner (D32).

const PLAYERS: Array[int] = [0, 1, 2, 3]


func test_ffa_puts_everyone_in_own_team() -> void:
	var a: TeamAssigner.Assignment = TeamAssigner.assign(make_rng(), TeamFormat.Format.FFA, PLAYERS)
	assert_eq(a.teams.size(), 4, "vier Einzelteams")
	for team: Array in a.teams:
		assert_eq(team.size(), 1, "jedes Team hat ein Mitglied")


func test_coop_is_one_team() -> void:
	var a: TeamAssigner.Assignment = TeamAssigner.assign(make_rng(), TeamFormat.Format.COOP_VS_CPU, PLAYERS)
	assert_eq(a.teams.size(), 1, "ein Team")
	assert_eq((a.teams[0] as Array).size(), 4, "mit allen vier")


func test_two_vs_two_has_two_pairs_covering_all() -> void:
	for seed_value: int in 20:
		var a: TeamAssigner.Assignment = TeamAssigner.assign(make_rng(seed_value), TeamFormat.Format.TWO_VS_TWO, PLAYERS)
		assert_eq(a.teams.size(), 2, "zwei Teams")
		var all: Array = (a.teams[0] as Array) + (a.teams[1] as Array)
		all.sort()
		assert_eq(all, [0, 1, 2, 3], "alle Spieler genau einmal")


func test_two_vs_two_never_repeats_last_pairing() -> void:
	var rng: RandomNumberGenerator = make_rng(7)
	var last: Array = []
	for i: int in 50:
		var a: TeamAssigner.Assignment = TeamAssigner.assign(rng, TeamFormat.Format.TWO_VS_TWO, PLAYERS, {}, last)
		if not last.is_empty():
			assert_true(TeamAssigner.pairing_key(a.teams) != TeamAssigner.pairing_key(last), "Paarung wiederholt sich nicht (Runde %d)" % i)
		last = a.teams


func test_one_vs_three_solo_is_last_placed() -> void:
	var scores: Dictionary = {0: 9, 1: 3, 2: 7, 3: 5}
	var a: TeamAssigner.Assignment = TeamAssigner.assign(make_rng(), TeamFormat.Format.ONE_VS_THREE, PLAYERS, scores)
	assert_eq(a.solo, 1, "Spieler mit den wenigsten Punkten ist Solo")
	assert_eq(a.teams[0], [1], "Solo-Team")
	assert_eq((a.teams[1] as Array).size(), 3, "drei gegen ihn")


func test_one_vs_three_tie_picks_among_lowest() -> void:
	var scores: Dictionary = {0: 2, 1: 5, 2: 2, 3: 8}
	for seed_value: int in 20:
		var solo: int = TeamAssigner.pick_last_placed(make_rng(seed_value), PLAYERS, scores)
		assert_true(solo == 0 or solo == 2, "bei Gleichstand nur unter den Letzten (war %d)" % solo)


func test_pick_format_avoids_last_and_respects_allowed() -> void:
	var rng: RandomNumberGenerator = make_rng(3)
	var allowed: Array[int] = [TeamFormat.Format.FFA, TeamFormat.Format.TWO_VS_TWO]
	for i: int in 100:
		var format: int = TeamAssigner.pick_format(rng, allowed, TeamFormat.Format.FFA)
		assert_eq(format, TeamFormat.Format.TWO_VS_TWO, "letztes Format wird gemieden")
	var single: Array[int] = [TeamFormat.Format.FFA]
	assert_eq(TeamAssigner.pick_format(rng, single, TeamFormat.Format.FFA), TeamFormat.Format.FFA, "ohne Alternative bleibt es beim Format")


func test_pick_format_weights_roughly_match() -> void:
	var rng: RandomNumberGenerator = make_rng(99)
	var counts: Dictionary = {}
	var n: int = 4000
	for i: int in n:
		var format: int = TeamAssigner.pick_format(rng, TeamFormat.ALL)
		counts[format] = int(counts.get(format, 0)) + 1
	for format: int in TeamFormat.ALL:
		var share: float = float(counts.get(format, 0)) / float(n) * 100.0
		var expected: float = TeamFormat.WEIGHTS[format]
		assert_true(absf(share - expected) < 4.0, "Anteil %s etwa %d %% (war %.1f %%)" % [TeamFormat.display_name(format), int(expected), share])


func test_pick_game_avoids_last() -> void:
	var rng: RandomNumberGenerator = make_rng(5)
	var games: Array[StringName] = [&"a", &"b"]
	for i: int in 30:
		assert_eq(TeamAssigner.pick_game(rng, games, &"a"), &"b", "letztes Spiel wird gemieden")
