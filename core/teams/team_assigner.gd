class_name TeamAssigner
extends RefCounted
## Reine Logik für die Auslosung von Format und Teams (D32). Ohne Szenenbaum testbar.
## Spieler werden über ihren Platzindex (0 bis 3) angesprochen.


## Ergebnis einer Teamzuweisung.
class Assignment:
	extends RefCounted
	var format: int = TeamFormat.Format.FFA
	## Liste von Teams, jedes Team ist ein Array[int] mit Platzindizes.
	var teams: Array = []
	## Platzindex des Solo-Spielers im 1 gegen 3, sonst -1.
	var solo: int = -1

	func team_of(index: int) -> int:
		for t: int in teams.size():
			if (teams[t] as Array).has(index):
				return t
		return -1


## Wählt ein Format gewichtet aus den erlaubten aus. `last_format` wird gemieden, wenn es Alternativen gibt.
static func pick_format(rng: RandomNumberGenerator, allowed: Array[int], last_format: int = -1) -> int:
	var candidates: Array[int] = allowed.duplicate()
	if candidates.size() > 1 and candidates.has(last_format):
		candidates.erase(last_format)
	if candidates.is_empty():
		return -1
	var total: float = 0.0
	for format: int in candidates:
		total += TeamFormat.WEIGHTS.get(format, 1.0)
	var roll: float = rng.randf() * total
	for format: int in candidates:
		roll -= TeamFormat.WEIGHTS.get(format, 1.0)
		if roll <= 0.0:
			return format
	return candidates[candidates.size() - 1]


## Wählt ein Minispiel-ID aus den Kandidaten, möglichst nicht das letzte.
static func pick_game(rng: RandomNumberGenerator, candidates: Array[StringName], last_game: StringName = &"") -> StringName:
	var pool: Array[StringName] = candidates.duplicate()
	if pool.size() > 1 and pool.has(last_game):
		pool.erase(last_game)
	if pool.is_empty():
		return &""
	return pool[rng.randi_range(0, pool.size() - 1)]


## Teilt die Spieler für ein Format ein.
## `scores`: Platzindex → Gesamtpunkte (für den Solo-Spieler im 1 gegen 3).
## `last_pairs`: Teams der letzten 2v2-Runde als Array von Array[int], damit sich Paare nicht wiederholen.
static func assign(rng: RandomNumberGenerator, format: int, players: Array[int], scores: Dictionary = {}, last_pairs: Array = []) -> Assignment:
	var result := Assignment.new()
	result.format = format
	var shuffled: Array[int] = players.duplicate()
	_shuffle(rng, shuffled)
	match format:
		TeamFormat.Format.COOP_VS_CPU:
			result.teams = [shuffled]
		TeamFormat.Format.FFA:
			for index: int in shuffled:
				result.teams.append([index])
		TeamFormat.Format.TWO_VS_TWO:
			result.teams = _pick_pairs(rng, players, last_pairs)
		TeamFormat.Format.ONE_VS_THREE:
			result.solo = pick_last_placed(rng, players, scores)
			var rest: Array[int] = []
			for index: int in players:
				if index != result.solo:
					rest.append(index)
			result.teams = [[result.solo], rest]
	return result


## Spieler mit den wenigsten Punkten; bei Gleichstand zufällig unter ihnen (Aufholhilfe).
static func pick_last_placed(rng: RandomNumberGenerator, players: Array[int], scores: Dictionary) -> int:
	var lowest: int = 1 << 30
	var candidates: Array[int] = []
	for index: int in players:
		var score: int = scores.get(index, 0)
		if score < lowest:
			lowest = score
			candidates = [index]
		elif score == lowest:
			candidates.append(index)
	return candidates[rng.randi_range(0, candidates.size() - 1)]


## Normalisierte Paarung (sortiert), zum Vergleichen.
static func pairing_key(teams: Array) -> String:
	var parts: PackedStringArray = []
	for team: Array in teams:
		var sorted: Array = team.duplicate()
		sorted.sort()
		parts.append(str(sorted))
	parts.sort()
	return "|".join(parts)


static func _pick_pairs(rng: RandomNumberGenerator, players: Array[int], last_pairs: Array) -> Array:
	var p: Array[int] = players.duplicate()
	p.sort()
	# Bei 4 Spielern gibt es genau 3 Paarungen.
	var options: Array = [
		[[p[0], p[1]], [p[2], p[3]]],
		[[p[0], p[2]], [p[1], p[3]]],
		[[p[0], p[3]], [p[1], p[2]]],
	]
	if not last_pairs.is_empty():
		var last_key: String = pairing_key(last_pairs)
		var filtered: Array = []
		for option: Array in options:
			if pairing_key(option) != last_key:
				filtered.append(option)
		options = filtered
	var chosen: Array = options[rng.randi_range(0, options.size() - 1)]
	if rng.randf() < 0.5:
		chosen = [chosen[1], chosen[0]]
	return chosen


static func _shuffle(rng: RandomNumberGenerator, array: Array[int]) -> void:
	for i: int in range(array.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp: int = array[i]
		array[i] = array[j]
		array[j] = tmp
