# Prompt 05b: Fortsetzung der Übergabe an Antigravity und Abschluss von v0.5

Stand 2026-10-21: Teil A, Schritt A1 (Einlesen) sowie der Git-Abgleich (Commit, Remote `origin` auf `https://github.com/sudoMrMCaffe/PartyPark.git`, Push auf GitHub) wurden erfolgreich durchgeführt. Die Entwickler-VM wurde neu gestartet, und die GPU ist nun durchgereicht.

Dieser Prompt setzt die Übergabe ab Schritt A2 (mit durchgereichter GPU) fort und schließt im Anschluss Teil B (Rest von v0.5) ab.

---

Du entwickelst **Partypark** (lokales 3D-Partyspiel, bis zu 4 Spieler, Godot 4.7, GDScript, Jolt, Forward+, Windows und Linux/Bazzite) als technischer Partner von Leonardo.
`AGENTS.md` gilt vollständig: **Spieldesign entscheidet Leonardo.** Für alles Sichtbare gilt `docs/ART_GUIDE.md`.

## Bisheriger Stand zu Beginn dieses Chats
1. **Git:** Remote `origin` ist `https://github.com/sudoMrMCaffe/PartyPark.git`, Branch `main` ist synchron.
2. **Kompilierung & Tests:** Unit-Tests (31/31) und Smoke-Compile (`compile_smoke.gd`, 122 Dateien, 0 Fehler) sind grün. `tests/smoke/compile_smoke.gd` überspringt `_incoming` (D90).
3. **GPU:** Die GPU ist in der Windows-VM aktiviert.

---

## Aufgabenplan

### Schritt 1: Teil A2 – Tests mit aktiver GPU abschließen
1. **Smoke-Tests in PowerShell ausführen:**
   ```powershell
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --smoke-m1
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --smoke-m2
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --smoke-games
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --tool-asset_audit
   ```
   Erwartet: m1 50/50, m2 39/39, games 12/12. Abweichungen erst melden.
2. **Bildschirmfotos mit echter GPU rendern (A2.3):**
   ```powershell
   .\Godot_v4.7.2-stable_win64_console.exe --path . --resolution 1280x720 -- --smoke-style_probe --shots=docs/screenshots/check --moods=noon,golden,evening
   ```
   Prüfe die erzeugten Bilder gegen `docs/screenshots/v0_5/stilproben/` und zeige Leonardo etwaige Unterschiede in Licht und Glanz.
3. **Sichtbarer Spielstart (A2.4):**
   ```powershell
   .\Godot_v4.7.2-stable_win64_console.exe --path .
   ```
   Kurz starten, damit Leonardo sieht, dass das Spiel auf dem Desktop läuft.
4. **GitHub Actions prüfen (A2.5):**
   Prüfe auf GitHub (oder Leonardo fragen), ob die Actions für den aktuellen Commit grün durchgelaufen sind.

### Schritt 2: Teil A3 – Arbeitsweise umstellen
1. `AGENTS.md`: Windows-Befehle bei „Nützliche Befehle“ ergänzen (inkl. Screenshots und Asset-Audit). Datei bleibt unter 12.000 Zeichen und neutral bezüglich KI-Werkzeugnamen.
2. `AGENTS.md`: Rückfragen-Regeln klar verankern (Designfragen im Chat mit Optionen A, B, C; Empfehlung zuerst; max. 4 Fragen gebündelt; bei optischen Fragen immer 2 bis 3 Bildvarianten).
3. `CLAUDE.md`: Hinweis oben ergänzen, dass seit 2026-10-21 Antigravity die Hauptumgebung ist und Claude den Stand über Git holt.
4. **Antigravity-Skills anlegen** (`.agents/skills/<name>/SKILL.md`):
   - `partypark-tests`: Alle Prüfungen ausführen und zusammenfassen.
   - `partypark-screenshots`: Ansichten in allen 3 Stimmungen rendern.
   - `partypark-minigame`: Neues Minispiel nach Guide anlegen.
   - `partypark-patch-abschluss`: Testanleitung, Doku, Commit, Push, CI-Check.
5. DEVLOG-Eintrag „Übergabe an Antigravity abgeschlossen“, ROADMAP 6.0 auf erledigt, Commit `Übergabe: Antigravity als Hauptumgebung`, Push.

### Schritt 3: Teil B – Rest von v0.5 „Neuer Look“
Arbeitspakete nach den Leitlinien aus `docs/prompts/04_patch_v0_5.md` und den 10 Nachbesserungen aus `docs/prompts/05_uebergabe_antigravity.md`:
- **WP 3 (5.3):** Asset-Pipeline (genutzte Dateien nach `assets/third_party/<paket>/`, CREDITS).
- **WP 4 (5.4):** Look-Grundlage vervollständigen (Materialien, Wasser, Glühbirnen).
- **WP 5 (5.5) & WP 5a:** Spielfigur-Feinschliff, Partyhütchen als Zubehör-Probe; Waffen-Szenen in `core/weapons/` aus dem Kenney Blaster Kit für Zerfetzung (Q24 mit Bildern).
- *Haltepunkt 1:* Bilder von Figur und Blastern zeigen, kurzes Feedback abholen.
- **WP 6 (5.6):** Park-Kulisse und 7 Themen-Arenen (Q26 Themenwahl mit Bildern, D84, alle 3 Stimmungen, Draw-Call-Budget beachten).
- *Haltepunkt 2:* Arenen-Galerie zeigen.
- **WP 7 bis 10:** Effekte (WP 7), Menüs & Tastensymbole (WP 8, Q23), Leistung (WP 9), Nachher-Galerie & Testanleitung v0.5 & Version 0.5.0 (WP 10).

Beginne direkt mit Schritt 1 (A2-Tests).
