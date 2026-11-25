# Partypark: Art Guide

Verbindlich für alle Agenten und Menschen, die an Partypark Grafik, Arenen, Menüs oder Effekte bauen (Stand 2026-10-21, v0.5). Entschieden in D85 (Stil) und D86 (Stimmung); technisch umgesetzt in `core/look/` (D87). Wer abweichen will, fragt Leonardo und trägt die Änderung in `docs/DECISIONS.md` ein.

## 1. Der Stil in einem Satz

**Lackiertes Spielzeug in einem Freizeitpark:** glatte, glänzende Oberflächen mit Klarlack und weichem Randlicht, kräftige, aber nicht grelle Farben, weiche Schatten, Low-Poly-Formen mit runden Kanten, **keine Umrisslinien**.

Vorbildbilder: `docs/stil/plastic_noon_held.png`, `plastic_golden_held.png`, `plastic_evening_held.png` (Variante A). Die verworfenen Varianten B (Toon) und C (Flach) sind in `docs/stil/uebersicht_stil_stimmung.png` zu sehen.

## 2. So benutzt man den Look im Code

| Aufgabe | Aufruf |
|---|---|
| Himmel, Sonne, Nebel, Glow einer Szene | `StageKit.add_environment(self)` oder `Look.add_environment(self)` |
| Stimmung vor dem Szenenaufbau wählen | `Look.use_mood(Look.mood_for_progress(t))`, Menüs `Look.menu_mood()` |
| Fläche in einer Farbe (geteilt, unveränderlich) | `Look.surface(Color("#f2be86"), Look.Kind.STONE)` |
| Eigenes, veränderbares Material (z. B. für Emission) | `StageKit.make_material(color, kind)` |
| Spielfigur | `Look.character_material(color)` (macht `PlayerVisual` selbst) |
| Glühbirne, Lichterkette | `Look.bulb_material(color)` |
| Anderes Leuchtendes (unbeleuchtet) | `Look.glow_surface(color, energy)` |
| Emission auf eigenem Material setzen oder ändern (Pulsieren, Warnfarbe) | `Look.set_glow(material, color, energy)` |
| Wasser | `Look.water_material()` |
| Fremdes Modell (Kenney, KayKit, Quaternius) einfärben | `Look.restyle(model, Look.Kind.PLASTIC, tint)` |
| Park-Bauteile | `ParkProps.ferris_wheel()`, `tent()`, `coaster(points)`, `string_lights(a, b)`, `flag_pole()`, `lamp_post()` |

Nie eigene `Environment`, `WorldEnvironment` oder Sonnen in Minispielen anlegen; Feinabstimmung nur in `Look.MOODS`.

## 3. Licht und Stimmungen

Drei Stimmungen, Werte in `core/look/look.gd` (`MOODS`):

| Stimmung | Sonne | Himmel oben / Horizont | Besonderheiten |
|---|---|---|---|
| Nachmittag | hoch (−55°), `#fff2dc`, Energie 1,3 | `#3f8fe6` / `#cde8ff` | hellste Stimmung, kein Fülllicht, Glühbirnen aus |
| Goldene Stunde | flach (−24°), `#ffc07a`, Energie 1,45 | `#5b7fd1` / `#ffd09a` | lange Schatten, Fülllicht blau 0,15, Glühbirnen schwach |
| Abendrummel | sehr flach (−28°), `#ffa36e`, Energie 0,65 | `#1c2257` / `#e0767a` | Fülllicht blau 0,4, Glühbirnen hell, Glow stark, echte Lampenlichter (ab Grafik Mittel) |

**Tagesverlauf (D86):** Im Turnier sind das erste Drittel der Runden Nachmittag, das zweite goldene Stunde, das letzte Abendrummel; die Siegerehrung ist abends. Im Freien Spiel rückt jede Runde eine Tageszeit weiter. Titel, Beitritt und Menüs zeigen den Abendrummel. Option „Tageszeit“: Tagesverlauf (Standard), Nachmittag, Goldene Stunde, Abend; eine feste Wahl gilt überall.

Regeln:

