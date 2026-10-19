# Partypark: Technische Architektur

Stand: 2026-10-19, nach Umsetzung von M1, M2, M3 und den Menüs. Alle Abschnitte außer 9 (Export) beschreiben den umgesetzten Stand. Wer davon abweicht, aktualisiert dieses Dokument und trägt die Abweichung in `docs/DECISIONS.md` ein.

## 1. Überblick

```
ui/title_screen/title_screen.tscn (Hauptszene)
  └─ ui/join_screen/join_screen.tscn (Beitritt)
       └─ ui/main_menu/main_menu.tscn (Hauptmenü, D29)
            ├─ modes/tournament/tournament.tscn (Schnellturnier)
            ├─ modes/free_play/free_play.tscn (Freies Spiel)
            ├─ modes/test_arena/test_arena.tscn (Testarena)
            └─ ui/options_menu/options_menu.tscn (Optionen)
  Turnier und Freies Spiel erzeugen je Runde einen MatchFlow:
            └─ MatchFlow: Ankündigung → Regeln (Bereit) → Countdown → Minispiel → Zeitlupe → Ergebnis
                 └─ minigames/<id>/<id>.tscn
```

Spielweite Zustände liegen in wenigen Autoloads (Singletons). Minispiele kennen keine Menüs und keine anderen Minispiele, sie bekommen einen Kontext und melden ein Ergebnis zurück.

## 2. Autoloads

| Name | Datei | Aufgabe |
|---|---|---|
| `Settings` | `core/settings.gd` | Optionen (Computer-Stärke, Vibration, Vollbild, Turnierlänge), gespeichert in `user://settings.cfg` |
| `InputRouter` | `core/input/input_router.gd` | Controller erkennen, Geräte festen Spielerplätzen zuordnen, Eingaben pro Spieler bereitstellen, Verbindungsabbrüche melden |
| `PlayerRoster` | `core/teams/player_roster.gd` | Die bis zu 4 Spielerplätze: Gerät, Farbe, Name, Computergegner ja/nein, Gesamtpunkte |
| `MinigameRegistry` | `core/minigame/minigame_registry.gd` | findet beim Start alle `minigames/*/info.tres` und filtert nach Teamformat und Spielerzahl |
| `Game` | `core/game.gd` | Szenenwechsel (`goto_title`, `goto_join`, `goto_main_menu`, `goto_options`, `start_tournament`, `start_free_play`, `start_test_arena`), Pause-Menü, Verbindungs-Pause mit Übernahme, Smoke-Tests (`--smoke-<name>` lädt `tests/smoke/<name>_smoke.gd`) |

Reihenfolge in `project.godot`: Settings, InputRouter, PlayerRoster, MinigameRegistry, Game. `Game.match_running` ist während Turnier, Freiem Spiel und Testarena an (dann gibt es Pause und Verbindungs-Pause), in Menüs aus. Beim Start einer Spielart füllt `Game` Computergegner auf (falls im Beitritt eingeschaltet) und entfernt sie bei der Rückkehr ins Menü wieder. Alle drei laufen mit `PROCESS_MODE_ALWAYS`, damit Eingabe und Menüs auch bei pausiertem Baum funktionieren. Der InputRouter fragt mit `process_physics_priority = -1000` vor allen anderen Knoten ab.

## 3. Eingabe: das wichtigste technische Thema

Godots Standard-Aktionen (`Input.is_action_pressed`) unterscheiden nicht, von welchem Controller eine Eingabe kommt. Für 4 Spieler braucht es daher eine eigene Schicht.

### 3.1 Abstraktion `InputSource`

Jeder Spielerplatz hat genau eine Eingabequelle mit derselben Schnittstelle:

```gdscript
class_name InputSource extends RefCounted

func get_move() -> Vector2            # linker Stick oder Steuerkreuz, mit Deadzone
func is_down(action: StringName) -> bool
func just_pressed(action: StringName) -> bool
func just_released(action: StringName) -> bool
func rumble(weak: float, strong: float, duration: float) -> void
```

Umsetzungen:

