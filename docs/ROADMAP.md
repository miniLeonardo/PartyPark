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

| Version | Titel | Kernidee |
|---|---|---|
| v0.4 | Spieleabend | Hörbar, spürbar, flüssig: Effekte, Sound, Ansager, Leistung, zwei neue Spiele, Bauanleitung für Minispiele |
| v0.5 | Mehr Chaos | Inhaltswelle mit sechs Spielen, Rache-Modus für Ausgeschiedene, Formatvarianten, Wiederholung des besten Moments |
| v0.6 | Der Park | Herzstück (Q01): Vorschlag „Parkrundfahrt“, ein Brettspiel auf einem begehbaren Freizeitpark |
| v0.7 | Party-Joker | Regel-Modifikatoren, Mikrospiel-Marathon, Sammelalbum mit Hüten, Saboteur-Format |
| v0.8 | Rettet den Park | Koop-Kampagne mit Bösewicht, Rätselräumen und mehrphasigem Endboss |
| v0.9 | Für alle | Zugänglichkeit, Englisch, echte Grafik und Musik, Feinschliff |
| v1.0 | Eröffnung | Release-Builds Windows und Linux, Bazzite/Steam Deck geprüft, mind. 30 Minispiele |

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

### v0.5 „Mehr Chaos“ (nächster Patch, Prompt `docs/prompts/04_patch_v0_5.md`)

Ziel: Doppelt so viele Spiele, und niemand sitzt mehr untätig herum.

| Nr | Aufgabe | Inspiration | Status |
|---|---|---|---|
| 5.1 | Rache-Modus: Ausgeschiedene schweben als Geister am Arenarand und werfen kleine Störungen (Bananenschale, Windstoß); einmal gebaut, in jedem Spiel mit Ausscheiden nutzbar | Bomberman-Rachewagen, Mario-Kart-Ballongeister | offen |
| 5.2 | Formatvarianten: vorhandene Spiele in weiteren Formaten (Autoscooter 2v2, Tauziehen als Vier-Seil-Stern FFA, Schafe hüten 2v2 als Wettstreit) | Mario Party Jamboree (Battle-, 2er-, 4er-Versionen) | offen |
| 5.3 | Sechs neue Minispiele, mindestens eins je Format, aus GAME_DESIGN Abschnitt 9 | | offen |
| 5.4 | Wiederholung des entscheidenden Moments: Ringpuffer der letzten Sekunden, andere Kameraperspektive, Zeitlupe | Sport-Wiederholungen, Rocket League | offen |
| 5.5 | Rundenstatistik und Bonustitel am Turnierende („Meiste Schubser“, „Pechvogel“, „Taktgefühl“), auf Wunsch mit Bonuspunkten | Mario-Party-Bonussterne | offen |
| 5.6 | Finale: letzte Runde doppelte Punkte, bei Gleichstand Duell im neuen Format 1 gegen 1 | Mario Party „Letzte 5 Runden“ | offen |

### v0.6 „Der Park“ (Herzstück, Q01)

Ziel: Ein Abendmodus mit Spannungsbogen, der über einzelne Minispiele hinausgeht.

| Nr | Aufgabe | Inspiration | Status |
|---|---|---|---|
| 6.1 | Q01 entscheiden. Vorschlag Hybrid „Parkrundfahrt“: Brettspiel, dessen Brett ein begehbarer Low-Poly-Freizeitpark ist (Achterbahnschienen als Wege, Attraktionen als Ereignisfelder); Tickets als Währung, Goldene Eintrittskarte als Siegpunkt | Mario Party, Nintendo Land | offen |
| 6.2 | Ereignisfelder: Wartungsarbeiten sperren Wege, Parade schiebt alle weiter, Riesenrad tauscht Plätze, Glücksrad, Fotoautomat | | offen |
| 6.3 | Gegenstände im Kiosk: Doppelwürfel, Abkürzungs-Pass, Greifarm (Ticket klauen), Regenschirm (Schutz) | Mario Party | offen |
| 6.4 | Brett-Kamera, Würfel, Zugreihenfolge, Speichern und Fortsetzen eines Abends | | offen |
| 6.5 | Regelvarianten: Schnelle Runde (10 Züge), Tag-Team (2er-Teams teilen Tickets) | Jamboree TV (Frenzy, Tag-Team) | offen |

### v0.7 „Party-Joker“

Ziel: Kein Abend gleicht dem anderen.

| Nr | Aufgabe | Inspiration | Status |
|---|---|---|---|
| 7.1 | Joker-Karten: Vor jeder Runde wählt der Letztplatzierte 1 aus 3 Karten, die die Regeln ändern (Mondschwerkraft, Riesenköpfe, Spiegelsteuerung, Seifenboden, Nebel, doppelte Punkte). Technisch als Modifikatoren auf Figur, Physik und Kamera | Balatro, Hades-Segen, Baba Is You | offen |
| 7.2 | Mikrospiel-Marathon: Serien aus 3-Sekunden-Spielen mit einem Befehlswort („Duck dich!“, „Fang!“), immer schneller; Gerüst, in das Dutzende winzige Spiele passen | WarioWare | offen |
| 7.3 | Sammelalbum: Tickets aus Spielen schalten Hüte, Brillen und Sticker frei; Figur im Beitritt anpassen | Fall Guys | offen |
| 7.4 | Lokale Rekorde und Bestenliste je Minispiel, Solo-Übungsmodus | | offen |
| 7.5 | Saboteur-Format: Koop-Aufgabe mit geheimem Saboteur, Rolle wird nur per Vibrationsmuster mitgeteilt, am Ende Abstimmung | Among Us | offen |

### v0.8 „Rettet den Park“ (Koop-Kampagne)

| Nr | Aufgabe | Inspiration | Status |
|---|---|---|---|
| 8.1 | Geschichte: Ein grauer Direktor will den Park in ein Parkhaus verwandeln; 5 Kapitel aus Koop-Spielen, Zwischenszenen mit Brabbelstimme | | offen |
| 8.2 | Rätselräume, die nur mit allen vier lösbar sind (Druckplatten, Räuberleiter, gemeinsames Tragen) | Pico Park | offen |
| 8.3 | Mehrphasiger Endboss (Ausbau des Staubsauger-Bosses), Wiederbelebung, Rücksetzpunkte, Schwierigkeitsgrade | | offen |

### v0.9 „Für alle“

| Nr | Aufgabe | Status |
|---|---|---|
| 9.1 | Tastenbelegung frei änderbar, „Halten statt Hämmern“, Spieltempo 80 % | offen |
| 9.2 | Farbsehschwäche: Formen und Muster zusätzlich zu Farben (Hüte, Ringmuster) | offen |
| 9.3 | Englisch als zweite Sprache (Übersetzungs-CSV) | offen |
| 9.4 | Echte Grafik und Musik: Low-Poly-Pakete (D17) plus eigener Toon-Shader, Musik pro Spielart | offen |
| 9.5 | Kurzer Einführungs-Spaziergang für neue Spieler | offen |

### v1.0 „Eröffnung“

| Nr | Aufgabe | Status |
|---|---|---|
| 10.1 | Release-Builds Windows und Linux, Bazzite und Steam Deck geprüft, 60 fps auf Radeon 780M | offen |
| 10.2 | Veröffentlichungsweg klären (privat, itch.io oder Steam, Q20); über Steam wäre „Remote Play Together“ für Online-Abende ohne eigenen Netzcode möglich | offen |
| 10.3 | Umfang: mindestens 30 Minispiele, 3 Spielarten, Kampagne | offen |
