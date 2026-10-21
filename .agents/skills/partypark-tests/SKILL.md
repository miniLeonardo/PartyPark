---
name: partypark-tests
description: >-
  Führt alle Tests und Prüfungen für Partypark unter Windows aus: Unit-Tests,
  smoke-compile, smoke-m1, smoke-m2, smoke-games und asset_audit.
---

# Partypark: Tests & Prüfungen

Dieser Skill führt die standardmäßigen Tests für Partypark aus und fasst die Ergebnisse zusammen.

## Auszuführende Befehle

Führe die folgenden Befehle nacheinander in PowerShell im Projektstamm aus:

1. **Unit-Tests (Logik, Punkte, Registry, Fx, Sfx, Announcer):**
   ```powershell
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/run_tests.gd
   ```
   *Erwartet:* 31 bestanden, 0 fehlgeschlagen.

2. **Smoke-Compile (Laden aller Skripte und Szenen):**
   ```powershell
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --smoke-compile
   ```
   *Erwartet:* 122 Dateien geladen, 0 Fehler.

3. **Smoke M1 (Beitritt, Steuerung, Pause, Controller-Trennung):**
   ```powershell
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --smoke-m1
   ```
   *Erwartet:* 50 von 50 Prüfungen bestanden.

4. **Smoke M2 (Turnier, Freies Spiel, Optionen):**
   ```powershell
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --smoke-m2
   ```
   *Erwartet:* 39 von 39 Prüfungen bestanden.

5. **Smoke Games (Simulation aller 7 Minispiele mit 4 Computergegnern):**
   ```powershell
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --smoke-games
   ```
   *Erwartet:* 12 von 12 Prüfungen bestanden.

6. **Asset-Audit (Dreiecke, Meshes, Draw Calls, Lichter):**
   ```powershell
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --tool-asset_audit
   ```
   *Prüfung:* Draw Calls unter 400 (Splitscreen unter 250), Dreiecke unter 300.000.
