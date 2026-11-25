class_name Handicap
extends RefCounted
## Handicap je Spieler (P3, D135): Stufe Profi, Normal oder Entspannt, gewählt im Beitrittsbildschirm.
## Die Stufe wirkt still über einen Faktorsatz, den Spielerfigur und Minispiele freiwillig lesen.
## Normal ändert nichts. Werte sind Platzhalter zum Tunen (Bestätigung durch Leonardo offen).
##
## Unterstützt (Stand 2026-11-25): Lauftempo aller Figuren (auch Ego-Spiele), Schubs-Wucht, die eine Figur
## abbekommt (alle Spiele), Trefferfenster im Tauziehen.

enum Level { PRO, NORMAL, RELAXED }

const NAMES: Array[String] = ["Profi", "Normal", "Entspannt"]

## Lauftempo (Faktor auf move_speed).
const SPEED: Array[float] = [0.95, 1.0, 1.1]
## Wucht erhaltener Schubser (kleiner = standfester).
const PUSH_TAKEN: Array[float] = [1.15, 1.0, 0.7]
## Zeitfenster bei Reaktions- und Taktspielen (größer = großzügiger).
const TIMING_WINDOW: Array[float] = [0.8, 1.0, 1.5]
## Treffer- und Fangradius (für Spiele, die ihn unterstützen).
const HIT_RADIUS: Array[float] = [0.9, 1.0, 1.25]


static func name_of(level: int) -> String:
	return NAMES[clampi(level, 0, NAMES.size() - 1)]


static func speed(level: int) -> float:
	return SPEED[clampi(level, 0, SPEED.size() - 1)]


static func push_taken(level: int) -> float:
	return PUSH_TAKEN[clampi(level, 0, PUSH_TAKEN.size() - 1)]


static func timing_window(level: int) -> float:
	return TIMING_WINDOW[clampi(level, 0, TIMING_WINDOW.size() - 1)]


static func hit_radius(level: int) -> float:
	return HIT_RADIUS[clampi(level, 0, HIT_RADIUS.size() - 1)]


## Nächste Stufe beim Blättern (step = -1 oder +1), ohne Überlauf.
static func step(level: int, direction: int) -> int:
	return clampi(level + direction, Level.PRO, Level.RELAXED)
