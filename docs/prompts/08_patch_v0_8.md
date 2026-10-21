# Prompt 08: Patch v0.8 „Party-Joker“ (Antigravity)

In Antigravity verwenden, sobald Patch v0.7 „Der Park“ vollständig abgeschlossen und von Leonardo probegetestet wurde (Version 0.7.0 in `project.godot`, interaktiver 3D-Freizeitpark als Hub spielbar, Kletterturm & Spielplatz aktiv, Partypark.exe bereitgestellt). Kann im selben Gespräch oder in einem neuen gestartet werden.

---

Du entwickelst **Partypark**, ein lokales 3D-Partyspiel für bis zu 4 Spieler an einem Bildschirm (Godot 4.7, GDScript, Jolt, Forward+, Windows und Linux/Bazzite), lokal in Antigravity mit PowerShell-Terminal, Godot und Git. Ich bin Leonardo, Ideengeber und Spieldesigner.
`AGENTS.md` gilt vollständig: **Spieldesign, Regeln, Joker-Effekte, Mikrospiel-Ideen, Optik und Klang entscheide ich nach deinen Vorschlägen.** Technische Entscheidungen triffst du selbst.

Quellen für den Stand: `docs/DEVLOG.md` (oberster Eintrag), `docs/ROADMAP.md` (Abschnitt v0.8), `docs/DECISIONS.md`, `docs/GAME_DESIGN.md` (Abschnitt 10 und 12), `docs/TESTANLEITUNG_V0_7.md`.

## Ziel des Patches

Patch v0.8 sorgt dafür, dass **kein Abend dem anderen gleicht**:
1. **Joker-Karten (Chaos-Modifikatoren):** Vor jeder Runde darf der Letztplatzierte (oder per Zufall) 1 aus 3 Karten wählen, die das anstehende Minispiel drastisch verändern (z. B. Mondschwerkraft, Riesenköpfe, Spiegelsteuerung, Seifenboden, Nebel, doppelte Punkte).
2. **Mikrospiel-Marathon:** Ein rasanter WarioWare-artiger Spielmodus mit ultrakurzen 3-bis-5-Sekunden-Mikrospielen („Duck dich!“, „Weiche aus!“, „Fang den Ball!“), der immer schneller wird.
3. **Sammelalbum & Ticket-Bude:** Nach Minispielen verdiente Park-Tickets können in der Ticket-Bude im Hub gegen lustige Hüte, Brillen und Accessoires eingetauscht werden.
4. **Lokale Rekorde & Bestenlisten:** Highscore-Tafeln an den Minispiel-Buden im Park.

## Schritt 0: Vorbereitung & Gesundheitscheck

1. **Tests ausführen:** Nutze den Skill `partypark-tests`:
   ```powershell
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/run_tests.gd
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --smoke-compile
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --smoke-hub
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --smoke-m1
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --smoke-m2
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --smoke-games
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --tool-asset_audit
   ```
   Rote Tests zuerst beheben. Version in `project.godot` muss mindestens `0.7.0` sein.

## Schritt 1: Lagebild und Spieldesign-Abstimmung

1. Stand in höchstens fünf Sätzen zusammenfassen.
2. In einer Fragerunde im Chat (nummerierte Fragen, Optionen A/B/C, Empfehlung mit Begründung voran, max. 4 Fragen):
   1. **Joker-Auswahl:** Wann und von wem werden die Joker gewählt (z. B. immer der Letztplatzierte als Aufhol-Mechanik, oder Reihum-Wahl)?
   2. **Joker-Effekt-Katalog:** Welche ersten 6 Chaos-Modifikatoren sollen ins Spiel (z. B. Mondschwerkraft, Glatteis, Riesenköpfe, Turbo-Tempo, Seifenblasen, Punkt-Doppler)?
   3. **Mikrospiel-Marathon:** Soll der Marathon als eigenständige Bude im Park stehen oder auch als Turniervariante wählbar sein?
   4. **Ticket-Belohnungen:** Welche kosmetischen Zubehörteile (Hüte, Brillen, Partymützen) sollen zuerst freischaltbar sein?
3. Antworten sofort in `docs/DECISIONS.md` eintragen.

## Schritt 2: Arbeitspakete

Vor jedem größeren Paket einen Implementierungsplan als Artefakt vorlegen. Commits auf Deutsch (`v0.8 WP<n>: …`).

| WP | ROADMAP | Inhalt |
|---|---|---|
| 1 | 8.1 | Modifikatoren-Framework: Modifikatoren auf Figur, Physik, Kamera & Regeln; Joker-Kartenauswahl im MatchFlow |
| 2 | 8.1 | Erste 6 Joker-Karten: Mondschwerkraft, Glatteis-Boden, Riesenköpfe, Zeitraffer, Turbotempo, Punkte-Doppler |
| 3 | 8.2 | Mikrospiel-Marathon: Schnelle Taktung, Befehlswort-Anzeige, Lebenspunkte-Anzeige, Geschwindigkeits-Steigerung |
| 4 | 8.2 | Erste 5 Mikrospiele: „Duck dich!“, „Fange!“, „Drücke A!“, „Bleib stehen!“, „Schubs! |
| 5 | 8.3 | Ticket-System & Belohnungsbude im Hub: Tickets am Rundenende, Bude zum Freischalten von Zubehör |
| 6 | 8.4 | Lokale Bestenlisten & Rekorde: Rekord-Tafeln an den Buden im Park |
| 7 | 8.5 | Polishing, Testanleitung v0.8, Build & Export der `.exe` über `partypark-patch-abschluss` |
