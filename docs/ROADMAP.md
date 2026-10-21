# Partypark: Roadmap

Status: **offen**, **in Arbeit**, **erledigt**, **verschoben**. Beim Abschluss eines Meilensteins Datum und Kurznotiz eintragen.

Phasen 0 bis 3 sind die Prototyp-Historie (zusammen Version 0.1 bis 0.3). Ab Version 0.4 gilt der Versionsplan weiter unten. Alle Inhalte des Versionsplans sind **Vorschläge**: Jede Spielidee und jede spielrelevante Funktion wird vor der Umsetzung mit Leonardo abgestimmt (D08).

## Phase 0: Einrichtung

| Nr | Aufgabe | Status | Notiz |
|---|---|---|---|
| 0.1 | Projektverzeichnis, Godot-Projekt, Git, Doku für KI-Übergabe | erledigt | 2026-10-19, Claude (Cowork) |
| 0.2 | Godot 4.6.x bei Leonardo installiert (Windows und Bazzite) | offen | |
| 0.3 | 4 Controller unter Windows und Bazzite erkannt (Godot Joypad-Demo oder Prototyp) | offen | |

## Phase 1: Prototyp, Meilenstein M1 „Kern“

| Nr | Aufgabe | Status |
|---|---|---|
| 1.1 | `InputRouter` mit `GamepadInput`, `KeyboardInput` (Debug), Verbindungsabbruch | erledigt (2026-10-19, headless und Smoke-Test grün, Controllertest offen) |
| 1.2 | `PlayerRoster`, Spielerfarben | erledigt (2026-10-19, headless und Smoke-Test grün, Controllertest offen) |
| 1.3 | Beitrittsbildschirm „Drücke A zum Mitspielen“ | erledigt (2026-10-19, headless und Smoke-Test grün, Controllertest offen) |
| 1.4 | Spielfigur: Laufen, Springen, Schubsen | erledigt (2026-10-19, headless und Smoke-Test grün, Controllertest offen) |
| 1.5 | Testarena mit `ArenaCamera` für 4 Spieler | erledigt (2026-10-19, headless und Smoke-Test grün, Controllertest offen) |
| 1.6 | Pause-Menü | erledigt (2026-10-19, headless und Smoke-Test grün, Controllertest offen) |
| 1.7 | Testanleitung für Leonardo, Test bestanden | erledigt (2026-10-19, Leonardo: „klappt alles“, Windows, Godot 4.7, vor allem Tastatur) |

## Phase 2: Prototyp, Meilenstein M2 „Minispiel-Framework“

| Nr | Aufgabe | Status |
|---|---|---|
| 2.1 | `TeamFormat`, `MinigameInfo`, `MinigameRegistry` | erledigt (2026-10-19) |
| 2.2 | `Minigame`-Basisklasse, `MinigameContext`, `MinigameResult` | erledigt (2026-10-19) |
| 2.3 | `MatchFlow`: Ankündigung, Regeln mit Bereit (ohne Übung, D33), Countdown, Zeitlupe, Ergebnis | erledigt (2026-10-19) |
| 2.4 | `TeamAssigner` mit Tests | erledigt (2026-10-19) |
| 2.5 | Schnellturnier mit Punktestand und Siegerehrung | erledigt (2026-10-19) |
| 2.6 | Testläufer `tests/run_tests.gd` | erledigt (2026-10-19) |

## Phase 3: Prototyp, Meilenstein M3 „Vertical Slice“

| Nr | Aufgabe | Status |
|---|---|---|
| 3.1 | Minispiel FFA: Autoscooter `bumper_cars` (D30, D34) | erledigt (2026-10-19, Smoke-Test grün, Controllertest offen) |
| 3.2 | Minispiel 2v2: Tauziehen `tug_of_war` (D35) | erledigt (2026-10-19, Smoke-Test grün, Controllertest offen) |
| 3.3 | Minispiel 1v3: Riese gegen Zwerge `giant_vs_dwarfs` (D36) | erledigt (2026-10-19, Smoke-Test grün, Controllertest offen) |
| 3.4 | Minispiel 4vCPU: Schafe hüten `sheep_herding` (D37) | erledigt (2026-10-19, Smoke-Test grün, Controllertest offen) |
| 3.5 | Einfache Computergegner über `AIInput`, Stärke einstellbar (D38, D45) | erledigt (2026-10-19) |
| 3.6 | Erster gemeinsamer Spieleabend als Test, Feedback im DEVLOG | teilweise (2026-10-20 kurz angespielt, Q22; voller Test mit Controllern offen) |

