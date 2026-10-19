class_name MinigameResult
extends RefCounted
## Ergebnis eines Minispiels: Platz pro Spielerplatz (1 = bester). Punkte berechnet `Scoring`.

## Platzindex (0 bis 3) → Platz (1 bis 4).
var placements: Dictionary = {}
## Alle gegen den Computer: haben die Spieler gewonnen?
var coop_won: bool = false
## Unentschieden (z. B. Zeit abgelaufen ohne Sieger in Teamformaten).
var is_draw: bool = false
## Kurzer Text für den Ergebnisbildschirm, z. B. „Team Orange gewinnt!“.
var headline: String = ""


## Gruppen von Platzindizes vom besten zum schlechtesten; eine Gruppe teilt sich den Platz.
static func from_ranking(groups: Array) -> MinigameResult:
	var result := MinigameResult.new()
	var place: int = 1
	for group: Array in groups:
		for index: int in group:
			result.placements[index] = place
		place += group.size()
	return result


static func team_win(winners: Array, losers: Array) -> MinigameResult:
	return from_ranking([winners, losers])


static func draw(players: Array) -> MinigameResult:
	var result: MinigameResult = from_ranking([players])
	result.is_draw = true
	return result


static func coop(players: Array, won: bool) -> MinigameResult:
	var result: MinigameResult = from_ranking([players])
	result.coop_won = won
	return result


func get_place(index: int) -> int:
	return placements.get(index, 4)


## Platzindizes mit Platz 1.
func get_winners() -> Array[int]:
	var winners: Array[int] = []
	for index: int in placements:
		if placements[index] == 1:
			winners.append(index)
	return winners
