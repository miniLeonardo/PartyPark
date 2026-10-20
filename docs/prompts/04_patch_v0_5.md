# Prompt 04: Patch v0.5 „Mehr Chaos“

Du bist Spieleentwickler an **Partypark**, einem lokalen 3D-Partyspiel für bis zu 4 Spieler an einem Bildschirm (Godot 4.7, GDScript, Jolt, Forward+, Windows und Linux/Bazzite). Ich bin Leonardo, Ideengeber und Spieldesigner. Du schreibst Code und triffst technische Entscheidungen; jede Entscheidung, die beeinflusst, wie sich das Spiel spielt, anfühlt, aussieht oder anhört, triffst du **nicht** selbst, sondern fragst mich.

Frühere Chats sind für dich unsichtbar. Alles steht im Projektordner `C:\Users\wad32muj\Agentenraum\partypark` (oder im privaten GitHub-Repository, D74): `AGENTS.md`, `CLAUDE.md`, `docs/DEVLOG.md`, `docs/ROADMAP.md` (Abschnitt v0.5), `docs/DECISIONS.md` (D01 bis D79, offene Fragen), `docs/GAME_DESIGN.md` (Pool 9.6, Abschnitt 12), `docs/ARCHITECTURE.md`, `docs/MINIGAME_GUIDE.md`, `docs/PERFORMANCE.md`, `docs/TESTANLEITUNG_V0_4.md`.

## Ziel des Patches

Nach v0.5 hat Partypark doppelt so viele Spiele (13), niemand sitzt nach dem Ausscheiden untätig herum, vorhandene Spiele gibt es in weiteren Formaten, und der entscheidende Moment jeder Runde wird wiederholt. Ein Turnier hat ein spannendes Finale und Bonustitel.

## Schritt 0: Einrichten und Gesundheitscheck

1. `CLAUDE.md` lesen und die passende Arbeitsweise (Variante A oder B) befolgen, inklusive Klassen-Cache `.godot/global_script_class_cache.cfg`. Ist der Ordner nicht verbunden, mir sofort Bescheid geben.
2. Godot 4.7.2 bereitstellen und den Ausgangszustand prüfen: `--import`, `--script res://tests/run_tests.gd`, `-- --smoke-compile`, `-- --smoke-m1`, `--fixed-fps 60 -- --smoke-m2`, `--fixed-fps 60 -- --smoke-games`. Ergebnisse als Ausgangswert notieren (Stand v0.4: Unit 31, compile 117 Dateien, m1 50/50, m2 39/39, games 12/12). Rote Tests zuerst reparieren.

## Schritt 1: Lagebild und Umfang festlegen

1. Pflichtlektüre aus `AGENTS.md` lesen und mir den Stand in höchstens fünf Sätzen zusammenfassen.
2. In **einer** Fragerunde mit `AskUserQuestion` klären:
   1. Testergebnis v0.4 (`docs/TESTANLEITUNG_V0_4.md`, Nummern 1 bis 30, Bazzite B1 bis B9, Messwerte `bench.txt`)? Falls ja, schicken lassen und als Erstes einarbeiten (WP 1).
   2. Q18: Rache-Modus für Ausgeschiedene grundsätzlich gewünscht?
   3. Welche sechs Spiele aus GAME_DESIGN 9.6 kommen in v0.5 (mindestens eins je Format)? Mehrfachauswahl, ggf. in zwei Fragen aufteilen.
   4. Autoscooter-Steuerung nach dem Controllertest (D51): bleibt, Auto-Gas oder Panzersteuerung?
3. Antworten sofort in `docs/DECISIONS.md` eintragen.

## Schritt 2: Arbeitspakete

Reihenfolge einhalten. Jedes Paket endet lauffähig mit grünen Tests. Vor jedem Paket mit Designanteil eine kurze Fragerunde (2 bis 4 Fragen, konkrete Optionen mit Zahlen, Empfehlung zuerst).

| WP | ROADMAP | Inhalt | Designfragen an mich |
|---|---|---|---|
| 1 | 4.x Rest | Testergebnis v0.4 einarbeiten: Q15 Balance, Q23 Ansager-Optik, Q24 Zerfetzung, Autoscooter (D51), Messwerte in `docs/PERFORMANCE.md`, Leistungsprobleme beheben | konkrete Zahlenwerte |
| 2 | 5.1 | Rache-Modus: Ausgeschiedene schweben als Geister am Rand und stören (Bananenschale, Windstoß); Baustein in `core/`, in alle Spiele mit Ausscheiden | Störungen, Abklingzeiten, Stärke |
| 3 | 5.2 | Formatvarianten: Autoscooter 2v2, Tauziehen als Vier-Seil-Stern FFA, Schafe hüten 2v2 als Wettstreit | Regeln je Variante |
| 4 | 5.3 | Sechs neue Minispiele, je mit Konzeptrunde, nach `docs/MINIGAME_GUIDE.md` und mit `tools/new_minigame.gd` | Ziel, Steuerung, Dauer, Sieg, Besonderheit |
| 5 | 5.4 | Wiederholung des entscheidenden Moments: Ringpuffer der letzten Sekunden, andere Kameraperspektive, Zeitlupe | Länge, Auslöser, überspringbar |
| 6 | 5.5 | Rundenstatistik und Bonustitel am Turnierende | Titel, Bonuspunkte ja/nein |
| 7 | 5.6 | Finale: letzte Runde doppelte Punkte, bei Gleichstand Duell 1 gegen 1 | Duell-Spiel, Ablauf |
| 8 | | Aufräumen, Doku, Bauanleitung um neue Erfahrungen ergänzen | keine |

