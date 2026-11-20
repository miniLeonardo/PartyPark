# Prompt 06: Patch v0.6 „Mehr Chaos“ (Antigravity)

In Antigravity verwenden, sobald Patch v0.5 „Neuer Look“ vollständig abgeschlossen ist (Version 0.5.0 in `project.godot`, alle 7 Themen-Arenen, Waffen in `core/weapons/`, Nachher-Galerie). Kann im selben Gespräch oder in einem neuen gestartet werden.

---

Du entwickelst **Partypark**, ein lokales 3D-Partyspiel für bis zu 4 Spieler an einem Bildschirm (Godot 4.7, GDScript, Jolt, Forward+, Windows und Linux/Bazzite), lokal in Antigravity mit PowerShell-Terminal, Godot und Git. Ich bin Leonardo, Ideengeber und Spieldesigner.
`AGENTS.md` gilt vollständig: **Spieldesign, Regeln, Optik und Klang entscheide ich nach deinen Vorschlägen.** Technische Entscheidungen triffst du selbst.

Quellen für den Stand: `docs/DEVLOG.md` (oberster Eintrag), `docs/ROADMAP.md` (Abschnitt v0.6), `docs/DECISIONS.md`, `docs/GAME_DESIGN.md` (Pool 9.6 und 9.7, Abschnitt 12), `docs/ASSET_QUELLEN.md`, `docs/ARCHITECTURE.md`, `docs/MINIGAME_GUIDE.md`, `docs/ART_GUIDE.md`, `docs/PERFORMANCE.md`, `docs/TESTANLEITUNG_V0_5.md`.

## Ziel des Patches

Nach v0.6 hat Partypark doppelt so viele Spiele (13 oder mehr), niemand sitzt nach dem Ausscheiden untätig herum (Rache-Modus), vorhandene Spiele gibt es in weiteren Formaten, der entscheidende Moment jeder Runde wird als Zeitlupen-Wiederholung gezeigt, und ein Turnier hat Bonustitel und ein spannendes Finale. Alle neuen Inhalte folgen dem Freizeitpark-Look aus `docs/ART_GUIDE.md`.

## Schritt 0: Gesundheitscheck & Vorbereitung

1. **Tests ausführen:** Nutze den Skill `partypark-tests` (oder die Befehle aus `AGENTS.md`):
   ```powershell
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/run_tests.gd
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --smoke-compile
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --smoke-m1
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --smoke-m2
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --smoke-games
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --tool-asset_audit
   ```
   Ausgangswerte mit dem DEVLOG vergleichen. Rote Tests zuerst reparieren.
2. **Entwickler-Schnellstart einrichten:**
   Ergänze in `core/game.gd` bzw. der `MinigameSandbox` das Argument `--play=<id>` (optional `--format=<format>`), damit einzelne Minispiele ohne Menü-Umweg direkt auf dem Desktop sichtbar gestartet und getestet werden können.

## Schritt 1: Lagebild und Umfang

1. Stand in höchstens fünf Sätzen zusammenfassen.
2. In einer Fragerunde im Chat (nummerierte Fragen, Optionen A/B/C, Empfehlung mit Begründung voran, max. 4 Fragen):
   1. **Testergebnis v0.5 & Messwerte:** Feedback aus `TESTANLEITUNG_V0_5.md` und Messwerte der Radeon 780M vorhanden? (WP 1)
   2. **Q18 Rache-Modus:** Sollen Ausgeschiedene als schwebende Geister kleine Störungen werfen (z. B. Bananenschale, Windstoß)?
   3. **Auswahl der 6 neuen Spiele:** Welche 6 Spiele aus `GAME_DESIGN.md` (Abschnitte 9.6 und 9.7) kommen in v0.6? Mindestens ein Schießspiel aus 9.7 vorschlagen, das die Blaster-Waffen aus `core/weapons/` wiederverwendet.
   4. **D51 Autoscooter-Steuerung:** Nach Controller-Test: Aktuelle Steuerung beibehalten, Auto-Gas oder Panzersteuerung?
3. Antworten sofort in `docs/DECISIONS.md` eintragen.

## Schritt 2: Arbeitspakete

Vor jedem größeren Paket einen Implementierungsplan als Artefakt vorlegen. Commits auf Deutsch (`v0.6 WP<n>: …`).

| WP | ROADMAP | Inhalt | Designfragen an Leonardo |
|---|---|---|---|
| 1 | 5.x Rest | Feedback und Messwerte aus v0.5 einarbeiten | konkrete Werte |
| 2 | 6.1 | Rache-Modus (`core/ghosts/`): Ausgeschiedene stören als Geister am Rand | Störungen, Abklingzeiten, Geister-Optik |
| 3 | 6.2 | Formatvarianten: Autoscooter 2v2, Tauziehen Vier-Seil-Stern, Schafe hüten 2v2 | Regeln je Variante |
| 4 | 6.3 | Sechs neue Minispiele (nach `docs/MINIGAME_GUIDE.md` mit `partypark-minigame`) | Konzeptrunde je Spiel, Themenwahl |
| 5 | 6.4 | Wiederholung des entscheidenden Moments (Ringpuffer der letzten Sekunden) | Auslöser, Kameraperspektive |
| 6 | 6.5 | Rundenstatistik und Bonustitel am Turnierende | Titel-Auswahl, Bonuspunkte |
| 7 | 6.6 | Finale: letzte Runde doppelte Punkte, bei Gleichstand 1v1-Duell | Duell-Spiel, Ablauf |
| 8 | 6.x | Aufräumen, Doku, Testanleitung v0.6 | keine |

**Haltepunkte:**
- Nach WP 2 (Rache-Modus spielbar): Kurze Testanleitung, Feedback abholen.
- Nach WP 4 (alle 6 neuen Spiele gebaut): Galerie mit dem Skill `partypark-screenshots` zeigen, Schnellstart zum Anspielen anbieten.

## Qualitätsregeln

1. `AGENTS.md` und `docs/ART_GUIDE.md` gelten vollständig.
2. Tastenhinweise über `InputHints` (D28), Menüs über `MenuList` (D26).
3. Effekte (`Fx`), Geräusche (`Sfx`) und Ansager (`Announcer`) gehören von Anfang an zu jedem neuen Spiel.
4. Jedes neue Spiel muss in allen drei Stimmungen (`noon`, `golden`, `evening`) sauber aussehen.
5. Draw Calls je Arena unter 400 (Splitscreen unter 250), Dreiecke unter 300.000.
6. Bei optischen Fragen immer 2 bis 3 gerenderte Bildvarianten vorlegen.
7. Keine Dateien löschen oder herunterladen und nie `git push --force` ohne ausdrückliche Freigabe.

## Abschluss des Patches

1. `docs/TESTANLEITUNG_V0_6.md` schreiben.
2. DEVLOG, ROADMAP v0.6 auf erledigt, DECISIONS aktualisieren, `config/version` auf `0.6.0` setzen.
3. Commit, Push nach Freigabe, CI-Prüfung über GitHub Actions.
4. Prompt für v0.7 „Der Park“ vorbereiten.

Beginne jetzt mit Schritt 0.