| Klasse | Zweck |
|---|---|
| `GamepadInput` | echter Controller über `Input.get_joy_axis(device, …)` und `Input.is_joy_button_pressed(device, …)` |
| `KeyboardInput` | Debug-Spieler auf der Tastatur, nur in Debug-Builds |
| `AIInput` | Computergegner; die KI „drückt“ dieselben virtuellen Tasten wie ein Mensch |

Vorteil: Spielfigur und Minispiele unterscheiden nie zwischen Mensch, Tastatur und Computer. Computergegner und Testspieler sind damit fast kostenlos.

### 3.2 Abstrakte Aktionen

Gameplay-Code verwendet nur diese Namen. Die Zuordnung zu echten Tasten liegt zentral in `InputRouter` und ist Spieldesign (Belegung muss Leonardo bestätigen).

| Aktion | Zweck |
|---|---|
| `move` | Bewegung (Vektor) |
| `jump` | Springen |
| `action` | kontextabhängige Hauptaktion |
| `push` | Schubsen / Angriff |
| `special` | Sonderfähigkeit im Minispiel |
| `confirm`, `back` | Menüs |
| `pause` | Pause-Menü |

`just_pressed` wird vom Router selbst berechnet: Er fragt in `_physics_process` alle Geräte ab und vergleicht mit dem vorigen Frame. Zusätzlich merkt sich jede Quelle Tastendrücke aus `_input`-Ereignissen bis zur nächsten Abfrage, damit kurze Drücke bei niedriger Bildrate nicht verloren gehen (D24).

Umgesetzt:

| Datei | Inhalt |
|---|---|
| `core/input/input_bindings.gd` | `InputBindings`: Aktionsnamen und die komplette Tastenbelegung für Gamepad (D18) und beide Tastatur-Debugspieler (D22). Hier und nur hier Tasten ändern. |
| `core/input/input_source.gd` | Basisklasse mit `poll`, `get_move`, `is_down`, `just_pressed`, `just_released`, `rumble`, `latch_event`, `reset`; leitet `nav_up/down/left/right` für Menüs aus dem Stick ab (D26) |
| `core/input/gamepad_input.gd` | radiale Deadzone 0,2 mit Neuskalierung, Steuerkreuz hat Vorrang vor dem Stick |
| `core/input/keyboard_input.gd` | physische Tasten, nur in Debug-Builds registriert |
| `core/input/ai_input.gd` | Gerüst: KI setzt `move` und `pressed` |
| `core/input/input_router.gd` | Quellenliste, Abfrage, `poll_join_requests()` mit Doppelgänger-Schutz (D23), `debug_connect_gamepad`/`debug_disconnect_gamepad` für Tests |

### 3.3 Beitritt und Verbindungsabbruch

1. Im Beitrittsbildschirm drückt jeder auf seinem Controller die Bestätigungstaste und belegt den nächsten freien Platz.
2. Die Zuordnung Gerät zu Platz bleibt für die ganze Sitzung fest.
3. `Input.joy_connection_changed` wird beobachtet. Fällt ein Controller weg, pausiert das Spiel mit dem Hinweis „Controller von Spieler 2 getrennt“. Ein neu verbundener Controller kann den freien Platz per Tastendruck übernehmen.
4. Umsetzung: `PlayerRoster` markiert den Platz als `disconnected`. Im Beitrittsbildschirm verlässt der Spieler einfach den Platz, während eines Spiels pausiert `Game` und zeigt `ui/disconnect_overlay`. Steckt derselbe Controller (gleiche Geräte-ID und GUID) wieder an, übernimmt er automatisch; sonst übernimmt jede freie Quelle mit A.
5. Doppelgänger-Schutz (D23): Ein freies Gamepad darf nicht beitreten, wenn innerhalb von 150 ms ein belegtes oder gerade beigetretenes Gamepad A gedrückt hat. So belegt ein Controller, der über Steam Input doppelt erscheint, nur einen Platz.

### 3.4 Hinweise zu Plattformen