1. Genau **ein** Richtungslicht mit Schatten (die Sonne). Fülllicht ohne Schatten.
2. Tonemapping **AgX**, Sättigung 1,2 über `adjustment_saturation`. AgX entsättigt sehr helle Farben, deshalb Grundfarben nicht heller als etwa 85 % Helligkeit wählen.
3. Tiefennebel (Beginn 30 bis 45 m) gibt der Kulisse Tiefe; der Himmel bleibt ungenebelt.
4. Glow nur für Leuchtendes (Schwelle 0,9): Glühbirnen, Lampen, Funken. Nicht für Böden oder Figuren.
5. SSAO nur auf Grafikstufe Hoch. Keine SDFGI, keine VoxelGI, keine Lightmaps.
6. Lampenlichter (OmniLight3D) nur im Abendrummel, ohne Schatten, Reichweite höchstens 10 m, höchstens 8 pro Arena.

## 4. Materialien

Alle Materialien sind `StandardMaterial3D` aus `Look.surface()`; gleiche Farbe und Stoffart teilen sich ein Material.

Randlicht-Stufen (`Look.RIM_LEVELS`, `Look.use_rim_level()`): Standard `CLASSIC` (Werte der Tabelle). `SOFT` und `STRONG` legen zusätzlich einen Fresnel-Rand in der Horizontfarbe darüber (`core/look/shaders/rim.gdshader`, ein Draw Call mehr je Fläche); Auswahl offen (Roadmap 5.4, Bilder in `docs/screenshots/look_5_4/`).

| Stoffart (`Look.Kind`) | Rauheit | Klarlack | Sonstiges | Wofür |
|---|---|---|---|---|
| `PLASTIC` | 0,32 | 0,5 | Randlicht 0,2 | Standard für Spielobjekte, Banden, Buden |
| `GLOSSY` | 0,2 | 0,8 | Randlicht 0,3 | besonders wichtige Spielobjekte (Bombe, Pokale) |
| Figur (`character_material`) | 0,22 | 0,8 | Randlicht 0,4 | nur Spielfiguren |
| `METAL` | 0,3 | | metallisch 0,6 | Gestänge, Riesenrad, Laternen |
| `RUBBER` | 0,6 | | | Reifen, Kabel, Matten |
| `WOOD`, `FABRIC` | 0,8 | | | Planken, Zeltplanen, Fahnen |
| `STONE` | 0,85 | | | Arenaböden, Mauern, Wege |
| `GRASS`, `GROUND` | 0,95 | | | Wiesen, Erde |

Wasser: eigener Shader `core/look/shaders/water.gdshader` mit zwei Farbtönen nach Tiefe, sanften Wellen, Schaumkante an allem, was ins Wasser ragt, und vereinzeltem Glitzern. Damit die Schaumkante sichtbar ist, sollen Plattformen sichtbar ins Wasser reichen (Sockel breiter als die Plattform).

## 5. Farbpalette

Spielerfarben (Q10, farbsehschwächen-sicher nach Okabe-Ito, unverändert) haben Vorrang: Sie dürfen in der Arena nicht großflächig vorkommen.

| Gruppe | Name | Hex | Einsatz |
|---|---|---|---|
| Spieler | Blau | `#1f7ae0` | Spieler 1 |
| Spieler | Zinnoberrot | `#e5531a` | Spieler 2 |
| Spieler | Gelb | `#f2d72e` | Spieler 3 |
| Spieler | Blaugrün | `#14a37f` | Spieler 4 |
| Teams | Orange | `#ff9a1f` | Teamringe (D57) |
| Teams | Lila | `#9b6bff` | Teamringe (D57) |
| Park-Akzente | Kirmesrot | `#ff5d73` | Zeltstreifen, Achterbahnschienen |
| Park-Akzente | Sonnengelb | `#ffcf3f` | Bandenstreifen, Naben, Wimpel |
| Park-Akzente | Korallenorange | `#ff6b4a` | Bandenstreifen |
| Park-Akzente | Minze | `#41c7a9` | Gondeln, Wagen |
| Park-Akzente | Himmelblau | `#5aa8ff` | Zelte, Gondeln |
| Park-Akzente | Flieder | `#b47cff` | Fahnen, Gondeln |
| Neutrale | Creme | `#fff6e8` | Zeltstreifen, Schilder |
| Neutrale | Lackweiß | `#f4f1ff` | Metallgestänge |
| Neutrale | Tiefviolett | `#3d3a5c` | Laternen, Schwellen, dunkle Akzente statt Schwarz |
| Neutrale | Sand | `#f2be86` | Arenaböden (Standard) |
| Neutrale | Sand dunkel | `#e8a66e` | Bodenmuster, Ringe |
| Natur | Rasen | `#7cc96a` | Wiesen |
| Wasser | Flach / Tief | `#5cc7eb` / `#1f6bbf` | Wasser-Shader (Nachmittag) |
| Leuchten | Glühbirnen | `#ffd75e`, `#ff8f5e`, `#ff6fa8`, `#8fe3ff`, `#b6ff7a` | Lichterketten, Riesenrad |

