# Partypark: Roadmap-Archiv (abgeschlossene Phasen)

Unverändert aus `docs/ROADMAP.md` verschoben (2026-11-20).

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
| 1.7 | Testanleitung für Leonardo, Test bestanden | erledigt (2026-10-19, Leonardo: „klappt alles“, Windows, Godot 4.7, vor allem Tastatur) |

## Phase 2: Prototyp, Meilenstein M2 „Minispiel-Framework“

| Nr | Aufgabe | Status |
|---|---|---|
| 2.1 | `TeamFormat`, `MinigameInfo`, `MinigameRegistry` | erledigt (2026-10-19) |
| 2.2 | `Minigame`-Basisklasse, `MinigameContext`, `MinigameResult` | erledigt (2026-10-19) |
| 2.3 | `MatchFlow`: Ankündigung, Regeln mit Bereit (ohne Übung, D33), Countdown, Zeitlupe, Ergebnis | erledigt (2026-10-19) |
| 2.4 | `TeamAssigner` mit Tests | erledigt (2026-10-19) |
| 2.5 | Schnellturnier mit Punktestand und Siegerehrung | erledigt (2026-10-19) |
| 2.6 | Testläufer `tests/run_tests.gd` | erledigt (2026-10-19) |

## Phase 3: Prototyp, Meilenstein M3 „Vertical Slice“

| Nr | Aufgabe | Status |
|---|---|---|
| 3.1 | Minispiel FFA: Autoscooter `bumper_cars` (D30, D34) | erledigt (2026-10-19, Smoke-Test grün, Controllertest offen) |
| 3.2 | Minispiel 2v2: Tauziehen `tug_of_war` (D35) | erledigt (2026-10-19, Smoke-Test grün, Controllertest offen) |
| 3.3 | Minispiel 1v3: Riese gegen Zwerge `giant_vs_dwarfs` (D36) | erledigt (2026-10-19, Smoke-Test grün, Controllertest offen) |
| 3.4 | Minispiel 4vCPU: Schafe hüten `sheep_herding` (D37) | erledigt (2026-10-19, Smoke-Test grün, Controllertest offen) |
| 3.5 | Einfache Computergegner über `AIInput`, Stärke einstellbar (D38, D45) | erledigt (2026-10-19) |
| 3.6 | Erster gemeinsamer Spieleabend als Test, Feedback im DEVLOG | teilweise (2026-10-20 kurz angespielt, Q22; voller Test mit Controllern offen) |

## Zwischenschritt: Menüs (2026-10-19 vorgezogen)

| Nr | Aufgabe | Status |
|---|---|---|
| M.1 | Titelbildschirm, Hauptmenü, Optionen (D29, D39) | erledigt (2026-10-19) |
| M.2 | Freies Spiel mit Teamwahl (D40) | erledigt (2026-10-19) |


### v0.4 „Spieleabend“ (umgesetzt 2026-10-20, Prompt `docs/prompts/03_patch_v0_4.md`, Versionsplan bestätigt D47; Tests bei Leonardo offen)

Ziel: Das Spiel fühlt sich an einem echten Abend wie ein fertiges Partyspiel an.

| Nr | Aufgabe | Inspiration | Status |
|---|---|---|---|
| 4.1 | Spieleabend-Feedback (ROADMAP 3.6) einarbeiten, Balance Q15, Teampunkte Q13, Teamfarben Q14 | | erledigt (2026-10-20: Seile sichtbar D52, Tauziehen mit Kraftakt D53, Computer-Zwerge D58, Q13/Q14 bleiben; Autoscooter wartet auf Controllertest D51) |
| 4.2 | Effekt-Baukasten `core/fx/`: Kamera-Wackeln über Trauma-Wert, Hitstop, Partikel-Vorlagen (Staub, Platscher, Konfetti, Sterne), Squash-Impulse an der Figur; in alle vorhandenen Minispiele einbauen | „The Art of Screenshake“, Nintendo-Feedback | erledigt (2026-10-20, D55, D56, D63; Hörtest/Sichttest bei Leonardo offen) |
| 4.3 | Sound-Grundgerüst: Busse Musik/Effekte/Stimme, Autoload `Sfx` mit Stimmen-Pool und Tonhöhen-Streuung, Lautstärke in den Optionen; Effekt-Generator `tools/sfx_gen.gd` nach dem sfxr-Prinzip erzeugt eigene `.wav` (keine Lizenzfrage) | sfxr/jsfxr | erledigt (2026-10-20, D59 bis D62, D65; 42 Geräusche, Hörtest bei Leonardo offen) |
| 4.4 | Ansager mit „Brabbelstimme“: Sprechblasen mit silbenweisem Geplapper für Ankündigung, Countdown, Sieg, Pech; Spruchlisten pro Ereignis | Animal Crossing, Wii-Party-Moderator | erledigt (2026-10-20, D67, D68: trockener Kommentator „Hodenhüpfer“, 8 Ereignisse, Spruchliste `core/announcer/announcer_lines.json`) |
| 4.5 | Leistung: FPS- und Frametime-Anzeige (Debug), Grafikoption Niedrig/Mittel/Hoch (Schatten, MSAA, 3D-Auflösung mit FSR), Messprotokoll je Minispiel in `docs/PERFORMANCE.md` | | erledigt (2026-10-20, D69: Grafikstufen, Leistungsanzeige F3/Option, Messmodus `-- --bench`; Messung auf Radeon 780M offen) |
| 4.6 | Zwei neue Minispiele aus der Schnellbau-Liste (GAME_DESIGN 9.5) | Bomberman, Fall Guys | erledigt (2026-10-20: Wackelwaben D70/D73, Heiße Kartoffel D71, zusätzlich Zerfetzung mit Splitscreen D72/D49) |
| 4.7 | Bauanleitung `docs/MINIGAME_GUIDE.md` und Gerüst-Skript `tools/new_minigame.gd` (legt Ordner, info.tres, Skript, Szene, Registry-Test an) | | erledigt (2026-10-20: `docs/MINIGAME_GUIDE.md`, `tools/new_minigame.gd` mit Test) |
| 4.8 | Aufräumen: leere `.gitkeep`, Hinweise zum Klassen-Cache; Q09 klären, bei Zustimmung GitHub-Repository und automatische Tests per GitHub Actions | | erledigt (2026-10-20: Q09 → GitHub privat mit Actions D74, Vorlage `tools/ci/tests.yml` D79; .gitkeep-Liste für Leonardo im DEVLOG) |
| 4.9 | Export-Vorlagen Windows und Linux (`export_presets.cfg`), erster Test auf Bazzite | | teilweise (2026-10-20: `export_presets.cfg` Windows und Linux, in der Cloud exportiert und gestartet; Test auf Bazzite offen, Anleitung `docs/EXPORT_UND_BAZZITE.md`) |