1. Godot liest Gamepads seit 4.5 über SDL3; Tasten werden nach Position benannt (`JOY_BUTTON_A` ist immer die untere Taste). Für Tastensymbole im UI den Controllertyp über `Input.get_joy_name(device)` erkennen.
2. Unter Bazzite das Spiel als Nicht-Steam-Spiel hinzufügen. Steam Input stellt Controller dann meist als virtuelle Xbox-Pads bereit; Geräte-IDs können sich dabei von denen unter Windows unterscheiden. Deshalb nie IDs fest im Code verwenden.
3. Vibration über `Input.start_joy_vibration(device, weak, strong, duration)`.

## 4. Minispiel-Framework

### 4.1 Beschreibungsdatei `MinigameInfo` (Resource)

Jedes Minispiel liegt in `minigames/<id>/` und hat eine `info.tres` vom Typ `MinigameInfo`:

| Feld | Typ | Beispiel |
|---|---|---|
| `id` | StringName | `ice_floe` |
| `display_name` | String | „Eisscholle“ |
| `formats` | Array[int] (Enum `TeamFormat`) | `[FFA]` |
| `min_players`, `max_players` | int | 2, 4 |
| `duration_sec` | float | 60 |
| `goal_text` | String | „Stoß alle anderen ins Wasser!“ |
| `controls` | Dictionary Aktion → Text | `{ "push": "Schubsen" }` |
| `scene` | PackedScene | `ice_floe.tscn` |
| `preview` | Texture2D | optional |

`TeamFormat` ist ein Enum in `core/teams/team_format.gd`: `COOP_VS_CPU`, `FFA`, `TWO_VS_TWO`, `ONE_VS_THREE`.

### 4.2 Basisklasse `Minigame`

```gdscript
class_name Minigame extends Node3D

signal finished(result: MinigameResult)

var context: MinigameContext   # Spieler, Teams, Format, Solo-Spieler, Practice-Modus

func setup(ctx: MinigameContext) -> void   # Arena aufbauen, Figuren platzieren
func start_practice() -> void              # Übungsrunde, zählt nicht
func start_round() -> void                 # echtes Spiel nach dem Countdown
func end_round() -> void                   # Gewinner ermitteln, finished senden
```

`MinigameResult` enthält eine Platzierung pro Spieler (1 bis 4) und optional Bonuspunkte. Die Spielart rechnet daraus Punkte.

### 4.3 `MatchFlow`

Eine Szene in `core/minigame/match_flow.tscn`, die genau einen Durchlauf steuert: Ankündigung, Regelbildschirm, Übung mit Bereit-Anzeige pro Spieler, Countdown, Spiel, Zeitlupe, Ergebnis. Jede Spielart (Turnier, Hub, Brett) nutzt denselben `MatchFlow`.

### 4.4 Umsetzung (M2/M3)

| Datei | Inhalt |
|---|---|
| `core/teams/team_format.gd` | Enum `TeamFormat.Format` (COOP_VS_CPU=0, FFA=1, TWO_VS_TWO=2, ONE_VS_THREE=3), Gewichte (D32), Teamfarben, Mindestspielerzahl |
| `core/minigame/minigame_info.gd` | Felder wie oben, plus `solo_goal_text`, `solo_controls`, `solo_role_name`, `team_role_name`; die Szene steht als Pfad in `scene_path` |
| `core/minigame/minigame_catalog.gd` | statisch: `scan()` findet `minigames/*/info.tres`, `filter()`, `available_formats()` |
| `core/minigame/minigame_registry.gd` | Autoload, hält die gefundenen Infos |
| `core/minigame/minigame_context.gd` | Teilnehmer, Format, Teams (Platzindizes), Solo-Spieler, Computer-Stärke; Teamfarbe und Teamname |
| `core/minigame/minigame_result.gd` | Platz pro Platzindex; `from_ranking`, `team_win`, `draw`, `coop` |
| `core/minigame/scoring.gd` | Punkte (D31, Q13) und Rangliste |
| `core/minigame/minigame.gd` | Basisklasse: `setup()` baut Arena (`_build_arena`) und Figuren (`_spawn_position`, `_configure_player`), `start_round()`, `_round_process()`, `_update_ai()` für Computer, `finish(result)`, Zeitlimit `time_limit`, HUD `hud` (`ui/minigame_hud.gd`) |
| `core/minigame/match_flow.gd` | Ablauf nach D33, Skriptklasse ohne Szene; `start(info, context, round_label, award_points)`, Signal `completed(result, points)` |
| `core/ai/ai_profile.gd` | Kennwerte der Computer je Stärke (D45) |