Regeln: Kein reines Schwarz (statt dessen `#3d3a5c` oder dunkle Töne der Grundfarbe), kein reines Weiß für große Flächen. Gefahren (Abgrund, heiße Zone, gleich fallende Wabe) sind warm-rot bis weiß blinkend und mit Muster markiert, nie nur über Farbe.

## 6. Fremde Modelle

1. Nur freigegebene Pakete (D83), Dateien nach `assets/third_party/<paket>/` mit `License.txt`, Eintrag in `assets/CREDITS.md`.
2. Jedes fremde Modell läuft durch `Look.restyle()`. Damit bekommt es Partypark-Glanz und Randlicht; die Farbtextur (Kenney `colormap.png`, KayKit `platformer_texture.png`) bleibt. Mit `tint` an die Palette anpassen.
3. Fremde Modelle nie allein stehen lassen: mit eigenen `ParkProps` und Palettenfarben mischen, damit nichts nach Baukasten aussieht.
4. Keine fremden Figuren als Spielfigur (D15); Kenney Mini Characters höchstens als Zuschauer am Rand.

## 7. Maßstab

Einheit Meter. Die Spielfigur ist der Maßstab.

| Objekt | Größe |
|---|---|
| Spielfigur | 1,4 m hoch, 0,9 m breit |
| Riese | 3-fache Figur |
| Bande | 0,7 m hoch |
| Tür, Budeneingang | 2,2 m |
| Bude, Kiosk | 4 m hoch |
| Baum | 5 bis 7 m |
| Laterne | 3,5 bis 4,2 m |
| Zirkuszelt | Radius 3 bis 4 m |
| Riesenrad | 20 bis 24 m hoch (Kulisse) |
| Achterbahn | 3 bis 12 m über Boden (Kulisse) |
| Arenaboden | 20 bis 26 m Durchmesser, spielrelevante Maße nie ohne Leonardo ändern |

## 8. Texturen

1. Höchstens 1024 px Kantenlänge, VRAM-komprimiert, mit Mipmaps.
2. Bevorzugt Paletten-Texturen (ein Atlas für ein ganzes Paket) oder einfarbige Materialien.
3. Eigene Texturen als PNG in `assets/textures/own/`, prozedurale Texturen bevorzugt im Code (`NoiseTexture2D`, `GradientTexture2D`).
4. Fotorealistische Texturen (ambientCG) nur stark nachgefärbt und dezent.

## 9. Lesbarkeit für vier Spieler

1. Figuren müssen sich immer vom Boden abheben: Arenaböden in hellen, warmen Mitteltönen (Sand), nie in einer Spielerfarbe.
2. Jede Figur wirft einen gut sichtbaren Schatten; auf Grafik Niedrig (ohne Schatten) sorgt der Spielerring bzw. der Bodenkreis für Halt.
3. Spielobjekte (Bombe, Seil, Schafe, Wolf, Scooter) stehen farblich und durch Glanz (`GLOSSY`) vor der Kulisse.
4. Kulisse ist ruhiger als die Arena: kleinere Kontraste, im Nebel, keine bewegten Dinge in Spielerfarben.
5. Aus der höchsten Spielkamera prüfen, nicht nur aus der Heldenperspektive.

## 10. Leistung (Budgets je Arena)

| Wert | Grenze |
|---|---|
| Richtungslichter mit Schatten | 1 |
| Dreiecke im Bild | unter 300.000 (je Arena präzisiert in Abschnitt 13) |
| Draw Calls | unter 400 (Splitscreen: je Ansicht unter 250) |
| Texturen | höchstens 1024 px |
| Partikel gleichzeitig | 700 (D63) |
| Lampenlichter | höchstens 8, nur Abendrummel |

