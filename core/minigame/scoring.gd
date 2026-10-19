class_name Scoring
extends RefCounted
## Punktevergabe im Schnellturnier (D31, Teamregel Platzhalter Q13).

## Punkte für Platz 1 bis 4 in „Jeder gegen jeden“.
const PLACE_POINTS: Array[int] = [3, 2, 1, 0]
## Punkte für jeden Spieler bei einem Koop-Sieg gegen den Computer.
const COOP_WIN_POINTS: int = 2
## Teamformate: Punkte pro Mitglied des Siegerteams, der Verlierer und bei Unentschieden (Q13).
const TEAM_WIN_POINTS: int = 3
const TEAM_LOSS_POINTS: int = 0
const TEAM_DRAW_POINTS: int = 1


## Platzindex → Punkte für diese Runde.
static func points_for(result: MinigameResult, format: int) -> Dictionary:
	var points: Dictionary = {}
	for index: int in result.placements:
		var place: int = result.placements[index]
		match format:
			TeamFormat.Format.COOP_VS_CPU:
				points[index] = COOP_WIN_POINTS if result.coop_won else 0
			TeamFormat.Format.FFA:
				points[index] = PLACE_POINTS[clampi(place, 1, 4) - 1]
			_:
				if result.is_draw:
					points[index] = TEAM_DRAW_POINTS
				else:
					points[index] = TEAM_WIN_POINTS if place == 1 else TEAM_LOSS_POINTS
	return points


## Gesamtstand als Rangliste: Array von Gruppen (gleiche Punkte = gleicher Rang), beste zuerst.
static func standings(totals: Dictionary) -> Array:
	var indices: Array = totals.keys()
	indices.sort_custom(func(a: int, b: int) -> bool: return totals[a] > totals[b] or (totals[a] == totals[b] and a < b))
	var groups: Array = []
	var last_score: int = -2147483648
	for index: int in indices:
		if groups.is_empty() or totals[index] != last_score:
			groups.append([index])
			last_score = totals[index]
		else:
			(groups[groups.size() - 1] as Array).append(index)
	return groups