**Neues Minispiel anlegen:** Ordner `minigames/<id>/` mit `info.tres` (Typ `MinigameInfo`, `scene_path` auf die Szene), `<id>.tscn` (Wurzel `Node3D` mit Skript) und `<id>.gd` (`extends Minigame`). Im Skript mindestens `_build_arena()` (Boden, Kamera), `_round_process()` mit Siegbedingung und `finish(...)`, `_update_ai()` für Computer überschreiben. Die Registry findet das Spiel automatisch; `tests/unit/test_registry.gd` um die neue ID ergänzen.

### 4.5 Die vier Minispiele

| ID | Format | Kern |
|---|---|---|
| `bumper_cars` | FFA | `ScooterAbility` ersetzt das Laufen (`Player.drive_override`), runde Kollision, Rempler über Aufprallgeschwindigkeit, 3 Leben, Bande mit 4 Lücken |
| `tug_of_war` | 2v2 | Takt mit `BeatRing`, Treffer ±0,13 s, Synchronbonus, Fehldruck sperrt kurz, Figuren werden entlang des Seils positioniert |
| `giant_vs_dwarfs` | 1v3 | Riese per `Player.set_body_scale(3)`, Stampfen mit Ausholzeit und Schockwelle, Seilzählung über aufsummierten Winkel um den Riesen |
| `sheep_herding` | Koop | `Sheep` (Flucht, Herde, Trödeln), `Wolf` (Gruppe `pushable`, flieht nach Schubser), Bellen über die Schubs-Taste |

## 5. Teams und Spielarten

1. `TeamAssigner` (`core/teams/team_assigner.gd`): reine Logik, bekommt Format, Spielerliste, Punktestand und Historie, liefert Teams und ggf. Solo-Spieler. Gut testbar.
2. Spielarten liegen in `modes/<name>/`. Das Schnellturnier wählt Format, Teams und ein passendes Minispiel, startet `MatchFlow`, sammelt Punkte und zeigt am Ende die Siegerehrung.
3. Umsetzung: `modes/tournament/tournament.gd` (Runden, Zwischenstand, `history` der gespielten Runden), `modes/tournament/tournament_ceremony.gd` (Podest, Konfetti), `modes/free_play/free_play.gd` (Liste, Teamwahl nach D40).
4. Menüs: `ui/menu_list.gd` (Liste mit Werten ◀ ▶, Navigation über InputSource), `ui/menu_backdrop.gd` (3D-Hintergrund mit hüpfenden Figuren), `ui/input_hints.gd` (Tastenhinweise je Gerät, D28).

## 6. Spielfigur

1. `player/player.tscn` mit `CharacterBody3D` als Basis (gut kontrollierbar), Wackel- und Squash-Effekte rein visuell über Animation bzw. prozedurale Bewegung des Modells. Rückstoß beim Schubsen als eigene Geschwindigkeitskomponente.
2. Fähigkeiten als Kind-Nodes (`JumpAbility`, `PushAbility`, `CarryAbility`, …), die ein Minispiel an- oder abschaltet.
3. Die Figur liest ausschließlich ihr `InputSource`.
4. Spielerfarbe wird über ein Material-Override gesetzt.
5. Ergänzt in M2/M3: `controls_enabled` (aus während Regeln und Countdown), `drive_override`/`drive_velocity` für eigene Bewegungsmodelle, `add_ability()`, `set_body_scale()`, `set_collision_shape()`, `set_team_ring()`, `set_active()`, `stun()`, `world_to_input()` (für Computer), `PlayerAbility.post_move_update()`. `PushAbility` trifft auch Knoten der Gruppe `pushable` und beachtet `friendly_fire`/`team_check`.
6. Umgesetzt in M1: `player/player.gd` (`Player`) trennt Laufgeschwindigkeit `_walk` und Rückstoß `_knockback`, Schwerkraft beim Fallen stärker, Bewegung kamerarelativ. Fähigkeiten erben von `player/abilities/player_ability.gd` und werden in Kind-Reihenfolge nach der Schwerkraft und vor `move_and_slide()` aufgerufen: `JumpAbility` (variable Höhe, Coyote-Zeit, Sprungpuffer), `PushAbility` (Trefferkegel, Rückstoß, Betäubung, Ausfallschritt). `player/player_visual.gd` (`PlayerVisual`) erzeugt Stauchen, Strecken, Nachwippen, Vorlehnen und Fußbewegung per Federn. `Player.movement_enabled` schaltet nur das Laufen ab (Beitrittsbildschirm). Die Figur hängt in der Gruppe `players`. Wichtige Methoden: `setup(slot)`, `respawn(pos)`, `face(dir)`, `receive_push(...)`, `add_knockback(...)`.
7. Figur aus Grundformen (Kapsel, Kugelaugen, Kugelfüße) nach D15; echte Modelle erst nach D17/Q09.

