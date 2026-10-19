extends TestCase
## Tests für Punktevergabe (D31, Q13) und Ergebnisse.


func test_ffa_places_give_3_2_1_0() -> void:
	var result: MinigameResult = MinigameResult.from_ranking([[2], [0], [3], [1]])
	var points: Dictionary = Scoring.points_for(result, TeamFormat.Format.FFA)
	assert_eq(points, {2: 3, 0: 2, 3: 1, 1: 0}, "Punkte nach Platz")


func test_ffa_tie_shares_better_place() -> void:
	var result: MinigameResult = MinigameResult.from_ranking([[1, 2], [0], [3]])
	assert_eq(result.get_place(1), 1, "geteilter erster Platz")
	assert_eq(result.get_place(0), 3, "danach Platz 3")
	var points: Dictionary = Scoring.points_for(result, TeamFormat.Format.FFA)
	assert_eq(points[1], 3, "beide Ersten 3 Punkte")
	assert_eq(points[2], 3, "beide Ersten 3 Punkte")
	assert_eq(points[0], 1, "Platz 3 gibt 1 Punkt")


func test_team_win_gives_winners_3_losers_0() -> void:
	var result: MinigameResult = MinigameResult.team_win([0, 3], [1, 2])
	var points: Dictionary = Scoring.points_for(result, TeamFormat.Format.TWO_VS_TWO)
	assert_eq(points, {0: 3, 3: 3, 1: 0, 2: 0}, "Siegerteam 3, Verlierer 0")


func test_team_draw_gives_everyone_1() -> void:
	var result: MinigameResult = MinigameResult.draw([0, 1, 2, 3])
	var points: Dictionary = Scoring.points_for(result, TeamFormat.Format.ONE_VS_THREE)
	assert_eq(points, {0: 1, 1: 1, 2: 1, 3: 1}, "Unentschieden 1 für alle")


func test_coop_win_and_loss() -> void:
	var won: Dictionary = Scoring.points_for(MinigameResult.coop([0, 1, 2, 3], true), TeamFormat.Format.COOP_VS_CPU)
	assert_eq(won, {0: 2, 1: 2, 2: 2, 3: 2}, "Koop-Sieg 2 für alle")
	var lost: Dictionary = Scoring.points_for(MinigameResult.coop([0, 1, 2, 3], false), TeamFormat.Format.COOP_VS_CPU)
	assert_eq(lost, {0: 0, 1: 0, 2: 0, 3: 0}, "Koop-Niederlage 0")


func test_standings_groups_equal_scores() -> void:
	var groups: Array = Scoring.standings({0: 5, 1: 8, 2: 5, 3: 1})
	assert_eq(groups, [[1], [0, 2], [3]], "Rangliste mit Gleichstand")
