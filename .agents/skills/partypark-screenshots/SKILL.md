---
name: partypark-screenshots
description: >-
  Rendert festgelegte Ansichten (Stilproben, Minispiele, Menüs, Siegerehrung) in
  allen drei Stimmungen (Nachmittag, Goldene Stunde, Abend) und legt sie als Galerie ab.
---

# Partypark: Screenshots & Stilproben

Dieser Skill erstellt visuelle Bildschirmfotos in 1280x720 Auflösung mit der aktiven Grafikkarte/Forward+-Renderer.

## Stilproben & Stimmungs-Check

Rendert die Standard-Stilprobe (Autoscooter-Arena mit Park-Kulisse) in allen drei Tageszeiten (`noon`, `golden`, `evening`):

```powershell
.\Godot_v4.7.2-stable_win64_console.exe --path . --resolution 1280x720 -- --smoke-style_probe --shots=docs/screenshots/check --moods=noon,golden,evening
```

Ergebnisdateien in `docs/screenshots/check/`:
- `plastic_noon_held.png`, `plastic_noon_spiel.png`
- `plastic_golden_held.png`, `plastic_golden_spiel.png`
- `plastic_evening_held.png`, `plastic_evening_spiel.png`

## Galerie-Generierung für Versionen

Für Vorher-Nachher-Vergleiche (z. B. nach `docs/screenshots/v0_5/nachher/`):
1. Zielordner anlegen (`New-Item -ItemType Directory ...`).
2. Screenshots mit `--shots=<zielordner>` rendern.
3. Bilder prüfen (Glanz, Schatten, Lesbarkeit, Farbharmonie).
4. Dokumentation in `docs/screenshots/v0_5/README.md` aktualisieren.