## Zwischenschritt: Menüs (2026-10-19 vorgezogen)

| Nr | Aufgabe | Status |
|---|---|---|
| M.1 | Titelbildschirm, Hauptmenü, Optionen (D29, D39) | erledigt (2026-10-19) |
| M.2 | Freies Spiel mit Teamwahl (D40) | erledigt (2026-10-19) |

## Versionsplan v0.4 bis v1.0 (Vorschlag, Stand 2026-10-20)

### Leitplanken

1. **Mischprinzip:** Jeder Patch bringt neue Inhalte (Minispiele, Modi) und mehr Qualität (Gefühl, Technik). Kein Patch ist nur Technik.
2. **Immer spielbar:** Jeder Patch endet mit grünen Tests, einer Testanleitung und einem Spieleabend-tauglichen Stand.
3. **Leistungsbudget:** 60 fps mit 4 Spielern auf einer integrierten Radeon 780M (GAME_DESIGN Abschnitt 8). Jedes neue Minispiel wird gemessen.
4. **Ein Baukasten, viele Spiele:** Gemeinsame Bausteine (Figur, Fähigkeiten, StageKit, Effekte, Sound, KI) wachsen mit, damit ein neues Minispiel in einer Sitzung entsteht.
5. **Inspiration ausdrücklich erwünscht:** Ideen aus Partyspielen (Mario Party, WarioWare, Fall Guys, Bomberman, Overcooked, Pico Park, Ultimate Chicken Horse) und aus ganz anderen Spielen (Balatro, Hades, Katamari, Baba Is You, Among Us, Unrailed!). Nie Figuren, Namen, Grafiken oder Musik übernehmen, nur Mechanik-Ideen.

### Übersicht

Umgestellt am 2026-10-21 (D80, D81): v0.5 setzt den Schwerpunkt auf Grafik; die bisherigen Inhalte rücken je eine Version nach. Ab v0.6 wird in Google Antigravity weitergearbeitet.

| Version | Titel | Kernidee | Umgebung |
|---|---|---|---|
| v0.4 | Spieleabend | Hörbar, spürbar, flüssig: Effekte, Sound, Ansager, Leistung, drei neue Spiele, Bauanleitung für Minispiele | Claude (Cowork), umgesetzt |
| v0.5 | Neuer Look | Grafik im Fokus: Stilrichtung, freie CC0-Assets und eigene Modelle, Themen-Arenen, Park-Kulisse, Figur, Waffen, Licht, Materialien, UI mit Tastensymbolen, Leistung | Claude (Cowork) bis WP 2, Rest in Antigravity (D89) |
| v0.6 | Mehr Chaos | Sechs neue Spiele, Rache-Modus für Ausgeschiedene, Formatvarianten, Wiederholung des besten Moments, Bonustitel, Finale | Antigravity |
| v0.7 | Der Park | Herzstück (Q01): Vorschlag „Parkrundfahrt“, ein Brettspiel auf einem begehbaren Freizeitpark | Antigravity |
| v0.8 | Party-Joker | Regel-Modifikatoren, Mikrospiel-Marathon, Sammelalbum mit Hüten, Saboteur-Format | Antigravity |
| v0.9 | Rettet den Park, Für alle | Koop-Kampagne, Zugänglichkeit, Englisch, Musik, Feinschliff | Antigravity |
| v1.0 | Eröffnung | Release-Builds Windows und Linux, Bazzite/Steam Deck geprüft, mind. 30 Minispiele | Antigravity |

### v0.4 „Spieleabend“ (umgesetzt 2026-10-20, Prompt `docs/prompts/03_patch_v0_4.md`, Versionsplan bestätigt D47; Tests bei Leonardo offen)

