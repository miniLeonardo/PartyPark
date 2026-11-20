# Partypark: Regeln für KI-Agenten

Diese Datei ist die zentrale Arbeitsanweisung für jede KI, die an diesem Projekt arbeitet (Claude, Google Antigravity/Gemini oder andere). `CLAUDE.md` verweist hierher. Antigravity liest `AGENTS.md` im Projektstamm automatisch als Regeldatei. Halte diese Datei unter 12.000 Zeichen.

## Projekt in einem Satz

Partypark ist ein lokales 3D-Partyspiel im Stil der Nintendo-Minispielsammlungen (Mario Party, Wii Party, Nintendo Land) für bis zu 4 Spieler an einem Bildschirm mit Controllern, gebaut mit Godot 4.7 für Windows und Linux (Bazzite).

## Pflichtlektüre zu Beginn jeder Sitzung

Lies in dieser Reihenfolge, bevor du Code änderst (sparsam: nur das Nötige, nicht ganze Ordner):

1. `AGENTS.md` (diese Datei, mit Projektkarte unten)
2. `docs/DEVLOG.md`: nur den obersten Eintrag (Stand und nächster Schritt)
3. `docs/ROADMAP.md`: Abschnitt der aktuellen Version
4. `docs/DECISIONS.md`: „Offene Fragen“ und die letzten Einträge
5. Bei Bedarf: `docs/GAME_DESIGN.md` (Spielinhalt), `docs/ARCHITECTURE.md` (Technik), `docs/ART_GUIDE.md` (Optik), `docs/MINIGAME_GUIDE.md` (neues Minispiel)

`docs/archiv/` enthält Abgeschlossenes (alte DEVLOG-Einträge, D01 bis D99, erledigte Phasen, alte Prompts und Testanleitungen). Nicht vorab lesen, nur gezielt durchsuchen (z. B. nach „D34“ oder „Autoscooter“), wenn du ein älteres System änderst. D01 bis D99 gelten weiter, sofern nicht ersetzt.

Fasse dem Nutzer danach in zwei bis drei Sätzen zusammen, wo das Projekt steht, und bestätige den nächsten Schritt.

## Goldene Regeln

1. **Spieldesign entscheidet Leonardo.** Bevor du etwas umsetzt, das beeinflusst, wie sich das Spiel spielt, anfühlt, aussieht oder anhört, frage nach. Biete 2 bis 4 konkrete Optionen an, markiere deine Empfehlung und begründe sie in einem Satz. Bündle mehrere Fragen, statt einzeln nachzuhaken. Bis zur Antwort darfst du an technisch unabhängigen Teilen weiterarbeiten oder einen klar gekennzeichneten Platzhalter verwenden.
2. **Rückfragen und Abstimmung:**
   - Designfragen im Chat immer als nummerierte Fragen mit Optionen A, B, C formulieren.
   - Die Empfehlung steht als erste Option mit einer einzeiligen Begründung voran.
   - Maximal 4 Fragen auf einmal bündeln, dann auf Antwort warten und die Entscheidung sofort in `docs/DECISIONS.md` eintragen.
   - Bei optischen Gestaltungsfragen immer erst 2 bis 3 gerenderte Bildvarianten derselben Ansicht vorlegen, dann fragen.
   - Vor jedem größeren Arbeitspaket einen Implementierungsplan als Artefakt zur Freigabe vorlegen.
3. **Was als Spieldesignentscheidung gilt:** Steuerung und Tastenbelegung, Bewegungsgefühl (Tempo, Sprunghöhe, Trägheit), Kameraperspektive, Regeln, Siegbedingungen und Punktevergabe eines Minispiels, Dauer von Runden, Teamzuweisung, Schwierigkeit und Verhalten der KI-Gegner, Figuren, Thema, Grafikstil, Farben, Sound und Musik, Texte und Namen, Menüabläufe, Auswahl und Reihenfolge der Minispiele.
4. **Technische Entscheidungen** (Code-Struktur, Benennung, Algorithmen, Hilfsklassen) triffst du selbst. Größere Weichenstellungen trägst du in `docs/DECISIONS.md` ein.
5. **Kontext sichern.** Eine Sitzung oder ein Meilenstein ist erst abgeschlossen, wenn `docs/DEVLOG.md` (neuer Eintrag oben), `docs/ROADMAP.md` (Status) und `docs/DECISIONS.md` (neue Entscheidungen und offene Fragen) aktualisiert sind. Schreibe so, dass eine andere KI auf einem anderen PC ohne Chatverlauf weitermachen kann.
6. **Immer lauffähig.** Das Projekt muss nach jedem Schritt fehlerfrei starten. Lieber kleine, getestete Schritte als große Umbauten.
7. **Keine neuen Abhängigkeiten ohne Rückfrage.** Addons, Plugins und fremde Assets nur nach Zustimmung. Erlaubte Lizenzen: CC0, CC-BY, MIT, vergleichbar freie. Jede fremde Datei wird in `assets/CREDITS.md` mit Quelle und Lizenz eingetragen.
8. **Doku nicht umschreiben, sondern ergänzen.** Alte Einträge in DEVLOG und DECISIONS bleiben stehen (Abgeschlossenes darf unverändert nach `docs/archiv/` wandern). Überholte Entscheidungen werden als „ersetzt durch Dxx“ markiert. DEVLOG-Einträge kurz halten (höchstens etwa 15 Zeilen).