Wiederholte Deko (Bäume, Laternen, Schwellen, Zuschauer) über `MultiMeshInstance3D`. Prüfen mit `godot --headless --path . -- --tool-asset_audit`. Grafikstufen siehe `docs/PERFORMANCE.md`.

## 11. Do und Don't

| Do | Don't |
|---|---|
| Runde, weiche Formen; Fasen und Rundungen statt scharfer Kanten | Spitze, dünne, realistische Formen |
| Eine Hauptfarbe je Objekt, ein Akzent | Viele Farben auf kleinem Raum |
| Glänzende Spielobjekte, matte Böden | Alles glänzend (Bild wird unruhig) |
| Dunkle Töne aus der Palette | Reines Schwarz, reines Weiß auf großen Flächen |
| Kulisse im Nebel, Lichterketten als Akzent | Kulisse heller oder bunter als die Arena |
| Fremde Modelle über `Look.restyle()` | Fremde Modelle mit Originalmaterial |
| Werte in `Look.MOODS` und `Look.surface()` ändern | Eigene Environments oder Sonnen in Minispielen |
| Leuchten über Emission und Glow | Leuchten über viele echte Lichter |

## 12. Beispielbilder

| Bild | Inhalt |
|---|---|
| `docs/stil/uebersicht_stil_stimmung.png` | alle drei Stile in drei Stimmungen (Entscheidungsgrundlage D85) |
| `docs/stil/plastic_noon_held.png` | gewählter Stil, Nachmittag |
| `docs/stil/plastic_golden_held.png` | gewählter Stil, goldene Stunde |
| `docs/stil/plastic_evening_held.png` | gewählter Stil, Abendrummel |

Ältere Vorher-Bilder (v0.4, v0.7) und die verworfenen Stilvarianten liegen nur noch in der Git-Historie (vor 2026-11-20 unter `docs/screenshots/`). Neue Prüfbilder gehen nach `docs/screenshots/` (nicht versioniert).

Neue Stilproben: `xvfb-run -a godot --path . --rendering-driver vulkan --resolution 1280x720 -- --smoke-style_probe --shots=<ordner> --moods=noon,golden,evening`.

## 13. Asset-Budget und Importvorgaben

Ergänzt Abschnitt 6 (Fremde Modelle), 8 (Texturen) und 10 (Leistung); Stand 2026-11-25 (Roadmap 5.3). Die Grenzen stehen als Konstanten oben in `tools/asset_audit.gd`; Überschreitungen markiert das Audit mit ⚠.

### Audit starten

```powershell
.\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --tool-asset_audit
```

Das Audit baut jedes Minispiel über die Sandbox und danach den Park (Hub) auf und gibt je Szene aus: Dreiecke, Meshes, MultiMesh-Instanzen, Materialien, geschätzte Draw Calls (Farbe plus Schatten je Oberfläche), Lichter, und je genutzter Textur Pfad, Größe in Pixeln, Format (z. B. DXT1), Mipmaps und VRAM in MB. Danach folgt ein Überblick über `assets/third_party/`: Dateien und MB je Paket, Lizenzdatei vorhanden, Texturen mit abweichenden Importvorgaben, die größten Dateien. Gezählt wird die ganze Szene (nicht nur das Bild), auf Grafikstufe Mittel.

### Messwerte (2026-11-25)

| Szene | Dreiecke | Draw Calls (geschätzt) | Lichter (Schatten) | Texturen (VRAM) |
|---|---|---|---|---|
| Minispiele, Spanne | 15.300 bis 151.800 (Schafe hüten) | 76 bis 220, Ausreißer Wackelwaben 604 | 2 (1) | 0 bis 1 (0,17 MB) |
| Freizeitpark (Hub) | 347.343 | ~1.357 | 18 (1) | 2 (0,33 MB) |
| `assets/third_party/` gesamt | | | | 3 Pakete, 26 Dateien, 3,2 MB |

### Budget je Szene

Messwert plus etwa 30 % Puffer; die Draw-Call-Grenze für Arenen bleibt bei 400 (Abschnitt 10). Wackelwaben liegt mit 302 einzelnen Waben darüber und ist ein bekannter Ausreißer (Abhilfe: Waben als MultiMesh oder Schatten der Waben aus).

