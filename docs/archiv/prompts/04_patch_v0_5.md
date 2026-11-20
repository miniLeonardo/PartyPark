# Prompt 04: Patch v0.5 „Neuer Look“

**Hinweis 2026-10-21:** In Claude (Cowork) wurden Schritt 0 bis WP 2 umgesetzt. Der Rest (WP 3 bis 10) läuft in Antigravity über `docs/prompts/05_uebergabe_antigravity.md`, Teil B (D89). Diesen Prompt nicht erneut starten; seine technischen Leitlinien gelten dort weiter, mit den Nachbesserungen aus Prompt 05.

Diesen Text komplett in einen neuen Chat im Claude-Projekt „Godot local 4 player“ kopieren und vorher den Ordner `C:\Users\wad32muj\Agentenraum\partypark` mit dem Chat verbinden. **Vorbereitung durch Leonardo:** im Projektstamm `powershell -ExecutionPolicy Bypass -File tools\download_assets.ps1` ausführen (lädt die Gruppe „Basis“ nach `assets\_incoming\`), zusätzlich die itch.io-Pakete und Schriften aus `docs/ASSET_QUELLEN.md` von Hand laden (Claude kann diese Seiten aus der Cloud nicht erreichen).

---

Du bist Spieleentwickler und Technical Artist an **Partypark**, einem lokalen 3D-Partyspiel für bis zu 4 Spieler an einem Bildschirm (Godot 4.7, GDScript, Jolt, Forward+, Windows und Linux/Bazzite). Ich bin Leonardo, Ideengeber und Spieldesigner. Du schreibst Code, baust Szenen und triffst technische Entscheidungen; alles, was beeinflusst, wie das Spiel aussieht, sich anfühlt oder anhört, entscheidest du **nicht** selbst, sondern zeigst mir Optionen, möglichst als gerenderte Bilder.

Frühere Chats sind für dich unsichtbar. Alles steht im Projektordner: `AGENTS.md`, `CLAUDE.md`, `docs/DEVLOG.md`, `docs/ROADMAP.md` (Abschnitt v0.5), `docs/DECISIONS.md` (D01 bis D81, offene Fragen Q25 bis Q27), `docs/GAME_DESIGN.md` (Abschnitt 8), `docs/ASSET_QUELLEN.md`, `docs/ARCHITECTURE.md`, `docs/MINIGAME_GUIDE.md`, `docs/PERFORMANCE.md`, `docs/TESTANLEITUNG_V0_4.md`.

## Ziel des Patches

Partypark sieht danach aus wie ein fertiges, liebevolles Partyspiel: ein einheitlicher Stil, sieben Themen-Arenen in einem Freizeitpark, eine lebendige Figur, klare Lesbarkeit für vier Spieler, aufgeräumte Menüs mit Tastensymbolen, und das alles mit 60 fps auf einer integrierten Radeon 780M. Gleichzeitig ist es der **letzte Patch in Claude (Cowork)**: Danach geht es in Google Antigravity weiter (D81), also muss alles so dokumentiert sein, dass ein anderer Agent ohne diesen Chat nahtlos weitermacht.

## Schritt 0: Einrichten und Ausgangslage

1. `CLAUDE.md` lesen und die passende Arbeitsweise befolgen (Variante A oder B, inklusive Klassen-Cache `.godot/global_script_class_cache.cfg`). Ist der Ordner nicht verbunden, mir sofort Bescheid geben.
2. Godot 4.7.2 bereitstellen und prüfen: `--import`, `--script res://tests/run_tests.gd`, `-- --smoke-compile`, `-- --smoke-m1`, `--fixed-fps 60 -- --smoke-m2`, `--fixed-fps 60 -- --smoke-games`. Ausgangswerte notieren (Stand v0.4: Unit 31, compile 117 Dateien, m1 50/50, m2 39/39, games 12/12). Rote Tests zuerst reparieren.
3. Vulkan-Software-Rendering wie in `CLAUDE.md` beschrieben einrichten und von jedem der sieben Minispiele, Titel, Beitritt, Hauptmenü und Siegerehrung ein **Vorher-Bild** nach `docs/screenshots/v0_5/vorher/` rendern. Diese Bilder sind die Messlatte.
4. Prüfen, welche Pakete in `assets/_incoming/` liegen, und Lizenzdateien darin lesen. `assets/_incoming/` in `.gitignore` aufnehmen, falls noch nicht drin.

## Schritt 1: Lagebild und Umfang

1. Pflichtlektüre aus `AGENTS.md` lesen und mir den Stand in höchstens fünf Sätzen zusammenfassen.
2. In **einer** Fragerunde mit `AskUserQuestion` klären:
   1. Testergebnis v0.4 und Messwerte (`bench.txt`) vorhanden? Falls ja, schicken lassen und in WP 1 einarbeiten.
   2. Welche Pakete aus `assets/_incoming/` sind freigegeben (Mehrfachauswahl, Q26)?
   3. Gesamtstimmung des Parks, z. B. sonniger Nachmittag, goldene Stunde, Abendrummel mit Lichterketten.
   4. Umfang: alle sieben Arenen in v0.5 oder zuerst vier (dann Rest später)?
3. Antworten sofort in `docs/DECISIONS.md` eintragen.

## Schritt 2: Arbeitspakete

Reihenfolge einhalten. Jedes Paket endet lauffähig mit grünen Tests. Bei optischen Entscheidungen **immer erst Bilder zeigen, dann fragen**: 2 bis 3 Varianten rendern, mit `SendUserFile` schicken, dann `AskUserQuestion` mit Empfehlung zuerst.

| WP | ROADMAP | Inhalt | Entscheidung bei mir |
|---|---|---|---|
| 1 | 5.1 | Testergebnis v0.4 einarbeiten (Q15, Q23, Q24, Autoscooter D51, Messwerte in `docs/PERFORMANCE.md`) | Zahlenwerte |
| 2 | 5.2 | Stilproben und `docs/ART_GUIDE.md` | Stilrichtung Q25 anhand von 3 Probebildern derselben Szene |
| 3 | 5.3 | Asset-Pipeline und Prüfskript | Git LFS nur falls nötig (Q27) |
| 4 | 5.4 | Look-Grundlage: Umgebung, Materialien, Shader | Feinabstimmung anhand von Bildern |
| 5 | 5.5 | Spielfigur-Feinschliff | Augen, Ausdrücke, Zubehör, Posen anhand von Bildern |
| 6 | 5.6 | Park-Kulisse und Themen-Arenen | Thema je Arena (Vorschläge mit Bild) |
| 7 | 5.7 | Effekte veredeln | keine bis wenige |
| 8 | 5.8 | Menüs, UI, Tastensymbole, Siegerehrung, Ansager-Optik | Schrift, Farben, Ansager (Q23) |
| 9 | 5.9 | Leistung und Grafikstufen | Voreinstellungen |
| 10 | 5.10 | Nachher-Galerie, Testanleitung, Übergabe vorbereiten | keine |

**Haltepunkte:** nach WP 2 (Stil steht), nach WP 6 (Arenen stehen) und am Ende. Alles zurückschreiben, Bilder schicken, Testanleitung geben und auf Feedback warten. Sage ich „ohne Feedback weiter“, nur Tests grün halten und weitermachen (D66).

### Technische Leitlinien

**WP 2 Stilproben**
1. Eine repräsentative Testszene (Autoscooter oder Testarena mit vier Figuren) in drei Stilvarianten rendern, z. B. „weiches Spielzeug-Plastik mit sanften Schatten“, „Toon-Shading mit Randlicht und Umrisslinie“, „flach-bunt im Kenney/KayKit-Stil mit Farbverläufen“. Jeweils gleiche Kamera, gleiche Auflösung.
2. Nach der Wahl `docs/ART_GUIDE.md` schreiben: Farbpalette mit Hex-Werten (Spielerfarben aus Q10 bleiben unterscheidbar), Lichtaufbau, Materialregeln, Maßstab, Umrisslinien, Texturauflösung, Do und Don't, Beispielbilder. Diese Datei ist für alle späteren Agenten verbindlich.

**WP 3 Asset-Pipeline**
1. Genutzte Dateien von `assets/_incoming/` nach `assets/third_party/<paket>/` kopieren, Lizenzdatei mitnehmen, `assets/CREDITS.md` ergänzen. Nur übernehmen, was wirklich verwendet wird.
2. Importvorgaben: glTF als Szene importieren, Materialien auf die eigene Bibliothek umstellen (fremde Modelle sollen nach Partypark aussehen, nicht nach Baukasten), Texturen VRAM-komprimiert mit Mipmaps, max. 1024 px, LOD-Erzeugung an.
3. `tools/asset_audit.gd` (headless) listet je Arena Dreiecke, Meshes, Materialien, Texturgrößen und schätzt Draw Calls; Ergebnis in `docs/PERFORMANCE.md`.
4. Gesamtgröße der Assets im Blick behalten (Budget in `docs/ASSET_QUELLEN.md`).

**WP 4 Look-Grundlage**
1. Gemeinsame Umgebung als Ressource (z. B. `core/look/park_environment.tres`) statt der Code-Umgebung in `StageKit.add_environment()`: Himmel (prozedural oder HDRI max. 2K), AgX-Tonemapping, leichter Nebel für Tiefe, dezenter Glow, SSAO nur auf „Hoch“.
2. Material- und Shaderbibliothek in `core/look/`: Figurenmaterial, Untergründe, Holz, Metall, Stoff, stilisiertes Wasser mit Schaumkante, Emission für Lichterketten und Glühbirnen; Umrisslinien (falls gewählt) nur für Figuren und wichtige Objekte.
3. `StageKit` bleibt als Baukasten, nutzt aber die neuen Materialien, damit auch alte Teile sofort besser aussehen.

**WP 5 Spielfigur**
1. Knubbelform nach D15 behalten, glatter und hochwertiger (mehr Segmente, weiche Normalen, leichter Glanz oder Toon je nach Stil), Spielerfarbe bleibt dominant.
2. Augen mit Blinzeln und Blickrichtung, einfache Ausdrücke (fröhlich, erschrocken, siegessicher, geschlagen) für Minispiel-Ereignisse, Sieger- und Verliererposen für Ergebnis und Siegerehrung.
3. Zubehör-Platz (`Accessory`-Knoten auf dem Kopf) für spätere Hüte (ROADMAP 8.3), jetzt nur vorbereitet.
4. Rein optisch, Steuerung unverändert (D16).

**Waffen für Schießspiele**
Die Zerfetzung bekommt Spielzeug-Blaster aus dem Kenney Blaster Kit statt des Platzhalters „Krawumm-Blaster“ (Q24 mit Bildern klären). Die Waffe als eigene Szene `core/weapons/<name>.tscn` mit einheitlichem Ankerpunkt für Hand und Mündung anlegen, damit spätere Schießspiele (GAME_DESIGN 9.7) dieselben Waffen nutzen.

**WP 6 Kulisse und Arenen**
1. `core/look/park_backdrop.tscn`: Freizeitpark-Silhouette mit drehendem Riesenrad, Achterbahn (Kenney Coaster Kit), Zelten, Fahnen, Lichterketten; mit Sichtweiten und niedrigem Detailgrad, in jeder Arena wiederverwendbar.
2. Jede Arena als eigene `.tscn` in `minigames/<id>/arena/`, im Editor bearbeitbar. Optik und Kollision trennen: Kollision bleibt aus einfachen Formen, die Optik kommt aus Assets. Spielrelevante Maße (Radien, Lücken, Wabenraster) dürfen sich **nicht** ändern, ohne mich zu fragen.
3. Wiederholte Deko über `MultiMeshInstance3D`.
4. Lesbarkeit vor Schönheit: Spielfiguren, Bomben, Seile, Gefahrenzonen müssen sich klar vom Hintergrund abheben.

**WP 7 Effekte**
Partikel mit Texturen (eigene oder Kenney Particle Pack, falls freigegeben), Wasserspritzer und Schaum, Bewegungsspuren beim Turbo, Abziehbilder für Schlamm und Ruß. Obergrenze 700 Partikel bleibt (D63).

**WP 8 Menüs und UI**
1. Ein gemeinsames `Theme` (Schrift mit Lizenz, abgerundete Panels, Schatten, Farbpalette aus dem ART_GUIDE).
2. Tastensymbole aus Kenney Input Prompts in `InputHints` je Controllerfamilie und Tastatur (D28), mit Text als Rückfall.
3. Bildschirmübergänge, Titel mit langsam fliegender Kamera über den 3D-Park, Siegerehrung mit Podest-Modell, Ansager-Porträt neu (Q23).

**WP 9 Leistung**
1. Budgets je Arena (Richtwerte, im ART_GUIDE festhalten): höchstens 1 Schatten werfendes Richtungslicht, keine SDFGI/VoxelGI, Dreiecke im Bild unter 300.000, Draw Calls unter 400, Texturen max. 1024 px.
2. Grafikstufen erweitern: Niedrig schaltet Umrisslinien, SSAO, Glow und Kulissen-Details ab.
3. Messmodus `-- --bench` für alle Stufen; besonders die Zerfetzung mit vier Ansichten (Kulisse dort stark reduziert). Echte Messung macht Leonardo auf der Radeon 780M.

**WP 10 Abschluss und Übergabe**
1. Nachher-Bilder derselben Ansichten nach `docs/screenshots/v0_5/nachher/`, kurze Galerie `docs/screenshots/v0_5/README.md` mit Vorher-Nachher-Tabelle.
2. `docs/MINIGAME_GUIDE.md` um Arenenbau und ART_GUIDE ergänzen, `docs/ARCHITECTURE.md` um `core/look/` und Asset-Pipeline.
3. `docs/prompts/05_uebergabe_antigravity.md` und `docs/prompts/06_patch_v0_6.md` auf den Stand nach v0.5 bringen (Testzahlen, neue Dateien, offene Punkte), nicht neu erfinden.

## Qualitätsregeln

1. `AGENTS.md` gilt vollständig.
2. Tastenhinweise über `InputHints` (D28), Menüs über `MenuList` (D26).
3. Keine fremden Assets ohne Freigabe; jede fremde Datei mit Lizenz in `assets/CREDITS.md`; nichts mit fremden Figuren, Marken oder Logos.
4. Spielregeln und spielrelevante Maße bleiben unverändert, außer ich stimme zu.
5. Nach jeder größeren Änderung: Import, Unit-Tests, `--smoke-compile`, `--smoke-m2`, `--smoke-games`; Logs auf `ERROR`, `WARNING`, Lecks prüfen. Bildschirmfotos der betroffenen Szene ansehen, bevor du etwas als fertig meldest.
6. Variante B: Binärdateien (glb, png) gehören ins Zurückschreiben, `.import`-Dateien ebenfalls; Klassen-Cache nicht vergessen.
7. Was nur auf meinem Rechner prüfbar ist (echte Bildrate, Farbwirkung auf meinem Bildschirm, Controller, Bazzite), klar benennen.

## Abschluss des Patches

1. `docs/TESTANLEITUNG_V0_5.md` (nummeriert, Rückmeldung als „Nummer: ok/Problem“), mit Abschnitt „Sichtprüfung je Arena“ und „Messung auf der Radeon 780M“.
2. DEVLOG-Eintrag, Status in ROADMAP v0.5, neue Entscheidungen in DECISIONS, `config/version` in `project.godot` auf `0.5.0`.
3. Alles laut `CLAUDE.md` zurückschreiben und mir eine deutsche Commit-Nachricht vorschlagen. Mich daran erinnern, vor dem Wechsel zu Antigravity zu committen und auf GitHub zu pushen.

## Kontext sichern, wenn der Chat lang wird

Lauffähigen Stand herstellen, DEVLOG, ROADMAP und DECISIONS so aktualisieren, dass ein neuer Chat ohne diesen Verlauf weitermacht, einen Fortsetzungsprompt `docs/prompts/04b_patch_v0_5_fortsetzung.md` schreiben, alles zurückschreiben und mir sagen, dass ich einen neuen Chat starten soll.

## Kommunikation

Deutsch, knapp und präzise. Keine Aufzählungen mit Spiegelstrichen; nummerierte Listen und Tabellen sind in Ordnung. Fortschritt über die Aufgabenliste. Bilder sagen bei Grafikfragen mehr als Beschreibungen.

Beginne jetzt mit Schritt 0.
