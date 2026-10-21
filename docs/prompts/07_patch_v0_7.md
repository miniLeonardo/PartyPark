# Prompt 07: Patch v0.7 „Der Park“ (Antigravity)

In Antigravity verwenden, sobald Patch v0.6 „Mehr Chaos“ vollständig abgeschlossen ist (Version 0.6.0 in `project.godot`, Rache-Modus aktiv, 13 Minispiele spielbar, Zeitlupen-Wiederholung, Bonustitel). Kann im selben Gespräch oder in einem neuen gestartet werden.

---

Du entwickelst **Partypark**, ein lokales 3D-Partyspiel für bis zu 4 Spieler an einem Bildschirm (Godot 4.7, GDScript, Jolt, Forward+, Windows und Linux/Bazzite), lokal in Antigravity mit PowerShell-Terminal, Godot und Git. Ich bin Leonardo, Ideengeber und Spieldesigner.
`AGENTS.md` gilt vollständig: **Spieldesign, Regeln, Brett-Layout, Optik und Klang entscheide ich nach deinen Vorschlägen.** Technische Entscheidungen triffst du selbst.

Quellen für den Stand: `docs/DEVLOG.md` (oberster Eintrag), `docs/ROADMAP.md` (Abschnitt v0.7), `docs/DECISIONS.md`, `docs/GAME_DESIGN.md` (Abschnitt 10 und 12), `docs/ASSET_QUELLEN.md`, `docs/ARCHITECTURE.md`, `docs/MINIGAME_GUIDE.md`, `docs/ART_GUIDE.md`, `docs/PERFORMANCE.md`, letzte Testanleitung `docs/TESTANLEITUNG_V0_6.md`.

## Ziel des Patches

Patch v0.7 bringt das **Herzstück von Partypark** (Q01): den abendfüllenden Brettspiel-Modus **„Parkrundfahrt“**. Die Spieler bewegen ihre Knubbelfiguren über einen begehbaren 3D-Freizeitpark mit verzweigten Wegen, Attraktionen als Ereignisfeldern, Kiosken mit nützlichen Gegenständen und Tickets als Währung. Nach jeder Runde wird ein Minispiel um Tickets und Platzierungen ausgetragen. Ziel ist es, die meisten Goldenen Eintrittskarten zu ergattern.

## Schritt 0: Gesundheitscheck & Ausgangslage

1. **Tests ausführen:** Nutze den Skill `partypark-tests`:
   ```powershell
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/run_tests.gd
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --smoke-compile
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --smoke-m1
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --smoke-m2
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --smoke-games
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --tool-asset_audit
   ```
   Rote Tests zuerst beheben. Die Version in `project.godot` muss mindestens `0.6.0` sein.

2. **Entwickler-Schnellstart für das Brettspiel:**
   Ergänze in `core/game.gd` das Argument `--board` bzw. `--play-board`, damit das Brettspiel zu Testzwecken direkt ohne Titel- und Beitrittsmenü gestartet werden kann.

## Schritt 1: Lagebild und Spieldesign-Abstimmung

1. Stand in höchstens fünf Sätzen zusammenfassen.
2. In einer Fragerunde im Chat (nummerierte Fragen, Optionen A/B/C, Empfehlung mit Begründung voran, max. 4 Fragen):
   1. **Q01 Parkrundfahrt-Layout:** Soll das Brett ein zusammenhängender Rundkurs mit 2 Abkürzungen sein oder ein Netz aus mehreren Themenbereichen (Kirmes, Western, Gruselpark)?
   2. **Würfel-Mechanik:** Klassischer 3D-Physikwürfel (1 bis 6), Zahlen-Glücksrad oder bewegliche Schienen-Weiche?
   3. **Siegbedingung & Währung:** Tickets aus Minispielen kaufen die „Goldene Eintrittskarte“ (z. B. 20 Tickets pro Stern/Karte); wer nach 10/15 Runden die meisten Karten hat, gewinnt?
   4. **Rundenlänge:** Standard 10 Runden (ca. 35–45 Minuten) oder frei wählbar (10, 15, 20 Runden)?
3. Antworten sofort in `docs/DECISIONS.md` eintragen.

## Schritt 2: Arbeitspakete

Vor jedem größeren Paket einen Implementierungsplan als Artefakt vorlegen. Commits auf Deutsch (`v0.7 WP<n>: …`).

| WP | ROADMAP | Inhalt | Designfragen an Leonardo |
|---|---|---|---|
| 1 | 7.1 | Brett-Architektur: Wegenetz (`BoardGraph`, Felder-Knoten, Weggabelungen) & Park-Gelände | Wegverzweigungen, Feld-Typen |
| 2 | 7.2 | Spielfiguren auf dem Brett, Zug-Ablauf, Würfelsystem & Kamerafahrt | Würfeloptik, Geh-Animation |
| 3 | 7.3 | Ereignisfelder: Riesenrad (Platztausch), Parade (Vorschub), Wartung (Sperrung), Glücksrad | Feld-Aktionen |
| 4 | 7.4 | Kiosk & Park-Items: Doppelwürfel, Abkürzungs-Pass, Greifarm, Schutz-Schirm | Item-Preise & Effekte |
| 5 | 7.5 | Minispiel-Integration: Rundenabschluss mit Minispiel-Auslosung, Ticketvergabe | Minispiel-Regeln am Brett |
| 6 | 7.6 | Ansager-Integration („Hodenhüpfer“ kommentiert Brettgeschehen) & Musik | Ereignis-Sprüche, Fanfaren |
| 7 | 7.7 | Zwischenspeichern (`user://board_save.json`) & Spielabend-Fortsetzung | Speicheroptionen |
| 8 | 7.8 | Polishing, Testanleitung v0.7, Build & Export der `.exe` über `partypark-patch-abschluss` | keine |

**Haltepunkte:**
- **Nach WP 2:** Brett-Rundgang spielbar (Würfeln, Laufen, Gabelungen wählen); Video/Screenshots und Testanleitung zeigen.
- **Nach WP 5:** Kompletter Spielabend spielbar (Brettzug → Ereignis → Minispiel → Zwischenstand); Spieltest anbieten.

## Qualitätsregeln

1. `AGENTS.md` und `docs/ART_GUIDE.md` gelten vollständig.
2. Das Brett nutzt dieselben Figuren, `Look`-Materialien und ParkProps wie die Arenen.
3. Steuerung am Gamepad: Stick wählt Richtung an Gabelungen, A bestätigt/würfelt, B öffnet Inventar/Karte.
4. Alle Tastenhinweise nutzen `InputHints` mit gerätespezifischen Icons aus `kenney_input-prompts`.
5. Keine Ruckler beim Kamerawechsel zwischen Nahansicht der Figur und Übersicht des Parks.

## Abschluss des Patches

1. `docs/TESTANLEITUNG_V0_7.md` schreiben.
2. DEVLOG, ROADMAP v0.7 auf erledigt, DECISIONS aktualisieren, `config/version` auf `0.7.0` setzen.
3. Commit, Push nach Freigabe, CI-Prüfung über GitHub Actions.
4. Neue `Partypark.exe` für Windows bauen und bereitstellen.
5. Prompt für v0.8 „Party-Joker“ (Joker-Karten, Regelmodifikatoren, Sammelalbum) vorbereiten.

Beginne jetzt mit Schritt 0.