Ziel: Das Spiel fühlt sich an einem echten Abend wie ein fertiges Partyspiel an.

| Nr | Aufgabe | Inspiration | Status |
|---|---|---|---|
| 4.1 | Spieleabend-Feedback (ROADMAP 3.6) einarbeiten, Balance Q15, Teampunkte Q13, Teamfarben Q14 | | erledigt (2026-10-20: Seile sichtbar D52, Tauziehen mit Kraftakt D53, Computer-Zwerge D58, Q13/Q14 bleiben; Autoscooter wartet auf Controllertest D51) |
| 4.2 | Effekt-Baukasten `core/fx/`: Kamera-Wackeln über Trauma-Wert, Hitstop, Partikel-Vorlagen (Staub, Platscher, Konfetti, Sterne), Squash-Impulse an der Figur; in alle vorhandenen Minispiele einbauen | „The Art of Screenshake“, Nintendo-Feedback | erledigt (2026-10-20, D55, D56, D63; Hörtest/Sichttest bei Leonardo offen) |
| 4.3 | Sound-Grundgerüst: Busse Musik/Effekte/Stimme, Autoload `Sfx` mit Stimmen-Pool und Tonhöhen-Streuung, Lautstärke in den Optionen; Effekt-Generator `tools/sfx_gen.gd` nach dem sfxr-Prinzip erzeugt eigene `.wav` (keine Lizenzfrage) | sfxr/jsfxr | erledigt (2026-10-20, D59 bis D62, D65; 42 Geräusche, Hörtest bei Leonardo offen) |
| 4.4 | Ansager mit „Brabbelstimme“: Sprechblasen mit silbenweisem Geplapper für Ankündigung, Countdown, Sieg, Pech; Spruchlisten pro Ereignis | Animal Crossing, Wii-Party-Moderator | erledigt (2026-10-20, D67, D68: trockener Kommentator „Hodenhüpfer“, 8 Ereignisse, Spruchliste `core/announcer/announcer_lines.json`) |
| 4.5 | Leistung: FPS- und Frametime-Anzeige (Debug), Grafikoption Niedrig/Mittel/Hoch (Schatten, MSAA, 3D-Auflösung mit FSR), Messprotokoll je Minispiel in `docs/PERFORMANCE.md` | | erledigt (2026-10-20, D69: Grafikstufen, Leistungsanzeige F3/Option, Messmodus `-- --bench`; Messung auf Radeon 780M offen) |
| 4.6 | Zwei neue Minispiele aus der Schnellbau-Liste (GAME_DESIGN 9.5) | Bomberman, Fall Guys | erledigt (2026-10-20: Wackelwaben D70/D73, Heiße Kartoffel D71, zusätzlich Zerfetzung mit Splitscreen D72/D49) |
| 4.7 | Bauanleitung `docs/MINIGAME_GUIDE.md` und Gerüst-Skript `tools/new_minigame.gd` (legt Ordner, info.tres, Skript, Szene, Registry-Test an) | | erledigt (2026-10-20: `docs/MINIGAME_GUIDE.md`, `tools/new_minigame.gd` mit Test) |
| 4.8 | Aufräumen: leere `.gitkeep`, Hinweise zum Klassen-Cache; Q09 klären, bei Zustimmung GitHub-Repository und automatische Tests per GitHub Actions | | erledigt (2026-10-20: Q09 → GitHub privat mit Actions D74, Vorlage `tools/ci/tests.yml` D79; .gitkeep-Liste für Leonardo im DEVLOG) |
| 4.9 | Export-Vorlagen Windows und Linux (`export_presets.cfg`), erster Test auf Bazzite | | teilweise (2026-10-20: `export_presets.cfg` Windows und Linux, in der Cloud exportiert und gestartet; Test auf Bazzite offen, Anleitung `docs/EXPORT_UND_BAZZITE.md`) |

### v0.5 „Neuer Look“ (in Arbeit seit 2026-10-21; WP 1 und 2 mit `docs/prompts/04_patch_v0_5.md` in Claude, Rest ab WP 3 in Antigravity mit `docs/prompts/05_uebergabe_antigravity.md` Teil B, D89)

