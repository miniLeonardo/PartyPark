# Bauanleitung für Minispiele

Stand v0.4 (2026-10-20), geschrieben aus den Erfahrungen mit Wackelwaben, Heiße Kartoffel und Zerfetzung. Ziel: ein neues Minispiel pro Sitzung. Technische Hintergründe stehen in `docs/ARCHITECTURE.md`, Regeln für KIs in `AGENTS.md`.

## 1. Ablauf in einer Sitzung

1. **Konzeptrunde mit Leonardo** (AGENTS Regel 1): Ziel, Steuerung, Dauer, Sieg, Besonderheit; 2 bis 4 Optionen mit Zahlen, Empfehlung zuerst. Antworten sofort als Dxx in `docs/DECISIONS.md`.
2. **Gerüst anlegen:**
   `godot --headless --path . --script res://tools/new_minigame.gd -- --id=<snake_case> --name="<Anzeigename>" --formats=ffa`
   Formate: `coop`, `ffa`, `2v2`, `1v3` (mehrere mit Komma). Das Skript legt `minigames/<id>/` mit `info.tres`, `<id>.tscn`, `<id>.gd` an und trägt die ID in `tests/unit/test_registry.gd` ein.
3. `godot --headless --path . --import`, dann sofort `--smoke-games --game=<id>`: Das leere Gerüst ist lauffähig.
4. Regeln, Arena, Effekte, Sounds und Computergegner einbauen (Abschnitte 3 bis 7).
5. Simulieren und abstimmen (Abschnitt 8), Doku nachziehen (Abschnitt 9).

## 2. Aufbau eines Minispiels

| Datei | Inhalt |
|---|---|
| `info.tres` | `MinigameInfo`: `id`, `display_name`, `formats`, Spielerzahl, `duration_sec`, `goal_text` (ein Satz für den Regelbildschirm), `controls` (Aktion → Text; Schlüssel `move`, `aim`, `jump`, `push`, `action`, `special`), bei 1 gegen 3 zusätzlich `solo_goal_text`, `solo_controls`, `solo_role_name`, `team_role_name` |
| `<id>.tscn` | Wurzel `Node3D` mit dem Skript, sonst leer; alles Weitere baut das Skript |
| `<id>.gd` | `extends Minigame`; alle Spielwerte als `@export` in Gruppen |

Die Registry findet das Spiel automatisch, Menüs und Turnier brauchen keine Änderung.

## 3. Lebenszyklus

| Methode | Wann | Typischer Inhalt |
|---|---|---|
| `_init()` | beim Laden | `time_limit` setzen |
| `_build_arena()` | in `setup()`, vor den Figuren | `super._build_arena()` (Himmel, Licht), Boden und Wände mit `StageKit`, Kamera (`ArenaCamera` oder feste `Camera3D`, `current = true`) |
| `_spawn_position(i, slot)`, `_spawn_facing(i, slot)` | je Figur | Startpunkte |
| `_configure_player(player, slot)` | je Figur, nach `add_child` | Fähigkeiten an/aus (`jump_ability`, `push_ability`), eigene `PlayerAbility` per `add_ability()`, Größe (`set_body_scale`), Signale verbinden |
| `_after_setup()` | nach allen Figuren | HUD-Startwerte, Objekte, die alle Figuren kennen müssen |
| `_on_round_started()` | nach dem Countdown | Zeitgeber starten |
| `_round_process(delta)` | jeden Physik-Frame während der Runde | Regeln, Siegbedingung, `finish(result)` |
| `_update_ai(player, ai, delta)` | je Computerfigur, vor `_round_process` | Computergegner (Abschnitt 6) |
| `_on_time_up()` | Zeit abgelaufen | Rangliste und `finish()` |

Ergebnis: `MinigameResult.from_ranking([[sieger], [zweiter], …])` (Gruppen teilen sich den Platz), `team_win(gewinner, verlierer)`, `draw(alle)`, `coop(alle, gewonnen)`. `finish()` darf mehrfach gerufen werden, zählt aber nur einmal.

Optionale Methoden, die der Rahmen nutzt:

1. `was_close() -> bool`: Der Ansager kommentiert dann „knapp“ statt „Sieg“.
2. `debug_summary() -> String`: wird von `--smoke-games` ausgegeben (z. B. „Explosionen 3, Weitergaben 12“), wichtig zum Abstimmen.

## 4. Figuren und Eingabe

1. Nie `Input.is_action_*` verwenden; Eingaben kommen über `player.get_input()` (null während Regeln und Countdown) mit `get_move()`, `get_aim()`, `just_pressed()`, `is_down()`.
2. Bewegung relativ zur Kamera übernimmt die Figur. Eigene Bewegungsmodelle setzen `player.drive_override = true` und schreiben `player.drive_velocity` in einer `PlayerAbility` (Beispiele: `ScooterAbility`, `ShooterAbility`).
3. Ausscheiden: `player.set_active(false)` (unsichtbar, ohne Physik, raus aus der Gruppe `players`).
4. Schubser auswerten: `player.push_ability.pushed.connect(...)` (Heiße Kartoffel), Treffer abfangen über `receive_push`.
5. Tastenhinweise nur über `InputHints`/`get_action_label`; `controls` in `info.tres` erscheinen automatisch je Gerät im Regelbildschirm.