## 7. Kamera

`core/camera/arena_camera.gd`: feste oder mitschwenkende Kamera, die alle aktiven Spieler im Bild hält (Mittelpunkt und Zoom aus der Bounding Box der Spieler, geglättet). Minispiele können eine feste Kamera stattdessen verwenden.

Umgesetzt: feste Neigung (`pitch_deg`) und Drehung (`yaw_deg`), Abstand aus Ausdehnung und Sichtfeld zwischen `min_distance` und `max_distance`, fallende Figuren unterhalb `ignore_below_height` zählen nicht mit.

## 7a. Hilfsbausteine (M1)

| Datei | Inhalt |
|---|---|
| `core/teams/player_slot.gd` | `PlayerSlot`: Index, Farbe, Name, Quelle, `is_cpu`, `disconnected`, `total_score` |
| `core/level/stage_kit.gd` | `StageKit`: Himmel, Licht, Quader und Zylinder mit Kollision für Platzhalter-Level |
| `ui/ui_style.gd` | `UiStyle`: Labels und Panels der Platzhalter-Oberfläche |
| `ui/join_screen/` | Beitrittsbildschirm (D20) |
| `ui/pause_menu/` | `PauseMenu` (D21), eigene Navigation |
| `ui/disconnect_overlay/` | `DisconnectOverlay` |
| `modes/test_arena/` | Testarena; bei Start per F6 treten alle Quellen automatisch bei |
| `tests/smoke/m1_smoke.gd` | automatischer M1-Durchlauf (D27); mit `--shots=<ordner>` und Renderer zusätzlich Bildschirmfotos |

## 8. Tests

Unit-Tests (TeamAssigner, Punkte, Registry) und Smoke-Tests (Spiel startet normal, das Skript simuliert Eingaben und beendet mit Exit-Code 0 oder 1):

```
godot --headless --path . --script res://tests/run_tests.gd
godot --headless --path . -- --smoke-m1
godot --headless --path . --fixed-fps 60 -- --smoke-m2
godot --headless --path . -- --smoke-compile
```

`--smoke-m2` spielt Titel, Beitritt, Hauptmenü, ein komplettes Schnellturnier, jedes Minispiel im Freien Spiel und die Optionen durch. `--fixed-fps 60` schaltet die Echtzeit ab, dann dauert das Ganze nur Sekunden. Mit Renderer und `--shots=<ordner>` (und `--short` für 20-s-Runden) entstehen Bildschirmfotos.

Hinweis: `--check-only --script` kennt keine Autoloads und meldet für Skripte, die `InputRouter`, `PlayerRoster` oder `Game` verwenden, fälschlich „Identifier not found“. Für diese Skripte gilt der Smoke-Test als Prüfung.


`tests/run_tests.gd` (erweitert `SceneTree`) lädt alle `tests/test_*.gd`, führt Funktionen mit Präfix `test_` aus und beendet sich mit Exit-Code 0 oder 1. Aufruf siehe `AGENTS.md`. Bevorzugt getestet wird reine Logik: Teamzuweisung, Punktevergabe, Turnierablauf, Registry-Filter.

## 9. Export

Export-Vorlagen für „Windows Desktop“ und „Linux“ werden in Phase 6 angelegt (`export_presets.cfg`). Ausgabe nach `builds/`, nicht versioniert.