## Technik

| Bereich | Festlegung |
|---|---|
| Engine | Godot 4.7.x (Standard-Build, kein .NET), D41 |
| Sprache | GDScript mit statischer Typisierung |
| Physik | Jolt Physics (in `project.godot` gesetzt) |
| Renderer | Forward+; bei Performanceproblemen auf Handhelds ist Mobile die Ausweichoption |
| Zielplattformen | Windows x86_64 und Linux x86_64 (Bazzite, auch Handhelds wie Steam Deck) |
| Eingabe | bis zu 4 Gamepads gleichzeitig, Tastatur nur als Debug-Eingabe |
| Bildschirm | ein gemeinsamer Bildschirm; Splitscreen nur in Ego-Minispielen über `SplitScreen` (D49) |

### Nützliche Befehle

```powershell
# Unter Windows lautet der Aufruf .\Godot_v4.7.2-stable_win64_console.exe (oder godot unter Linux)

# Projekt importieren und auf Ladefehler prüfen (ohne Fenster)
.\Godot_v4.7.2-stable_win64_console.exe --headless --path . --import

# Unit-Tests (TeamAssigner, Punkte, Registry, Fx, Sfx, Announcer)
.\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/run_tests.gd

# Alle Skripte und Szenen laden (findet Parse-Fehler, auch mit Autoloads)
.\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --smoke-compile

# Durchläufe mit simulierten Eingaben (Exit-Code 0 = grün)
.\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --smoke-m1
.\Godot_v4.7.2-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --smoke-m2
.\Godot_v4.7.2-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --smoke-games
.\Godot_v4.7.2-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --smoke-hub

# Spieltest-Statistik aller Minispiele (Dauer, Siegverteilung, untätiger Spieler; D131)
.\Godot_v4.7.2-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --smoke-playtest --runs=12

# Asset-Audit je Arena (Dreiecke, Meshes, Draw Calls, Lichter)
.\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --tool-asset_audit

# Bildschirmfotos / Stilproben rendern (1280x720, alle Stimmungen)
.\Godot_v4.7.2-stable_win64_console.exe --path . --resolution 1280x720 -- --smoke-style_probe --shots=docs/screenshots/check --moods=noon,golden,evening

# Geräusche aus tools/sfx_recipes.gd neu erzeugen, danach --import
.\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tools/sfx_gen.gd

# Neues Minispiel anlegen (Anleitung docs/MINIGAME_GUIDE.md)
.\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tools/new_minigame.gd -- --id=<id> --name="<Name>" --formats=ffa

# Messmodus (mit Fenster, Ergebnis in user://bench.txt, siehe docs/PERFORMANCE.md)
.\Godot_v4.7.2-stable_win64_console.exe --path . -- --bench
```

`--check-only` kennt keine Autoloads, daher `--smoke-compile` für Syntaxprüfungen. `--smoke-m2` spielt ein ganzes Turnier und jedes Minispiel durch; mit `--fixed-fps 60` ohne Echtzeit in Sekunden.

## Code-Konventionen

1. Offizieller GDScript-Styleguide: Dateien und Ordner `snake_case`, Klassen `PascalCase` mit `class_name`, Funktionen und Variablen `snake_case`, Konstanten `UPPER_SNAKE_CASE`.
2. Statische Typen überall (`var speed: float = 6.0`, `func get_team() -> int:`).
3. Signale im Perfekt benannt (`player_joined`, `round_finished`).
4. Spielwerte nicht im Code verstecken, sondern als `@export` oder Konstante oben in der Datei, damit Leonardo sie im Editor tunen kann.
5. Bezeichner und Code auf Englisch, Kommentare und Dokumentation auf Deutsch.
6. Eine Szene, ein Hauptskript mit gleichem Namen daneben (`player.tscn` und `player.gd`).
7. **Eingabe:** Gameplay-Code fragt niemals globale Aktionen wie `ui_accept` oder `Input.is_action_pressed()` ohne Gerätebezug ab. Jede Spielereingabe läuft über den zentralen InputRouter (siehe `docs/ARCHITECTURE.md`), der Controller-IDs festen Spielerplätzen zuordnet.
8. Neue Minispiele entstehen mit `tools/new_minigame.gd` und werden über ihre Beschreibungsdatei registriert, nicht per Hand in Menüs eingetragen. Anleitung in `docs/MINIGAME_GUIDE.md`. Effekte (`Fx`), Geräusche (`Sfx`) und Ansager (`Announcer`) gehören von Anfang an dazu.
9. Menüs und Tastenhinweise nutzen `MenuList` und `InputHints` (Tasten je Gerät, D28), nie Godots Fokus-Navigation.