**Haltepunkte:** Nach WP 2 und nach WP 4 stoppen, alles zurückschreiben, mir eine kurze Testanleitung geben und auf mein Feedback warten. Sage ich „ohne Feedback weiter“, nur Tests grün halten und weitermachen (D66).

### Technische Leitlinien je Paket

**WP 2 Rache-Modus**
1. Wiederverwendbarer Baustein (z. B. `core/ghosts/ghost_controller.gd`), den ein Minispiel mit einer Zeile aktiviert; Geister nutzen dieselbe `InputSource` des ausgeschiedenen Spielers.
2. Störungen als kleine Szenen mit Abklingzeit, wirken über `receive_push` oder eigene Schnittstelle; Computer-Geister über `AIProfile`.
3. Effekte (`Fx`), Geräusche (`Sfx`) und Ansager-Sprüche (neues Ereignis in `announcer_lines.json`) von Anfang an.

**WP 3 Formatvarianten**
1. `info.tres` um Formate erweitern; Varianten im selben Skript über `context.format` und `context.teams`.
2. Smoke-Test deckt alle Formate ab (`--smoke-games` spielt jedes Format).

**WP 4 Neue Minispiele**
1. Pro Spiel: Konzeptrunde, Gerüst mit `tools/new_minigame.gd`, Umsetzung mit Effekten, Sounds und Computergegnern, `debug_summary()` und `was_close()`, Simulation der Rundendauer (mehrere Läufe), Eintrag im Messmodus automatisch.
2. Alle Spielwerte als `@export`; neue Geräusche als Rezepte in `tools/sfx_recipes.gd`.
3. Ego-Spiele nur über `SplitScreen` (D76).

**WP 5 Wiederholung**
1. Ringpuffer der Figurenzustände (Position, Drehung, Sichtbarkeit) der letzten 3 bis 5 Sekunden, kein Videopuffer.
2. Abspielen mit eigener Kamera und `Engine.time_scale` nur innerhalb von `MatchFlow` (D42); Minispiele melden den Moment über eine Methode (z. B. `highlight_time()`).

**WP 6 und 7 Turnier**
1. Statistik-Zähler im Minispiel-Rahmen (`Minigame`), Auswertung in `modes/tournament/`.
2. Punkte und Finale über `Scoring` mit Unit-Tests.

## Qualitätsregeln

1. `AGENTS.md` gilt vollständig.
2. Tastenhinweise immer über `InputHints` (D28), Menüs über `MenuList` (D26).
3. Effekte, Sounds und Ansager laufen mit pausiertem Baum und Zeitlupe korrekt (unskalierte Zeit wo nötig).
4. Neue Autoloads und Klassen in `docs/ARCHITECTURE.md` dokumentieren; Abweichungen in DECISIONS als KI-Entscheidung.
5. Nach jeder größeren Änderung: Import, Unit-Tests, `--smoke-compile`, `--smoke-m2`, `--smoke-games`; Logs auf `ERROR`, `WARNING`, Lecks prüfen. Neue Funktionen bekommen Smoke- oder Unit-Tests.
6. Was nur auf meinem Rechner prüfbar ist (Klang, Vibration, Bildrate, Controller, Bazzite), klar benennen.
7. Nach dem Push auf GitHub müssen die Actions grün sein (D74).

## Abschluss des Patches

1. `docs/TESTANLEITUNG_V0_5.md` (nummeriert, Rückmeldung als „Nummer: ok/Problem“).
2. DEVLOG-Eintrag, Status in ROADMAP v0.5, neue Entscheidungen in DECISIONS, `config/version` in `project.godot` auf `0.5.0`.
3. Alles laut `CLAUDE.md` zurückschreiben, inklusive Klassen-Cache, und mir eine deutsche Commit-Nachricht vorschlagen.
4. Den nächsten Prompt als `docs/prompts/05_patch_v0_6.md` nach dem Muster dieses Prompts für ROADMAP v0.6 „Der Park“ schreiben (vorher Q01 klären).

## Kontext sichern, wenn der Chat lang wird

Lauffähigen Stand herstellen, DEVLOG, ROADMAP und DECISIONS so aktualisieren, dass ein neuer Chat ohne diesen Verlauf weitermacht, einen Fortsetzungsprompt `docs/prompts/04b_patch_v0_5_fortsetzung.md` schreiben, alles zurückschreiben und mir sagen, dass ich einen neuen Chat starten soll.

## Kommunikation

Deutsch, knapp und präzise. Keine Aufzählungen mit Spiegelstrichen; nummerierte Listen und Tabellen sind in Ordnung. Fortschritt über die Aufgabenliste.

Beginne jetzt mit Schritt 0.
