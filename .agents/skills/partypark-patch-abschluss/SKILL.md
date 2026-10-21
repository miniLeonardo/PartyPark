---
name: partypark-patch-abschluss
description: >-
  Abschluss-Checkliste für einen Meilenstein oder Patch: Tests grün, Testanleitung verfassen,
  DEVLOG, ROADMAP, DECISIONS aktualisieren, Versionsnummer setzen, Commit, Push und CI prüfen.
---

# Partypark: Patch- & Meilenstein-Abschluss

Vorgehen beim Fertigstellen eines Arbeitspakets, Meilensteins oder Release-Patches.

## Checkliste

1. **Tests & Qualitätsprüfung:**
   - Headless Import ohne Warnungen/Fehler.
   - Alle Tests grün (`run_tests.gd`, `compile_smoke.gd`, `smoke-m1`, `smoke-m2`, `smoke-games`).
   - Asset-Audit sauber (`--tool-asset_audit`).

2. **Testanleitung für Leonardo:**
   - Datei `docs/TESTANLEITUNG_V<version>.md` anlegen oder ergänzen.
   - Nummerierte Liste konkreter Prüfschritte (z. B. Spielgefühl, Controller, Audio, Bildrate).

3. **Dokumentation aktualisieren:**
   - `docs/DEVLOG.md`: Neuer Eintrag ganz oben nach Standard-Vorlage.
   - `docs/ROADMAP.md`: Status der Aufgaben auf `erledigt` setzen.
   - `docs/DECISIONS.md`: Alle neuen Entscheidungen als `Dxx` und geklärte Fragen eintragen.
   - Falls Patch-Abschluss: `config/version` in `project.godot` hochzählen.

4. **Git & Synchronisation:**
   - `git status` prüfen.
   - Sinnvolle deutsche Commit-Nachricht mit Präfix (z. B. `v0.5 WP6: Themen-Arenen`).
   - `git push origin main` nach Freigabe ausführen.
   - GitHub Actions auf Erfolg prüfen.

5. **Build & Export (.exe bereitstellen):**
   - Windows-Export bauen:
     ```powershell
     .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --export-release "Windows Desktop" builds/windows/Partypark.exe
     ```
   - Die eigenständige Datei `builds/windows/Partypark.exe` für Tests auf anderen PCs bereitstellen.