## Projektkarte

Autoloads: `Log`, `Settings`, `Sfx`, `Fx`, `Announcer`, `InputRouter`, `PlayerRoster`, `MinigameRegistry`, `Game` (Szenenwechsel, Pause).

| Ordner | Wichtige Dateien |
|---|---|
| `core/input/` | `input_router` (Gerät → Spielerplatz), `input_source`, `gamepad_input`, `keyboard_input`, `ai_input` (Computer), `input_bindings` |
| `core/teams/` | `player_roster`, `player_slot`, `team_assigner`, `team_format` |
| `core/minigame/` | `minigame` (Basisklasse), `match_flow` (Ansage → Regeln → Countdown → Ergebnis), `minigame_info`/`_registry`/`_context`/`_result`, `scoring`, `minigame_sandbox` (Tests) |
| `core/look/`, `core/level/` | `look` (Stimmung, Materialien), `park_props`, `stage_kit` (Grundformen mit Kollision) |
| `core/fx/`, `core/audio/`, `core/announcer/` | Effekte, Geräusche, Ansager |
| `core/camera/` | `arena_camera`, `split_screen` (nur Ego-Spiele) |
| `player/` | `player` (Bewegung, Schubsen, Stufenhilfe, `push_velocity`), `player_visual`, `abilities/` (Springen, Schubsen) |
| `minigames/<id>/` | `<id>.gd/.tscn`, `info.tres`; Spiele: bumper_cars, tug_of_war, giant_vs_dwarfs, sheep_herding, hex_fall, hot_potato, blaster_brawl |
| `modes/` | `tournament/`, `free_play/`, `test_arena/`, `hub/` (Park: `hub`, `hub_camera` mit Leine, `hub_props` baut die Welt, `hub_minigame` startet Spiele, `tower/`, `playground/`, `stations/`, `crowd/`) |
| `ui/` | Titel, Beitritt, Hauptmenü, Optionen, Pause, `menu_list`, `input_hints` |
| `tests/` | `run_tests.gd` + `unit/`; `smoke/` (compile, m1, m2, games, hub, playtest, Bildskripte shots/style_probe) |
| `tools/` | `new_minigame`, `sfx_gen`/`sfx_recipes`, `asset_audit`, `download_assets.ps1` |
| `assets/` | `audio/` (selbst erzeugt), `third_party/` (nur genutzte Dateien), `CREDITS.md`; `_incoming/` = lokale Rohdownloads, nicht versioniert |
| `docs/` | aktuelle Doku, `stil/` (Stilvorlagen), `archiv/`; `screenshots/` lokal, nicht versioniert |

## Testen

1. Nach jeder Änderung: headless Import ohne Fehler und Warnungen im eigenen Code.
2. Logik, die sich ohne Fenster prüfen lässt (Teamzuweisung, Punkte, Turnierablauf), bekommt Tests in `tests/`.
3. Controller-Tests kann nur Leonardo am echten Rechner machen. Formuliere nach jedem Meilenstein eine kurze, nummerierte Testanleitung für ihn und trage das Ergebnis in den DEVLOG ein.
4. Für Tests mit weniger als 4 Controllern gibt es Debug-Spieler (Tastatur oder Dummy), die nur in Debug-Builds verfügbar sind.

## Arbeitsumgebungen

1. **Lokal mit Shell, Godot und Git** (Antigravity oder Claude Code unter Windows mit echter Grafikkarte): Godot liegt als `Godot_v4.7.2-stable_win64(_console).exe` im Projektordner (nicht versioniert). Änderungen lokal testen und committen.
2. **Austauschweg:** GitHub `https://github.com/miniLeonardo/PartyPark.git` (CI über `.github/workflows/tests.yml`). Vor der Arbeit `git pull`, nach dem Abschluss pushen, wenn Leonardo zustimmt.
3. Nach dem ersten Klonen oder großen Asset-Änderungen einmal `--import` ausführen; `assets/_incoming/` braucht eine `.gdignore` (liegt bei), sonst bricht der Import an `.blend`-Dateien ab.
4. Wechselt die Umgebung, wird das im DEVLOG vermerkt.

## Definition of Done für eine Aufgabe

1. Projekt startet ohne Fehler, headless Import ist sauber.
2. Neue Spielwerte sind im Editor einstellbar.
3. Offene Designfragen wurden gestellt oder sind als Platzhalter dokumentiert.
4. DEVLOG, ROADMAP und DECISIONS sind aktualisiert.
5. Git-Commit mit aussagekräftiger Nachricht auf Deutsch, zum Beispiel `M1: Controller-Beitritt und Spielerfarben`.
