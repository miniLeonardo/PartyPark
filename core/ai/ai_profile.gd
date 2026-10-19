class_name AIProfile
extends RefCounted
## Kennwerte der Computergegner je Stärke (0 leicht, 1 mittel, 2 schwer, D38).
## Minispiele lesen hier, statt eigene Zahlen zu verstecken.

## Wie lange ein Computer braucht, um auf etwas zu reagieren (Sekunden).
const REACTION_TIME: Array[float] = [0.55, 0.3, 0.14]
## Zielungenauigkeit beim Ansteuern (Meter).
const AIM_ERROR: Array[float] = [1.6, 0.8, 0.3]
## Wahrscheinlichkeit, eine sinnvolle Aktion auch wirklich auszuführen.
const SKILL: Array[float] = [0.5, 0.72, 0.9]
## Streuung des Timings bei Takt-Spielen (Sekunden).
const TIMING_SIGMA: Array[float] = [0.12, 0.075, 0.04]
## Tempo-Faktor der Stickauslenkung.
const SPEED: Array[float] = [0.75, 0.9, 1.0]


static func reaction_time(difficulty: int) -> float:
	return REACTION_TIME[clampi(difficulty, 0, 2)]


static func aim_error(difficulty: int) -> float:
	return AIM_ERROR[clampi(difficulty, 0, 2)]


static func skill(difficulty: int) -> float:
	return SKILL[clampi(difficulty, 0, 2)]


static func timing_sigma(difficulty: int) -> float:
	return TIMING_SIGMA[clampi(difficulty, 0, 2)]


static func speed(difficulty: int) -> float:
	return SPEED[clampi(difficulty, 0, 2)]
