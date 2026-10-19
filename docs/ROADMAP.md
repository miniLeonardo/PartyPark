# Partypark: Roadmap

Status: **offen**, **in Arbeit**, **erledigt**, **verschoben**. Beim Abschluss eines Meilensteins Datum und Kurznotiz eintragen.

## Phase 0: Einrichtung

| Nr | Aufgabe | Status | Notiz |
|---|---|---|---|
| 0.1 | Projektverzeichnis, Godot-Projekt, Git, Doku für KI-Übergabe | erledigt | 2026-10-19, Claude (Cowork) |
| 0.2 | Godot 4.6.x bei Leonardo installiert (Windows und Bazzite) | offen | |
| 0.3 | 4 Controller unter Windows und Bazzite erkannt (Godot Joypad-Demo oder Prototyp) | offen | |

## Phase 1: Prototyp, Meilenstein M1 „Kern“

| Nr | Aufgabe | Status |
|---|---|---|
| 1.1 | `InputRouter` mit `GamepadInput`, `KeyboardInput` (Debug), Verbindungsabbruch | erledigt (2026-10-19, headless und Smoke-Test grün, Controllertest offen) |
| 1.2 | `PlayerRoster`, Spielerfarben | erledigt (2026-10-19, headless und Smoke-Test grün, Controllertest offen) |
| 1.3 | Beitrittsbildschirm „Drücke A zum Mitspielen“ | erledigt (2026-10-19, headless und Smoke-Test grün, Controllertest offen) |
| 1.4 | Spielfigur: Laufen, Springen, Schubsen | erledigt (2026-10-19, headless und Smoke-Test grün, Controllertest offen) |
| 1.5 | Testarena mit `ArenaCamera` für 4 Spieler | erledigt (2026-10-19, headless und Smoke-Test grün, Controllertest offen) |
| 1.6 | Pause-Menü | erledigt (2026-10-19, headless und Smoke-Test grün, Controllertest offen) |
| 1.7 | Testanleitung für Leonardo, Test bestanden | in Arbeit (Anleitung in `docs/TESTANLEITUNG_M1.md`, Test bei Leonardo offen) |

## Phase 2: Prototyp, Meilenstein M2 „Minispiel-Framework“

| Nr | Aufgabe | Status |
|---|---|---|
| 2.1 | `TeamFormat`, `MinigameInfo`, `MinigameRegistry` | offen |
| 2.2 | `Minigame`-Basisklasse, `MinigameContext`, `MinigameResult` | offen |
| 2.3 | `MatchFlow`: Ankündigung, Regeln, Übung mit Bereit, Countdown, Ergebnis | offen |
| 2.4 | `TeamAssigner` mit Tests | offen |
| 2.5 | Schnellturnier mit Punktestand und Siegerehrung | offen |
| 2.6 | Testläufer `tests/run_tests.gd` | offen |

## Phase 3: Prototyp, Meilenstein M3 „Vertical Slice“

| Nr | Aufgabe | Status |
|---|---|---|
| 3.1 | Minispiel FFA (Vorschlag Eisscholle) | offen |
| 3.2 | Minispiel 2v2 (Vorschlag Ruderboot) | offen |
| 3.3 | Minispiel 1v3 (Vorschlag Geisterhaus) | offen |
| 3.4 | Minispiel 4vCPU (Vorschlag Staubsauger-Boss) | offen |
| 3.5 | Einfache Computergegner über `AIInput` | offen |
| 3.6 | Erster gemeinsamer Spieleabend als Test, Feedback im DEVLOG | offen |

## Phase 4: Ausbau

Weitere Minispiele, Grafikstil festziehen, Sound, Hub oder Brettspiel (je nach Q01).

## Phase 5: Juice und Politur

Bildschirmwackeln, Freeze-Frames, Partikel, Animationen, Ansager, Menü-Feinschliff.

## Phase 6: Export und Verteilung

Export-Vorlagen Windows und Linux, Test auf Bazzite als Nicht-Steam-Spiel, Performance-Check auf Handheld.
