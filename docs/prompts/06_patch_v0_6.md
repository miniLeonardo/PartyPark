# Prompt 06: Patch v0.6 „Mehr Chaos“ (Antigravity)

In Antigravity verwenden, nachdem `docs/prompts/05_uebergabe_antigravity.md` vollständig abgeschlossen ist (Teil A Übergabe und Teil B Rest von v0.5, Version 0.5.0). Kann im selben Gespräch oder in einem neuen gestartet werden. Ist v0.5 noch nicht fertig, zuerst dort weitermachen.

---

Du arbeitest als Spieleentwickler an **Partypark**, einem lokalen 3D-Partyspiel für bis zu 4 Spieler an einem Bildschirm (Godot 4.7, GDScript, Jolt, Forward+, Windows und Linux/Bazzite), lokal in Antigravity mit Terminal, Godot und Git. Ich bin Leonardo, Ideengeber und Spieldesigner. `AGENTS.md` gilt vollständig: Technik entscheidest du, Spieldesign, Optik und Klang entscheide ich nach deinen Vorschlägen.

Quellen für den Stand: `docs/DEVLOG.md` (oberster Eintrag), `docs/ROADMAP.md` (Abschnitt v0.6), `docs/DECISIONS.md`, `docs/GAME_DESIGN.md` (Pool 9.6 und 9.7, Abschnitt 12), `docs/ASSET_QUELLEN.md`, `docs/ARCHITECTURE.md`, `docs/MINIGAME_GUIDE.md`, `docs/ART_GUIDE.md`, `docs/PERFORMANCE.md`, letzte Testanleitung `docs/TESTANLEITUNG_V0_5.md`.

## Ziel des Patches

Nach v0.6 hat Partypark doppelt so viele Spiele (13 oder mehr), niemand sitzt nach dem Ausscheiden untätig herum, vorhandene Spiele gibt es in weiteren Formaten, der entscheidende Moment jeder Runde wird wiederholt, und ein Turnier hat Bonustitel und ein spannendes Finale. Alle neuen Inhalte sehen aus wie der Rest des Spiels (`docs/ART_GUIDE.md`).

## Schritt 0: Gesundheitscheck

1. `git pull`, dann den Skill `partypark-tests` (bzw. alle Prüfungen aus `AGENTS.md`, inklusive `--tool-asset_audit`) ausführen. Ausgangswerte mit dem obersten DEVLOG-Eintrag vergleichen, rote Tests zuerst reparieren. `config/version` muss `0.5.0` sein, sonst ist v0.5 nicht abgeschlossen.
2. Falls noch nicht vorhanden, als reines Entwicklerwerkzeug einen Schnellstart `-- --play=<minigame_id>` (optional `--format=<FFA|TWO_VS_TWO|ONE_VS_THREE|COOP_VS_CPU>`) über die `MinigameSandbox` ergänzen, damit ich neue Spiele sofort sichtbar ausprobieren kann.

## Schritt 1: Lagebild und Umfang

1. Stand in höchstens fünf Sätzen zusammenfassen.
2. Eine Fragerunde im Chat (nummerierte Fragen, Optionen A/B/C, Empfehlung zuerst):
   1. Testergebnis v0.5 und Messwerte der Radeon 780M vorhanden? Falls ja, als Erstes einarbeiten (WP 1).
   2. Q18: Rache-Modus für Ausgeschiedene grundsätzlich gewünscht?
   3. Welche sechs Spiele aus GAME_DESIGN 9.6 und 9.7 kommen in v0.6, mindestens eins je Format? Mindestens ein Schießspiel aus 9.7 vorschlagen, das die Waffen-Szenen aus `core/weapons/` nutzt. Gern mit Vorschlag, welche mit den Assets und der Kulisse aus v0.5 am besten aussehen.
   4. Autoscooter-Steuerung nach dem Controllertest (D51): bleibt, Auto-Gas oder Panzersteuerung?
3. Antworten in `docs/DECISIONS.md` eintragen.

## Schritt 2: Arbeitspakete

Vor jedem Paket einen Implementierungsplan als Artefakt anlegen und auf meine Freigabe warten. Jedes Paket endet lauffähig mit grünen Tests und einem eigenen Commit (`v0.6 WP<n>: …`). Gepusht wird an den Haltepunkten nach meiner Freigabe; danach müssen die GitHub Actions grün sein.

| WP | ROADMAP | Inhalt | Designfragen an mich |
|---|---|---|---|
| 1 | 5.x Rest | Testergebnis v0.5 einarbeiten, Messwerte in `docs/PERFORMANCE.md`, Leistungsprobleme beheben | konkrete Werte |
| 2 | 6.1 | Rache-Modus: Ausgeschiedene schweben als Geister am Rand und stören (z. B. Bananenschale, Windstoß); Baustein in `core/`, in alle Spiele mit Ausscheiden | Störungen, Abklingzeiten, Stärke, Aussehen der Geister |
| 3 | 6.2 | Formatvarianten: Autoscooter 2v2, Tauziehen als Vier-Seil-Stern FFA, Schafe hüten 2v2 als Wettstreit | Regeln je Variante |
| 4 | 6.3 | Sechs neue Minispiele, je mit Konzeptrunde, über den Skill `partypark-minigame` | Ziel, Steuerung, Dauer, Sieg, Besonderheit, Arenathema |
| 5 | 6.4 | Wiederholung des entscheidenden Moments | Länge, Auslöser, überspringbar |
| 6 | 6.5 | Rundenstatistik und Bonustitel am Turnierende | Titel, Bonuspunkte ja/nein |
| 7 | 6.6 | Finale: letzte Runde doppelte Punkte, bei Gleichstand Duell 1 gegen 1 | Duell-Spiel, Ablauf |
| 8 | | Aufräumen, Doku, Bauanleitung um neue Erfahrungen ergänzen | keine |