Ziel: Partypark sieht aus wie ein fertiges, liebevolles Partyspiel: einheitlicher Stil, Themen-Arenen in einem Freizeitpark, lebendige Figur, gute Lesbarkeit für vier Spieler, 60 fps auf der Radeon 780M. Asset-Quellen und Lizenzen in `docs/ASSET_QUELLEN.md`.

| Nr | Aufgabe | Status |
|---|---|---|
| 5.1 | Testergebnis v0.4 einarbeiten (Q15, Q23, Q24, Autoscooter D51, Messwerte `bench.txt`) | verschoben (2026-10-21, D82: kein Testergebnis; Punkte wandern in `TESTANLEITUNG_V0_5.md`, Messtabelle vorbereitet) |
| 5.2 | Stilrichtung (Q25) anhand gerenderter Stilproben festlegen: Licht, Farbpalette, Materialien, Umrisslinien ja/nein; Ergebnis als `docs/ART_GUIDE.md` | erledigt (2026-10-21: Spielzeug-Plastik ohne Umriss D85, Tagesverlauf D86, `docs/ART_GUIDE.md`) |
| 5.3 | Asset-Pipeline: `assets/third_party/<paket>/` mit Lizenzdatei, Importvorgaben, Prüfskript `tools/asset_audit.gd` (Dreiecke, Texturgrößen, Draw Calls je Szene), CREDITS, Größenbudget und Entscheidung zu Git LFS | in Arbeit (Prüfskript und erstes Paket da) |
| 5.4 | Look-Grundlage: gemeinsame Umgebung (Himmel, AgX-Tonemapping, Nebel, dezenter Glow), Material- und Shaderbibliothek (Toon mit Randlicht, stilisiertes Wasser, Emission für Lichterketten), Grafikstufen erweitert | offen |
| 5.5 | Spielfigur-Feinschliff im Stil von D15: glattere Form, neues Material, Blinzeln, Gesichtsausdrücke, Zubehör-Platz für Hüte, Sieger- und Verliererposen | offen |
| 5.5a | Waffen für Schießspiele: Spielzeug-Blaster aus dem Kenney Blaster Kit als Szenen in `core/weapons/`, Einbau in die Zerfetzung, Q24 | offen |
| 5.6 | Sieben Themen-Arenen als bearbeitbare `.tscn` (Optik getrennt von einfacher Kollision), gemeinsame Park-Kulisse mit Riesenrad, Achterbahn, Zelten und Lichterketten | offen |
| 5.7 | Effekte veredeln: Partikeltexturen, stilisiertes Wasser mit Schaum, Spuren, Abziehbilder (Schlamm, Ruß), Licht-Akzente | offen |
| 5.8 | Menüs und UI: Schrift, einheitliches Theme, Tastensymbole statt Text (Kenney Input Prompts) mit Textrückfall, Übergänge, Titel mit 3D-Park, Siegerehrung mit Podest, Ansager-Optik (Q23) | offen |
| 5.9 | Leistung: Budgets, LOD und Sichtweiten, MultiMesh für Deko, Messung aller Stufen und des Splitscreen-Spiels | offen |
| 5.10 | Vorher-Nachher-Galerie `docs/screenshots/v0_5/`, Testanleitung, Übergabe an Antigravity vorbereiten | offen |

### v0.6 „Mehr Chaos“ (erster Patch in Antigravity, Prompts `docs/prompts/05_uebergabe_antigravity.md` und `06_patch_v0_6.md`)

Ziel: Doppelt so viele Spiele, und niemand sitzt mehr untätig herum.

