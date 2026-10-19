# Partypark: Technische Architektur

Stand: 2026-10-19. Dies ist der **Zielentwurf** vor dem ersten Prototyp. Wer davon abweicht, aktualisiert dieses Dokument und trägt die Abweichung in `docs/DECISIONS.md` ein.

## 1. Überblick

```
main.tscn (Einstieg)
  └─ Titel und Beitritt (ui/join_screen)
       └─ Spielart wählen (z. B. modes/tournament)
            └─ MatchFlow: Ankündigung → Regeln → Übung → Countdown → Minispiel → Ergebnis
                 └─ minigames/<id>/<id>.tscn
```

Spielweite Zustände liegen in wenigen Autoloads (Singletons). Minispiele kennen keine Menüs und keine anderen Minispiele, sie bekommen einen Kontext und melden ein Ergebnis zurück.

## 2. Autoloads

| Name | Datei | Aufgabe |
|---|---|---|
| `InputRouter` | `core/input/input_router.gd` | Controller erkennen, Geräte festen Spielerplätzen zuordnen, Eingaben pro Spieler bereitstellen, Verbindungsabbrüche melden |
| `PlayerRoster` | `core/teams/player_roster.gd` | Die bis zu 4 Spielerplätze: Gerät, Farbe, Name, Computergegner ja/nein, Gesamtpunkte |
| `MinigameRegistry` | `core/minigame/minigame_registry.gd` | findet beim Start alle `minigames/*/info.tres` und filtert nach Teamformat und Spielerzahl |
| `Game` | `core/game.gd` | Szenenwechsel, Pause, globale Einstellungen, Debug-Schalter |

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

`just_pressed` wird vom Router selbst berechnet: Er fragt in `_physics_process` alle Geräte ab und vergleicht mit dem vorigen Frame.

### 3.3 Beitritt und Verbindungsabbruch

1. Im Beitrittsbildschirm drückt jeder auf seinem Controller die Bestätigungstaste und belegt den nächsten freien Platz.
2. Die Zuordnung Gerät zu Platz bleibt für die ganze Sitzung fest.
3. `Input.joy_connection_changed` wird beobachtet. Fällt ein Controller weg, pausiert das Spiel mit dem Hinweis „Controller von Spieler 2 getrennt“. Ein neu verbundener Controller kann den freien Platz per Tastendruck übernehmen.

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

## 5. Teams und Spielarten

1. `TeamAssigner` (`core/teams/team_assigner.gd`): reine Logik, bekommt Format, Spielerliste, Punktestand und Historie, liefert Teams und ggf. Solo-Spieler. Gut testbar.
2. Spielarten liegen in `modes/<name>/`. Das Schnellturnier wählt Format, Teams und ein passendes Minispiel, startet `MatchFlow`, sammelt Punkte und zeigt am Ende die Siegerehrung.

## 6. Spielfigur

1. `player/player.tscn` mit `CharacterBody3D` als Basis (gut kontrollierbar), Wackel- und Squash-Effekte rein visuell über Animation bzw. prozedurale Bewegung des Modells. Rückstoß beim Schubsen als eigene Geschwindigkeitskomponente.
2. Fähigkeiten als Kind-Nodes (`JumpAbility`, `PushAbility`, `CarryAbility`, …), die ein Minispiel an- oder abschaltet.
3. Die Figur liest ausschließlich ihr `InputSource`.
4. Spielerfarbe wird über ein Material-Override gesetzt.

## 7. Kamera

`core/camera/arena_camera.gd`: feste oder mitschwenkende Kamera, die alle aktiven Spieler im Bild hält (Mittelpunkt und Zoom aus der Bounding Box der Spieler, geglättet). Minispiele können eine feste Kamera stattdessen verwenden.

## 8. Tests

`tests/run_tests.gd` (erweitert `SceneTree`) lädt alle `tests/test_*.gd`, führt Funktionen mit Präfix `test_` aus und beendet sich mit Exit-Code 0 oder 1. Aufruf siehe `AGENTS.md`. Bevorzugt getestet wird reine Logik: Teamzuweisung, Punktevergabe, Turnierablauf, Registry-Filter.

## 9. Export

Export-Vorlagen für „Windows Desktop“ und „Linux“ werden in Phase 6 angelegt (`export_presets.cfg`). Ausgabe nach `builds/`, nicht versioniert.
