---
name: partypark-minigame
description: >-
  Leitfaden zum Erstellen eines neuen Minispiels nach docs/MINIGAME_GUIDE.md und docs/ART_GUIDE.md
  mit tools/new_minigame.gd, Konzeptrunde, KI-Profil, Arena und Tests.
---

# Partypark: Neues Minispiel anlegen

Anleitung zum Erstellen eines neuen Minispiels innerhalb einer Sitzung.

## Schrittweiser Ablauf

1. **Konzeptrunde mit Leonardo:**
   - Spielidee, Ziel, Tastenbelegung, Rundendauer, Siegbedingung abstimmen.
   - 2 bis 4 konkrete Optionen anbieten, Empfehlung zuerst begründen.
   - Freigabe als `Dxx` in `docs/DECISIONS.md` festhalten.

2. **Gerüst generieren:**
   ```powershell
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tools/new_minigame.gd -- --id=<id> --name="<Name>" --formats=ffa
   ```
   Legt `minigames/<id>/` an mit `info.tres`, `<id>.tscn`, `<id>.gd` und trägt die ID in `tests/unit/test_registry.gd` ein.

3. **Import & Basistest:**
   ```powershell
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --import
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --smoke-games --game=<id>
   ```

4. **Umsetzung & Integration:**
   - Arena als bearbeitbare `.tscn` mit `Look` und `ParkProps` aufbauen.
   - Steuerung über `player.get_input()` (`move`, `push`, `action`, etc.).
   - Computergegner über `_update_ai()` und `AIProfile`.
   - Feedback: Effekte (`Fx.shake`, `Fx.burst`, `Fx.hitstop`), Geräusche (`Sfx.play`) und Ansager (`Announcer.say`).

5. **Prüfung:**
   - `partypark-tests` ausführen.
   - Asset-Audit prüfen (Draw Calls unter 400).
   - Messmodus `-- --bench` zur Performanceprüfung.