| Nr | Aufgabe | Inspiration | Status |
|---|---|---|---|
| 6.0 | Übergabe: Antigravity einrichten, Tests unter Windows, Arbeitsweise in `AGENTS.md` umstellen (findet schon vor dem Rest von v0.5 statt, Prompt 05 Teil A) | | erledigt (2026-10-21, Antigravity als Hauptumgebung eingerichtet, alle Tests grün, Skills und Windows-Befehle da) |
| 6.1 | Rache-Modus: Ausgeschiedene schweben als Geister am Arenarand und werfen kleine Störungen (Bananenschale, Windstoß); einmal gebaut, in jedem Spiel mit Ausscheiden nutzbar | Bomberman-Rachewagen, Mario-Kart-Ballongeister | in Arbeit (Plan vorgelegt, D92) |
| 6.2 | Formatvarianten: vorhandene Spiele in weiteren Formaten (Autoscooter 2v2, Tauziehen als Vier-Seil-Stern FFA, Schafe hüten 2v2 als Wettstreit) | Mario Party Jamboree (Battle-, 2er-, 4er-Versionen) | offen |
| 6.3 | Sechs neue Minispiele, mindestens eins je Format, aus GAME_DESIGN Abschnitt 9, gebaut nach `docs/ART_GUIDE.md` | | offen |
| 6.4 | Wiederholung des entscheidenden Moments: Ringpuffer der letzten Sekunden, andere Kameraperspektive, Zeitlupe | Sport-Wiederholungen, Rocket League | offen |
| 6.5 | Rundenstatistik und Bonustitel am Turnierende („Meiste Schubser“, „Pechvogel“, „Taktgefühl“), auf Wunsch mit Bonuspunkten | Mario-Party-Bonussterne | offen |
| 6.6 | Finale: letzte Runde doppelte Punkte, bei Gleichstand Duell im neuen Format 1 gegen 1 | Mario Party „Letzte 5 Runden“ | offen |

### v0.7 „Der Park“ (Herzstück, Q01 entschieden D98)

Ziel: Ein interaktives 3D-Lobby-Areal im Freizeitpark, das als nahtlose Brücke zwischen den Minispielen dient. Voller Bewegungsspaß, Platforming-Spielereien und einem fordernden Jump'n'Run. Baut auf der Park-Kulisse aus v0.5 auf.

| Nr | Aufgabe | Inspiration | Status |
|---|---|---|---|
| 7.1 | Q01 entschieden (D98): 3D-Freizeitpark-Lobby als interaktiver Hub zwischen Minispielen statt Brettspiel | Mario 64 Schlossgarten, Nintendo Land Plaza, Fall Guys Lobby | erledigt (2026-10-21, WP 1: 3D-Gelände modes/hub/, Plaza, Sternwege, Kulisse, Schnellstart --hub, smoke-hub grün) |
| 7.2 | Bewegungs- & Platforming-Spielplatz: Trampoline, Rutschen, bewegliche Hindernisse, Rempler-Zonen | Fall Guys, A Hat in Time | erledigt (2026-10-21, WP 2: Trampoline D103, Rutschen D104, Karussell D105, Wippen & Plattformen D106 in modes/hub/playground/) |
| 7.3 | Forderndes Jump'n'Run (Parkour / Turm): Knifflige Sprungpassagen mit Belohnung an der Spitze (Aussichtspunkt, Krone, Sound) | Mario Sunshine Klettergerüste, Roblox Obby | erledigt (2026-10-21, WP 3: Kletterturm modes/hub/tower/, 3 Passagen, Sicherheitsnetze D107, Siegerkrone mit Bogenflug D108, Konfetti-Buzzer, Haltepunkt 1 erreicht) |
| 7.4 | Minispiel-Stationen: Attraktionen im Park mit Anmelde-Podesten („Drücke A für Start“); Turniermodus führt von Station zu Station | Mario Party Hub, Nintendo Land | erledigt (2026-10-21, WP 4: Attraktions-Boulevard, Minispiel-Buden D109, Turnier-Pavillon D110, Ready-Pads mit 3s-Countdown D111, Wegweiser D112) |
| 7.5 | Dynamische Großraum-Kamera für bis zu 4 Spieler (Zoom-Limits, Offscreen-Indikatoren D113, Turm-Neigung D114) | Super Smash Bros, Mario 3D World | erledigt (2026-10-21, WP 5: HubCamera modes/hub/hub_camera.gd, Höhen-Lerp 48°->38°, 2D-Indikatoren mit Distanz, Haltepunkt 2 erreicht) |
| 7.6 | Parkbesucher & Rummelplatz-Atmosphäre: Kenney Mini Characters am Wegrand, Lichterketten-Beleuchtung, Park-Geräusche | RollerCoaster Tycoon, Theme Park World | erledigt (2026-10-21, WP 6: Parkbesucher D115 modes/hub/crowd/park_visitor.gd, pulsierende Lichterketten D116 hub_string_lights.gd, zonenabhängiges Ambiente D117 hub_ambiance.gd, neue SFX cheer/bell/breeze) |
| 7.7 | Übergänge & MatchFlow: Nahtloser Wechsel zwischen Lobby und Minispielen mit Rückkehr in den Park, Menü-Einbindung | Nintendo Land, Fall Guys | erledigt (2026-10-21, WP 7: Hauptmenü-Eintrag Freizeitpark, Pavillon-Rückkehr in den Park nach Turniersiegerehrung) |
| 7.8 | Polishing, Testanleitung v0.7, Build & Export der `.exe` über partypark-patch-abschluss | | in Arbeit |

