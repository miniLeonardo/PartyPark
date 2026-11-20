# Fremde Assets und Lizenzen

Jede Datei, die nicht selbst erstellt wurde, hier eintragen. Erlaubt sind CC0, CC-BY (mit Namensnennung), MIT und vergleichbar freie Lizenzen.

| Datei / Ordner | Urheber | Quelle (URL) | Lizenz | Hinzugefügt am |
|---|---|---|---|---|
| `assets/third_party/kenney_coaster-kit/` (nur genutzte Modelle: Bäume, Buden; Lizenz in `License.txt`) | Kenney (www.kenney.nl) | https://kenney.nl/assets/coaster-kit | CC0 1.0 | 2026-10-21 |
| `assets/third_party/kenney_blaster-kit/` (nur Blaster a, e, k; Lizenz in `License.txt`) | Kenney (www.kenney.nl) | https://kenney.nl/assets/blaster-kit | CC0 1.0 | 2026-10-21 |
| `assets/third_party/kenney_mini-characters/` (nur die 12 Parkbesucher-Modelle; Lizenz in `License.txt`) | Kenney (www.kenney.nl) | https://kenney.nl/assets/mini-characters | CC0 1.0 | 2026-10-21 |

Aufgeräumt 2026-11-20: Ungenutzte Pakete (Castle, Food, Input Prompts, Particle, Toy Car, Quaternius Farm) und ungenutzte Modelle wurden aus dem Repository entfernt. Originale: lokal `assets/_incoming/`, neu laden mit `tools/download_assets.ps1`, Quellen in `docs/ASSET_QUELLEN.md`. Nur genutzte Dateien nach `assets/third_party/` übernehmen.

## Selbst erzeugte Assets

| Datei / Ordner | Herkunft | Lizenz | Hinzugefügt am |
|---|---|---|---|
| `core/look/park_props.gd` (Riesenrad, Zelte, Achterbahn, Lichterketten, Fahnen, Laternen) | selbst gebaut aus Grundformen im Code | eigenes Werk des Projekts | 2026-10-21 |
| `core/look/shaders/water.gdshader` | selbst geschrieben | eigenes Werk des Projekts | 2026-10-21 |
| `assets/audio/sfx/*.wav` | selbst erzeugt mit `tools/sfx_gen.gd` aus den Rezepten in `tools/sfx_recipes.gd` (sfxr-Prinzip, keine fremden Samples) | eigenes Werk des Projekts | 2026-10-20 |
