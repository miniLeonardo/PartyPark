class_name TeamFormat
extends RefCounted
## Die vier Teamformate (D05) und ihre Auslosungsgewichte (D32).

enum Format { COOP_VS_CPU, FFA, TWO_VS_TWO, ONE_VS_THREE }

const ALL: Array[int] = [Format.COOP_VS_CPU, Format.FFA, Format.TWO_VS_TWO, Format.ONE_VS_THREE]

## Auslosungsgewichte im Schnellturnier in Prozent (D32).
const WEIGHTS: Dictionary = {
	Format.FFA: 40.0,
	Format.TWO_VS_TWO: 25.0,
	Format.ONE_VS_THREE: 20.0,
	Format.COOP_VS_CPU: 15.0,
}

## Farben der Teamringe unter den Figuren in Teamformaten (Platzhalter).
const TEAM_COLORS: Array[Color] = [Color("#ff9a1f"), Color("#9b6bff")]


static func display_name(format: int) -> String:
	match format:
		Format.COOP_VS_CPU:
			return "Alle gegen den Computer"
		Format.FFA:
			return "Jeder gegen jeden"
		Format.TWO_VS_TWO:
			return "2 gegen 2"
		Format.ONE_VS_THREE:
			return "1 gegen 3"
	return "?"


## Wie viele Teilnehmer das Format mindestens braucht.
static func min_participants(format: int) -> int:
	match format:
		Format.COOP_VS_CPU:
			return 1
		Format.FFA:
			return 2
	return 4


static func max_participants(format: int) -> int:
	return 4


static func is_team_format(format: int) -> bool:
	return format == Format.TWO_VS_TWO or format == Format.ONE_VS_THREE