## 5. Effekte und Sound (von Anfang an einbauen)

| Moment | Aufruf |
|---|---|
| Rausfallen, Ausscheiden (stark) | `Fx.shake(Fx.SHAKE_STRONG)`, `Sfx.play(&"eliminated", pos)`, `Announcer.say(&"bad_luck", {"player": name}, 0.6)` |
| Großer Treffer (mittel) | `Fx.shake(Fx.SHAKE_MEDIUM)` |
| Rempler, Treffer | `Fx.hitstop([a, b])`, `Fx.burst(&"stars", pos)` |
| Normale Schubser | nur Partikel und Squash (passiert in `Player.receive_push` automatisch) |
| Partikel | `Fx.burst(&"dust" / &"dust_ring" / &"splash" / &"confetti" / &"stars" / &"mud" / &"chunks", pos, farbe, größe)` |
| Figur stauchen | `Fx.squash(player, 0.8)` |
| Geräusch | `Sfx.play(&"name", pos)`; neues Geräusch als Rezept in `tools/sfx_recipes.gd`, dann `tools/sfx_gen.gd -- --only=name` und `--import` |

Stärken nach D55/D56: Wackeln nur bei großen Momenten. Partikel-Obergrenze 700 gilt automatisch. Konfetti über den Siegern und die Fanfare macht `MatchFlow`.

## 6. Computergegner

1. Gleiche Schnittstelle wie Menschen: `ai.move` (Stick), `ai.aim` (zweiter Stick), `ai.tap(aktion)`, `ai.hold(aktion, true)`.
2. Hilfen: `ai_steer_to(player, ai, ziel, tempo)`, `player.world_to_input(richtung)`.
3. Stärke nur über `AIProfile`: `reaction_time()` (Denkpause), `aim_error()` (Ungenauigkeit), `skill()` (Wahrscheinlichkeit, das Richtige zu tun), `timing_sigma()`, `speed()`.
4. Zustand je Figur in einem Dictionary nach Platzindex, Denkintervall statt jeden Frame neu entscheiden.
5. Wahrscheinlichkeiten pro Frame klein halten (z. B. `skill * 0.02`), sonst „spammen“ Computer.

## 7. Fallstricke (aus v0.4)

1. **Welche Fläche betritt die Figur?** Kollisionen mit Nachbarflächen an Fugen täuschen; bei stehender Figur liefert `move_and_slide` oft keine Kollision. Fläche aus der Position berechnen (Wackelwaben, `_tile_under`).
2. **Rundendauer immer simulieren:** Computer gegen Computer laufen anders als geplant (Wackelwaben 9 s statt 60 s bei 37 Waben, D73).
3. **Ego-Spiele:** `SplitScreen` benutzen. Die eigene Figur per Render-Ebene ausblenden (`SplitScreen.set_render_layer`, `hide_layer_in_view`). Während des Splitscreens rendert die Hauptansicht kein 3D; `Sfx` spielt dann ohne Panorama.
4. **Zeitlupe:** Am Rundenende läuft `Engine.time_scale` langsamer. Eigene Echtzeit-Effekte mit `delta / Engine.time_scale` rechnen, Hitstop nur lokal über `Fx.hitstop`.
5. **Variablennamen wie `position`** überdecken Node-Eigenschaften und erzeugen Warnungen.
6. **Neue `class_name`-Klassen:** Nach dem Zurückschreiben auch `.godot/global_script_class_cache.cfg` mitliefern (CLAUDE.md).
7. **Kein `await` in `_round_process`**, Abläufe über Zeitwerte oder Tweens.

## 8. Testen und Abstimmen

1. `godot --headless --path . --fixed-fps 60 -- --smoke-games --game=<id>` mehrfach laufen lassen; Dauer und `debug_summary` prüfen.
2. Alle Tests: Unit, `--smoke-compile`, `--smoke-m1`, `--smoke-m2` (spielt jedes Spiel im Freien Spiel), `--smoke-games`.
3. Bildschirmfoto mit Renderer: `xvfb-run … --rendering-driver vulkan … -- --smoke-games --game=<id> --short --shots=<ordner>`.
4. Leistung: Messmodus `-- --bench` (Abschnitt in `docs/PERFORMANCE.md`).

## 9. Doku zum Abschluss

1. `docs/DECISIONS.md`: Dxx der Konzeptrunde, KI-Entscheidungen.
2. `docs/ARCHITECTURE.md` Abschnitt 4.5: Zeile für das neue Spiel.
3. `docs/GAME_DESIGN.md`: Idee aus dem Pool als „gebaut“ markieren.
4. `docs/DEVLOG.md`, `docs/ROADMAP.md`, Testanleitung.