| Wert | Minispiel-Arena | Park (Hub, ganze Szene) |
|---|---|---|
| Dreiecke | 200.000 (präzisiert die 300.000 aus Abschnitt 10) | 450.000 |
| Draw Calls (geschätzt) | 400 (Splitscreen je Ansicht 250) | 1.600 (Frustum-Culling zeigt nur einen Teil) |
| Lichter gesamt | 10 (Sonne, Fülllicht, höchstens 8 Lampen) | 24 |
| Richtungslichter mit Schatten | 1 | 1 |
| Textur-VRAM | 8 MB | 16 MB |
| Einzeltextur | höchstens 1024 px Kantenlänge | höchstens 1024 px |

Zum Vergleich: eine 1024-px-Textur mit Mipmaps belegt als DXT1 etwa 0,7 MB, als DXT5/BPTC etwa 1,3 MB, unkomprimiert (RGBA8) etwa 5,3 MB.

### Ordnerregel

1. Jedes fremde Paket liegt in `assets/third_party/<urheber>_<paket>/` (z. B. `kenney_coaster-kit/`), Kleinbuchstaben, Bindestriche wie im Original.
2. Im Paketordner liegt die Lizenzdatei des Urhebers (`License.txt`); das Audit warnt, wenn sie fehlt.
3. Nur tatsächlich genutzte Dateien übernehmen (Modelle plus deren Textur, meist `Textures/colormap.png`). Rohdownloads bleiben in `assets/_incoming/` (nicht versioniert, mit `.gdignore`).
4. Jedes Paket hat eine Zeile in `assets/CREDITS.md` (Quelle, Lizenz, Datum, welche Dateien).
5. Einzeldateien über 10 MB vermeiden (Audit warnt); siehe Git LFS unten.

### Importvorgaben

| Dateiart | Vorgabe in der `.import`-Datei | Warum |
|---|---|---|
| Textur für 3D (PNG, JPG) | `compress/mode=2` (VRAM komprimiert), `compress/high_quality=false`, `mipmaps/generate=true`, `detect_3d/compress_to=0` | spart etwa 80 % Grafikspeicher (512-px-Farbatlas: 0,17 MB statt 1 MB); Mipmaps verhindern Flimmern in der Ferne und passen zum Filter `LINEAR_WITH_MIPMAPS_ANISOTROPIC` aus `Look.surface()` |
| Textur für UI (Symbole, Schriften) | Godot-Standard (verlustfrei, `compress/mode=0`), ohne Mipmaps | scharfe Kanten, Größe unkritisch |
| Modell (`.glb`, `.gltf`) | Godot-Standard: `meshes/generate_lods=true`, `meshes/create_shadow_meshes=true`, `meshes/force_disable_compression=false`, `gltf/embedded_image_handling=1` (eingebettete Bilder extrahieren) | LODs und Schattenmeshes kosten nichts und helfen in der Kulisse; Material kommt ohnehin aus `Look.restyle()` |

Neue Texturen nach dem Kopieren einmal importieren und die `.import`-Datei auf diese Werte setzen (im Editor: Import-Dock, „Komprimieren: VRAM komprimiert“, „Mipmaps erzeugen“ an, „Neu importieren“), danach mit `--import` und dem Audit prüfen. Stand 2026-11-25: alle drei Kenney-Farbatlanten (`colormap.png`, 512 × 512) wurden von „verlustfrei ohne Mipmaps“ auf diese Vorgabe umgestellt (jetzt DXT1 mit Mipmaps, 0,17 MB je Atlas); die 18 `.glb`-Dateien hatten bereits einheitlich die Standardwerte.

### Git LFS (Q27)

Kein Git LFS. Gemessen 2026-11-25: aktueller Stand 479 Dateien, 8,3 MB; gesamte Historie 1.935 Blobs, 34,9 MB unkomprimiert, Pack 11,4 MB. Größte versionierte Datei `docs/stil/uebersicht_stil_stimmung.png` mit 1,5 MB, größtes Asset 0,26 MB (Kenney-Figur). LFS brächte zusätzliche Einrichtung auf jedem Rechner und in der CI sowie das GitHub-Kontingent für LFS-Speicher und -Download, aber keinen Nutzen. Neu prüfen, sobald eine einzelne Datei 10 MB überschreitet (Musik, große Texturen) oder das Pack 500 MB erreicht. Bildschirmfotos bleiben unversioniert (`docs/screenshots/`).