**Haltepunkte:** Nach WP 2 und nach WP 4 stoppen, das Spiel für mich starten (Schnellstart), mir eine kurze Testanleitung geben und auf Feedback warten. Sage ich „ohne Feedback weiter“, nur Tests grün halten und weitermachen (D66).

### Technische Leitlinien

**WP 2 Rache-Modus**
1. Wiederverwendbarer Baustein (z. B. `core/ghosts/ghost_controller.gd`), den ein Minispiel mit einer Zeile aktiviert; Geister nutzen die `InputSource` des ausgeschiedenen Spielers.
2. Störungen als kleine Szenen mit Abklingzeit, Wirkung über `receive_push` oder eine eigene Schnittstelle; Computer-Geister über `AIProfile`.
3. Effekte (`Fx`), Geräusche (`Sfx`, neue Rezepte in `tools/sfx_recipes.gd`) und Ansager-Sprüche (neues Ereignis in `announcer_lines.json`) von Anfang an. Geister-Optik nach ART_GUIDE.

**WP 3 Formatvarianten**
1. `info.tres` um Formate erweitern; Varianten im selben Skript über `context.format` und `context.teams`.
2. `--smoke-games` spielt jedes Format jedes Spiels.

**WP 4 Neue Minispiele**
1. Pro Spiel: Konzeptrunde, Gerüst mit `tools/new_minigame.gd`, Arena als `.tscn` nach ART_GUIDE (Optik getrennt von Kollision, Park-Kulisse wiederverwenden), Effekte, Geräusche, Computergegner, `debug_summary()` und `was_close()`, Simulation der Rundendauer über mehrere Läufe, Messmodus und `--tool-asset_audit`. Die Arena muss in allen drei Stimmungen gut aussehen (D86); Bilder aller drei zeigen.
2. Alle Spielwerte als `@export`. Ego-Spiele nur über `SplitScreen` (D76).
3. Neue fremde Assets nur nach meiner Zustimmung, Quelle und Lizenz in `assets/CREDITS.md` (siehe `docs/ASSET_QUELLEN.md`, Pakete mit Direktlink lädt `tools/download_assets.ps1`, bei Bedarf mit `-Nur <name>`). Du darfst selbst herunterladen, wenn ich zustimme. Schießspiele aus GAME_DESIGN 9.7 nutzen die gemeinsamen Waffen-Szenen in `core/weapons/`.
4. Nach jedem Spiel ein Bildschirmfoto der Arena zeigen.

**WP 5 Wiederholung**
1. Ringpuffer der Figurenzustände (Position, Drehung, Sichtbarkeit, Ausdruck) der letzten 3 bis 5 Sekunden, kein Videopuffer.
2. Abspielen mit eigener Kamera, `Engine.time_scale` nur innerhalb von `MatchFlow` (D42); Minispiele melden den Moment über eine Methode (z. B. `highlight_time()`).

**WP 6 und 7 Turnier**
1. Statistik-Zähler im Minispiel-Rahmen (`Minigame`), Auswertung in `modes/tournament/`.
2. Punkte und Finale über `Scoring`, mit Unit-Tests.

## Qualitätsregeln

1. `AGENTS.md` gilt vollständig, ebenso `docs/ART_GUIDE.md` für alles Sichtbare.
2. Tastenhinweise über `InputHints` (D28), Menüs über `MenuList` (D26).
3. Effekte, Sounds und Ansager laufen mit pausiertem Baum und Zeitlupe korrekt.
4. Neue Autoloads und Klassen in `docs/ARCHITECTURE.md`; technische Abweichungen in DECISIONS als KI-Entscheidung mit Modellname und „Antigravity“.
5. Nach jeder größeren Änderung alle Prüfungen; Logs auf `ERROR`, `WARNING`, Lecks prüfen. Neue Funktionen bekommen Smoke- oder Unit-Tests.
6. Leistungsbudget aus dem ART_GUIDE einhalten; neue Spiele im Messmodus.
7. Keine Dateien löschen, nichts installieren, kein `git push --force` ohne meine Zustimmung.

## Abschluss des Patches

1. `docs/TESTANLEITUNG_V0_6.md` (nummeriert, Rückmeldung als „Nummer: ok/Problem“).
2. DEVLOG-Eintrag, ROADMAP v0.6 auf erledigt, DECISIONS, `config/version` in `project.godot` auf `0.6.0`.
3. Commit, nach Freigabe Push, Actions grün.
4. Den nächsten Prompt `docs/prompts/07_patch_v0_7.md` nach diesem Muster für ROADMAP v0.7 „Der Park“ schreiben; vorher Q01 mit mir klären.

## Kontext sichern, wenn das Gespräch lang wird

Lauffähigen Stand herstellen, DEVLOG, ROADMAP und DECISIONS so aktualisieren, dass ein neues Gespräch ohne diesen Verlauf weitermacht, Fortsetzungsprompt `docs/prompts/06b_patch_v0_6_fortsetzung.md` schreiben, committen und mir sagen, dass ich neu starten soll.

## Kommunikation

Deutsch, knapp und präzise. Keine Aufzählungen mit Spiegelstrichen; nummerierte Listen und Tabellen sind in Ordnung. Fortschritt über die Aufgabenliste bzw. Antigravity-Artefakte.

Beginne jetzt mit Schritt 0.
