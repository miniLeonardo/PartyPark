class_name MinigameContext
extends RefCounted
## Alles, was ein Minispiel über die Runde wissen muss: Teilnehmer, Format, Teams, Solo-Spieler, KI-Stärke.

var format: int = TeamFormat.Format.FFA
## Teilnehmende Plätze (Menschen und Computer), aufsteigend nach Index.
var slots: Array[PlayerSlot] = []
## Teams als Array von Array[int] (Platzindizes).
var teams: Array = []
## Platzindex des Solo-Spielers im 1 gegen 3, sonst -1.
var solo: int = -1
## Computer-Stärke 0 leicht, 1 mittel, 2 schwer (D38).
var difficulty: int = 1


static func from_assignment(assignment: TeamAssigner.Assignment, p_slots: Array[PlayerSlot], p_difficulty: int) -> MinigameContext:
	var ctx := MinigameContext.new()
	ctx.format = assignment.format
	ctx.slots = p_slots
	ctx.teams = assignment.teams
	ctx.solo = assignment.solo
	ctx.difficulty = p_difficulty
	return ctx


func get_slot(index: int) -> PlayerSlot:
	for slot: PlayerSlot in slots:
		if slot.index == index:
			return slot
	return null


func indices() -> Array[int]:
	var result: Array[int] = []
	for slot: PlayerSlot in slots:
		result.append(slot.index)
	return result


func team_of(index: int) -> int:
	for t: int in teams.size():
		if (teams[t] as Array).has(index):
			return t
	return -1


func is_solo(index: int) -> bool:
	return solo == index


func team_members(team: int) -> Array[int]:
	var result: Array[int] = []
	if team >= 0 and team < teams.size():
		for index: int in teams[team]:
			result.append(index)
	return result


func are_teammates(a: int, b: int) -> bool:
	if format == TeamFormat.Format.FFA:
		return false
	return team_of(a) == team_of(b)


## Farbe eines Teams: in Teamformaten die Teamfarbe, sonst die Spielerfarbe des einzigen Mitglieds.
func team_color(team: int) -> Color:
	if TeamFormat.is_team_format(format):
		if format == TeamFormat.Format.ONE_VS_THREE:
			return TeamFormat.TEAM_COLORS[0] if team_members(team).has(solo) else TeamFormat.TEAM_COLORS[1]
		return TeamFormat.TEAM_COLORS[clampi(team, 0, 1)]
	var members: Array[int] = team_members(team)
	if members.size() == 1 and get_slot(members[0]) != null:
		return get_slot(members[0]).color
	return Color.WHITE


func team_name(team: int, info: MinigameInfo = null) -> String:
	match format:
		TeamFormat.Format.TWO_VS_TWO:
			return "Team Orange" if team == 0 else "Team Lila"
		TeamFormat.Format.ONE_VS_THREE:
			var is_solo_team: bool = team_members(team).has(solo)
			if info != null:
				var role: String = info.solo_role_name if is_solo_team else info.team_role_name
				if not role.is_empty():
					return role
			return "Solo" if is_solo_team else "Team"
		TeamFormat.Format.COOP_VS_CPU:
			return "Alle"
	var members: Array[int] = team_members(team)
	return get_slot(members[0]).display_name if members.size() == 1 else "?"