### v0.8 „Party-Joker“

Ziel: Kein Abend gleicht dem anderen.

| Nr | Aufgabe | Inspiration | Status |
|---|---|---|---|
| 8.1 | Joker-Karten: Vor jeder Runde wählt der Letztplatzierte 1 aus 3 Karten, die die Regeln ändern (Mondschwerkraft, Riesenköpfe, Spiegelsteuerung, Seifenboden, Nebel, doppelte Punkte). Technisch als Modifikatoren auf Figur, Physik und Kamera | Balatro, Hades-Segen, Baba Is You | offen |
| 8.2 | Mikrospiel-Marathon: Serien aus 3-Sekunden-Spielen mit einem Befehlswort („Duck dich!“, „Fang!“), immer schneller; Gerüst, in das Dutzende winzige Spiele passen | WarioWare | offen |
| 8.3 | Sammelalbum: Tickets aus Spielen schalten Hüte, Brillen und Sticker frei; Figur im Beitritt anpassen (nutzt den Zubehör-Platz aus 5.5) | Fall Guys | offen |
| 8.4 | Lokale Rekorde und Bestenliste je Minispiel, Solo-Übungsmodus | | offen |
| 8.5 | Saboteur-Format: Koop-Aufgabe mit geheimem Saboteur, Rolle wird nur per Vibrationsmuster mitgeteilt, am Ende Abstimmung | Among Us | offen |

### v0.9 „Rettet den Park“ und „Für alle“

| Nr | Aufgabe | Inspiration | Status |
|---|---|---|---|
| 9.1 | Geschichte: Ein grauer Direktor will den Park in ein Parkhaus verwandeln; 5 Kapitel aus Koop-Spielen, Zwischenszenen mit Brabbelstimme | | offen |
| 9.2 | Rätselräume, die nur mit allen vier lösbar sind (Druckplatten, Räuberleiter, gemeinsames Tragen) | Pico Park | offen |
| 9.3 | Mehrphasiger Endboss (Ausbau des Staubsauger-Bosses), Wiederbelebung, Rücksetzpunkte, Schwierigkeitsgrade | | offen |
| 9.4 | Tastenbelegung frei änderbar, „Halten statt Hämmern“, Spieltempo 80 % | | offen |
| 9.5 | Farbsehschwäche: Formen und Muster zusätzlich zu Farben (Hüte, Ringmuster) | | offen |
| 9.6 | Englisch als zweite Sprache (Übersetzungs-CSV) | | offen |
| 9.7 | Musik pro Spielart (selbst erzeugt oder CC0) | | offen |
| 9.8 | Kurzer Einführungs-Spaziergang für neue Spieler | | offen |

### v1.0 „Eröffnung“

| Nr | Aufgabe | Status |
|---|---|---|
| 10.1 | Release-Builds Windows und Linux, Bazzite und Steam Deck geprüft, 60 fps auf Radeon 780M | offen |
| 10.2 | Veröffentlichungsweg klären (privat, itch.io oder Steam, Q20); über Steam wäre „Remote Play Together“ für Online-Abende ohne eigenen Netzcode möglich | offen |
| 10.3 | Umfang: mindestens 30 Minispiele, 3 Spielarten, Kampagne | offen |
