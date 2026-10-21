# Partypark: Entwicklungstagebuch

Neueste Einträge **oben**. Jeder Eintrag folgt dieser Vorlage, damit eine andere KI ohne Chatverlauf weitermachen kann:

```
## JJJJ-MM-TT: Kurztitel
Agent und Umgebung: z. B. Claude (Cowork) / Gemini (Antigravity) / Leonardo
Erledigt: …
Entscheidungen: Verweise auf Dxx / Qxx
Getestet: was, wie, Ergebnis
Probleme / Bekannte Fehler: …
Nächster Schritt: eine konkrete Aufgabe aus ROADMAP.md
Aktuelle Kopie liegt in: Claude-Projekt / Git-Repo / PC von Leonardo
```

## 2026-10-21: Patch v0.7 „Der Park“ – WP 6 abgeschlossen

Agent und Umgebung: Gemini (Antigravity), Windows x86_64 lokal
Erledigt: Fragerunde zu Besucher-Verhalten, Lichterketten-Dynamik und Audio-Atmosphäre durchgeführt und Entscheidungen D115 bis D117 in `docs/DECISIONS.md` festgehalten (D115: lebendige Zuschauer mit Idle-Animationen und freudiger Jubel-/Hüpf-Reaktion bei Spielernähe; D116: dynamisch pulsierende Lichterketten mit Verstärkung am Abend; D117: zonenabhängiges Park-Ambiente mit Murmeln, Rummel-Glocken und Turmwind). Kenney Mini Characters aus `assets/_incoming/` nach `assets/third_party/kenney_mini-characters/` übernommen und in `assets/CREDITS.md` eingetragen. Komponenten `ParkVisitor` (`modes/hub/crowd/park_visitor.gd`), `HubStringLights` (`modes/hub/crowd/hub_string_lights.gd`) und `HubAmbiance` (`modes/hub/crowd/hub_ambiance.gd`) implementiert. Neue Soundrezepte `cheer`, `bell`, `breeze` in `tools/sfx_recipes.gd` ergänzt und per `tools/sfx_gen.gd` erzeugt. 30 Parkbesucher an strategischen Orten (Plaza, Buden, Karussell, Spielplatz, Turm) platziert. Smoke-Test `tests/smoke/hub_smoke.gd` um Besucher-Reaktion, Lichterketten und Audio-Ambiente erweitert (58/58 bestanden).
Entscheidungen: D115, D116, D117
Getestet: Unit-Tests 31/31; compile_smoke 148/0; smoke-hub 58/58; asset_audit erfolgreich (360k Tris, 1360 Draw Calls).
Probleme / Bekannte Fehler: keine.
Nächster Schritt: WP 7 (Übergänge & MatchFlow: Nahtloser Wechsel zwischen Lobby und Minispielen, Menü-Einbindung).
Aktuelle Kopie liegt in: Git-Repo `https://github.com/sudoMrMCaffe/PartyPark.git` und lokal in `c:\Users\VM\Desktop\PartyPark`


## 2026-10-21: Patch v0.7 „Der Park“ – WP 5 & Haltepunkt 2 erreicht

Agent und Umgebung: Gemini (Antigravity), Windows x86_64 lokal
Erledigt: Fragerunde zu Kameraführung, Zoom-Grenzen und Neigung durchgeführt und Entscheidungen D113 und D114 in `docs/DECISIONS.md` festgehalten (D113: Zoom-Clamp bei max. 46 m mit farbigen Offscreen-Indikatoren inklusive Distanzanzeige; D114: Dynamische Turm-Neigung von 48° am Boden auf bis zu 38° bei Kletterhöhe). Implementierungsplan für WP 5 vorgelegt. WP 5 (ROADMAP 7.5) umgesetzt: `HubCamera` in `modes/hub/hub_camera.gd` mit Neigungs-Lerp und 2D-Overlay (`CanvasLayer`) für Pfeil-Indikatoren in Spielerfarben erweitert. Haltepunkt 2 erreicht: Kompletter Zyklus (Lobby → Minispiel über Ready-Pad → Minispiel spielen → Rückkehr in die Lobby mit Reaktivierung aller Spieler) nahtlos spielbar und im Smoke-Test verifiziert.
Entscheidungen: D113, D114
Getestet: Unit-Tests 31/31; compile_smoke 145/0; smoke-hub 52/52 (inkl. Höhen-Neigungstest, Offscreen-Pfeil und MatchFlow-Zyklus); smoke-m1 50/50; smoke-m2 39/39; smoke-games 12/12; asset_audit erfolgreich.
Probleme / Bekannte Fehler: keine.
Nächster Schritt: WP 6 (Parkbesucher & Atmosphäre: Kenney Mini Characters, Lichterketten-Beleuchtung, Park-Geräusche).
Aktuelle Kopie liegt in: Git-Repo `https://github.com/sudoMrMCaffe/PartyPark.git` und lokal in `c:\Users\VM\Desktop\PartyPark`


## 2026-10-21: Patch v0.7 „Der Park“ – WP 4 abgeschlossen

Agent und Umgebung: Gemini (Antigravity), Windows x86_64 lokal
Erledigt: Fragerunde zu Stations-Optik, Turnier-Pavillon, Ready-Countdown und Wegweisern durchgeführt und Entscheidungen D109 bis D112 in `docs/DECISIONS.md` festgehalten (D109: bunte Kirmes-Buden mit Themenwimpel, Namensschild und leuchtender Bodenplatte; D110: prachtvoller Turnier-Pavillon am Kopf des Süd-Boulevards mit Rundenzahl-Umschaltung; D111: 3-Sekunden-Countdown mit Tonsignalen bei Vollzähligkeit, Abbruch beim Verlassen; D112: Holz-Wegweiserpfähle an Wegkreuzungen). Implementierungsplan für WP 4 vorgelegt. WP 4 (ROADMAP 7.4) umgesetzt: Komponenten in `modes/hub/stations/` (`activation_pad.gd`, `minigame_station.gd`, `tournament_pavilion.gd`, `signpost.gd`). Attraktions-Boulevard auf der Süd-Plaza errichtet mit 7 Minispiel-Buden, dem großen Turnier-Pavillon und 4 Wegweiserpfählen auf der Plaza. Signalverknüpfung in `Hub` (`play_minigame`, `start_tournament_from_hub`) integriert. Smoke-Test `tests/smoke/hub_smoke.gd` um Stations-, Pavillon- und Countdown-Prüfungen erweitert (45/45 bestanden).
Entscheidungen: D109, D110, D111, D112
Getestet: Unit-Tests 31/31; compile_smoke 145/0; smoke-hub 45/45; smoke-m1 50/50; smoke-m2 39/39; asset_audit erfolgreich.
Probleme / Bekannte Fehler: keine.
Nächster Schritt: WP 5 (Dynamische Kamera für bis zu 4 Spieler im großen Areal, Haltepunkt 2).
Aktuelle Kopie liegt in: Git-Repo `https://github.com/sudoMrMCaffe/PartyPark.git` und lokal in `c:\Users\VM\Desktop\PartyPark`


## 2026-10-21: Patch v0.7 „Der Park“ – WP 3 & Haltepunkt 1 erreicht

Agent und Umgebung: Gemini (Antigravity), Windows x86_64 lokal
Erledigt: Fragerunde zu Kletterturm-Schwierigkeit und Kronen-Mechanik durchgeführt und Entscheidungen D107 und D108 in `docs/DECISIONS.md` festgehalten (D107: knackiger Parkour mit Sicherheitsnetzen alle 6 Höhenmeter; D108: Siegerkrone schwebt auf der Spitze und springt bei Schubsern als Physik-Item mit weitem Bogenflug ab). Implementierungsplan für WP 3 vorgelegt. WP 3 (ROADMAP 7.3) umgesetzt: Kletterturm in `modes/hub/tower/` (`tower.gd`, `crown.gd`, `confetti_buzzer.gd`) mit 20 Metern Höhe am Ende des Nord-Boulevards errichtet. 3 Passagen (Spiral-Holzbalken mit Trampolin, rotierende Drehkreuze mit Schwebestufen, dünne Balancier-Pfähle mit Launchpad), 2 Zwischen-Plattformen mit Auffangnetzen, Aussichtsplattform mit Baldachin-Dach, schwebender Siegerkrone und großem Konfetti-Buzzer. Haltepunkt 1 erreicht: 5 Screenshots in 1280x720 Forward+ gerendert (`docs/screenshots/v0_7/hub/`), Schnellstart über `.\Godot_v4.7.2-stable_win64_console.exe --hub` bereit für Leonardos Probesprung.
Entscheidungen: D107, D108
Getestet: Unit-Tests 31/31; compile_smoke 141/0; smoke-hub 37/37 (inkl. Kronenraub, Physikflug und Buzzer-Test); smoke-m1 50/50; smoke-m2 39/39; 5 Screenshots erfolgreich gerendert; asset_audit erfolgreich.
Probleme / Bekannte Fehler: keine.
Nächster Schritt: WP 4 (Attraktions-Portale & Minispiel-Einstieg: Stationen für alle Minispiele, Schnellturnier-Bude, Aktivierungs-Zonen nach D101).
Aktuelle Kopie liegt in: Git-Repo `https://github.com/sudoMrMCaffe/PartyPark.git` und lokal in `c:\Users\VM\Desktop\PartyPark`


## 2026-10-21: Patch v0.7 „Der Park“ – WP 2 abgeschlossen

Agent und Umgebung: Gemini (Antigravity), Windows x86_64 lokal
Erledigt: Fragerunde zu Spielplatz- und Physikmechaniken durchgeführt und Entscheidungen D103 bis D106 in `docs/DECISIONS.md` festgehalten (D103: dynamisches Federn nach Fallhöhe; D104: Null-Reibungs-Gleitfläche mit Trägheitslenkung und Schanze; D105: Karussell mit kontinuierlicher Rotation und Zentrifugalkraft; D106: Plattform-Mix aus Wippen, Schwebeliften und horizontalen Pendeln). Implementierungsplan für WP 2 vorgelegt. WP 2 (ROADMAP 7.2) umgesetzt: Modulare Spielplatz-Komponenten in `modes/hub/playground/` (`trampoline.gd`, `slide.gd`, `carousel.gd`, `moving_platform.gd`, `seesaw.gd`). `Player` um `launch()` erweitert. Spielplatz-Elemente in `HubProps` in die Ost- und West-Zonen integriert (Karussell und Großtrampolin im Rummel; Schanzenrutsche, physikalische Wippe, Zwillings-Trampoline und Teich-Fähre auf der Spielzeug-Wiese; Vertikallift zum Parkour). Smoke-Test `tests/smoke/hub_smoke.gd` um Spielplatz-Prüfungen und Trampolin-Sprungdynamik erweitert (31/31 bestanden).
Entscheidungen: D103, D104, D105, D106
Getestet: Unit-Tests 31/31; compile_smoke 138/0; smoke-hub 31/31; smoke-m1 50/50; smoke-m2 39/39; asset_audit erfolgreich.
Probleme / Bekannte Fehler: keine.
Nächster Schritt: WP 3 (Schwieriges Jump'n'Run: Fordernder Parkour & Kletterturm mit Rückfall-Sicherung und Siegerkrone an der Spitze).
Aktuelle Kopie liegt in: Git-Repo `https://github.com/sudoMrMCaffe/PartyPark.git` und lokal in `c:\Users\VM\Desktop\PartyPark`


## 2026-10-21: Patch v0.7 „Der Park“ – WP 1 abgeschlossen

Agent und Umgebung: Gemini (Antigravity), Windows x86_64 lokal
Erledigt: Schritt 0 und 1 von Prompt 07 umgesetzt: Alle Systemtests grün, Version in `project.godot` auf 0.6.0 gesetzt, Entwickler-Schnellstart über `--hub` / `--lobby` in `core/game.gd` integriert. Fragerunde zu Park-Layout, Kletterturm, Startlogik und Spielzeugen durchgeführt und Entscheidungen D99 bis D102 in `docs/DECISIONS.md` festgehalten. Implementierungsplan für WP 1 vorgelegt und freigegeben. WP 1 (ROADMAP 7.1) umgesetzt: Begehbares 3D-Lobby-Areal in `modes/hub/` (`hub.tscn`, `hub.gd`, `hub_camera.gd`, `hub_props.gd`) mit zentraler Plaza, Springbrunnen, vier thematischen Sternwegen mit Torbögen (Parkour/Turm, Rummelplatz, Attraktionen, Spielzeug-Wiese), umlaufender Parkmauer mit Hecken, rotierendem Riesenrad, Achterbahn-Horizont, Zirkuszelten, Lichterketten, Laternen, Buden und Bäumen aus dem Kenney Coaster Kit. Dynamische Großraumkamera `HubCamera`, automatisches Spawning für 4 Spieler, Zonen-Erkennung und Absturz-Sicherung. Neuer Smoke-Test `tests/smoke/hub_smoke.gd` (--smoke-hub, 23/23 bestanden).
Entscheidungen: D99, D100, D101, D102
Getestet: Unit-Tests 31/31; compile_smoke 133/0; smoke-m1 50/50; smoke-m2 39/39; smoke-hub 23/23; asset_audit erfolgreich.
Probleme / Bekannte Fehler: keine.
Nächster Schritt: WP 2 (Bewegungs- & Platforming-Spielplatz: Trampoline, Rutschen, Karussell, bewegliche Plattformen).
Aktuelle Kopie liegt in: Git-Repo `https://github.com/sudoMrMCaffe/PartyPark.git` und lokal in `c:\Users\VM\Desktop\PartyPark`


## 2026-10-21: Spieltest-Feedback eingearbeitet, Prompt 07 für v0.7 erstellt

Agent und Umgebung: Gemini (Antigravity), Windows x86_64 lokal
Erledigt: Spieltest-Notizen von Leonardo aus dem Build ausgewertet und in `docs/DECISIONS.md` festgehalten: D95 (Trigger RT/R2 als Standard für Gas/Boost in Autoscooter, Schuss in Zerfetzung, Scheuchen in Schafe hüten; A Bestätigen/Springen, B Zurück/Aktion), D96 (Schafe hüten Gameplay-Rework für mehr Dynamik und komplexere Aufgaben), D97 (Tastensymbole aus `kenney_input-prompts` in Menüs und HUD grafisch einbinden). Prompt `docs/prompts/07_patch_v0_7.md` für Patch v0.7 „Der Park“ (Brettspiel-Modus „Parkrundfahrt“, Würfel, Ereignisfelder, Kiosk-Items) nach Vorlage ausgearbeitet.
Entscheidungen: D95, D96, D97
Getestet: Exportierte `Partypark.exe` läuft auf Windows.
Probleme / Bekannte Fehler: keine.
Nächster Schritt: Trigger-Steuerung und Schafe-Gameplay vorbereiten, dann Weiterarbeit nach Aufgabenplan.
Aktuelle Kopie liegt in: Git-Repo `https://github.com/sudoMrMCaffe/PartyPark.git` und lokal in `c:\Users\VM\Desktop\PartyPark`

## 2026-10-21: Patch v0.6 „Mehr Chaos“ gestartet, Schritt 0 und 1 abgeschlossen

Agent und Umgebung: Gemini (Antigravity), Windows x86_64 lokal
Erledigt: Schritt 0 und 1 von Prompt 06 umgesetzt: Alle automatischen Tests ausgeführt und grün (Unit 31/31, compile 123 Dateien 0 Fehler, smoke-m1 50/50, smoke-m2 39/39, smoke-games 12/12, asset_audit erfolgreich). Entwickler-Schnellstart über `--play=<id>` (optional `--format=<format>`, `--mood=<mood>`, `--instant`) in `core/game.gd` und `MinigameSandbox` (`start_by_id`) eingerichtet; Minigames starten ohne Menü direkt auf dem Desktop oder im Headless-Modus. Fragerunde durchgeführt und Entscheidungen D91 bis D94 in `docs/DECISIONS.md` festgehalten (D91: rein testgetriebene Weiterarbeit; D92: Rache-Modus als Geister am Rand mit Störungen auf Cooldown; D93: 6 neue Spiele target_rally, coaster_brake, snack_stand, log_flume, game_master, track_builder; D94: Autoscooter-Steuerung beibehalten). Q18 als erledigt markiert. Implementierungsplan für WP 2 (Rache-Modus) als Artefakt vorgelegt.
Entscheidungen: D91, D92, D93, D94; Q18 erledigt
Getestet: Unit-Tests 31/31; compile_smoke 123/0; smoke-m1 50/50; smoke-m2 39/39; smoke-games 12/12; asset_audit erfolgreich; `--play=bumper_cars --instant`, `--play=tug_of_war --format=2v2 --instant` und `--play=sheep_herding` (MatchFlow) erfolgreich ausgeführt.
Probleme / Bekannte Fehler: keine neuen Fehler.
Nächster Schritt: WP 2 (Rache-Modus in `core/ghosts/`) nach Freigabe des Implementierungsplans umsetzen.
Aktuelle Kopie liegt in: Git-Repo `https://github.com/sudoMrMCaffe/PartyPark.git` und lokal in `c:\Users\VM\Desktop\PartyPark`

## 2026-10-21: Übergabe an Antigravity abgeschlossen

Agent und Umgebung: Gemini (Antigravity), Windows x86_64 lokal
Erledigt: Teil A abgeschlossen: Alle automatischen Tests ausgeführt und grün (Unit 31/31, compile 122 Dateien 0 Fehler, smoke-m1 50/50, smoke-m2 39/39, smoke-games 12/12). Asset-Audit ausgeführt. Import-Problem durch `.gdignore` in `assets/_incoming/` dauerhaft gelöst (alle 52 WAVs und GLBs sauber importiert). Stilproben in 1280x720 in allen drei Stimmungen erfolgreich gerendert und geprüft (`docs/screenshots/check/`). Spiel sichtbar gestartet. `AGENTS.md` um Windows-Befehle, Asset-Audit, Screenshots und Rückfrageregeln erweitert (bleibt unter 12.000 Zeichen). `CLAUDE.md` mit Hinweis auf Antigravity als Hauptumgebung versehen. Vier Antigravity-Skills in `.agents/skills/` angelegt (`partypark-tests`, `partypark-screenshots`, `partypark-minigame`, `partypark-patch-abschluss`). ROADMAP 6.0 auf erledigt.
Entscheidungen: D90
Getestet: Unit-Tests 31/31; compile_smoke 122/0; smoke-m1 50/50; smoke-m2 39/39; smoke-games 12/12; asset_audit erfolgreich; smoke-style_probe 6 Screenshots erzeugt.
Probleme / Bekannte Fehler: Intel UHD 630 meldet in Windows CM_PROB_FAILED_POST_START; Godot rendert Forward+ sauber und flüssig über Direct3D 12. Draw Calls bei Wackelwaben noch bei 604 (wird in WP 6 optimiert).
Nächster Schritt: Teil B, Arbeitspaket 3 (Asset-Pipeline: genutzte Pakete aus `assets/_incoming/` nach `assets/third_party/` überführen, CREDITS.md).
Aktuelle Kopie liegt in: Git-Repo `https://github.com/sudoMrMCaffe/PartyPark.git` und lokal in `c:\Users\VM\Desktop\PartyPark`

## 2026-10-21: Antigravity-Übernahme begonnen, Git-Sync und Vorbereitung GPU-Neustart

Agent und Umgebung: Gemini (Antigravity), Windows x86_64 lokal
Erledigt: Teil A Schritt A1 durchgeführt (Einlesen, Bestandsaufnahme); A2.1 Git-Status geprüft, Prompt 05 mit Online-Repo-URL committet, Remote `origin` auf `https://github.com/sudoMrMCaffe/PartyPark.git` gesetzt, Leonardo hat Branch `main` per `--force-with-lease` auf GitHub gepusht; A2.5 Vorhandensein von `.github/workflows/tests.yml` geprüft; `compile_smoke.gd` um `_incoming` in `SKIP_DIRS` ergänzt (jetzt grün: 122 Dateien, 0 Fehler). Unit-Tests 31/31 grün. Fortsetzungsprompt `docs/prompts/05b_v0_5_fortsetzung.md` zur nahtlosen Weiterarbeit nach GPU-Durchreichung und VM-Neustart erstellt.
Entscheidungen: D90
Getestet: Unit-Tests 31/31 bestanden; `godot --headless --path . -- --smoke-compile` 122 Dateien, 0 Fehler.
Probleme / Bekannte Fehler: GPU war in Entwickler-VM noch nicht durchgereicht (wird beim Neustart erledigt). Audio-Samples im headless-Modus ohne Audio-Treiber melden Ladefehler beim direkten WAV-Laden; Godot-Editor importiert nach GPU-Aktivierung vollständig.
Nächster Schritt: Nach dem VM-Neustart neuen Chat mit `docs/prompts/05b_v0_5_fortsetzung.md` starten (Schritte A2.2 bis A3, danach Teil B).
Aktuelle Kopie liegt in: Git-Repo `https://github.com/sudoMrMCaffe/PartyPark.git` und lokal in `c:\Users\VM\Desktop\PartyPark`


Agent und Umgebung: Claude (Cowork), nur Doku, kein Spielcode geändert
Erledigt: Stand geprüft: In der v0.5-Sitzung lief eine frühere Fassung von Prompt 04 (ohne Waffen-Abschnitt und ohne Download-Skript); umgesetzt sind Schritt 0 bis WP 2 (Stil D85, Tageszeiten D86, `core/look/`, ART_GUIDE, Asset-Audit, Coaster Kit in `assets/third_party/`). Version noch 0.4.0. Prompt 05 neu: Teil A Übergabe an Antigravity (Windows-Befehle, Bildschirmfotos mit echter Grafikkarte, Skills, Rückfrageregeln), Teil B Rest von v0.5 (WP 3 bis 10) mit zehn Nachbesserungen: Waffen aus dem Blaster Kit als `core/weapons/` (neues WP 5a), keine Umrisslinien, alle drei Stimmungen je Arena, Draw Calls Wackelwaben und Dreiecke Schafe, Wasser-Spiegelung, Arenathemen Q26 mit Bildern, doppelte Pakete in `_incoming`, Hüte selbst bauen, offene Testpunkte, kein Dateibrücken-Ablauf mehr. Prompt 06 setzt den Abschluss von v0.5 voraus und schlägt mindestens ein Schießspiel vor. Prompt 04 mit Hinweis versehen, ROADMAP (5.5a, Umgebung v0.5), D89.
Entscheidungen: D89
Getestet: nichts (nur Doku)
Probleme / Bekannte Fehler: Haltepunkt 1 von v0.5 ohne formale Rückmeldung zu den Bildern; Testergebnisse v0.4 und Messwerte weiter offen.
Nächster Schritt: Leonardo committet und pusht den aktuellen Stand, dann in Antigravity `docs/prompts/05_uebergabe_antigravity.md` starten.
Aktuelle Kopie liegt in: `C:\Users\wad32muj\Agentenraum\partypark`

## 2026-10-21: Patch v0.5, Schritt 0 bis WP 2 (Stil steht), Haltepunkt 1

Agent und Umgebung: Claude (Cowork), Variante B, Godot 4.7.2 headless, Bildschirmfotos mit Vulkan-Software-Renderer (lavapipe) in 1280×720
Erledigt: Ausgangswerte grün (Unit 31, compile 117, m1 50/50, m2 39/39, games 12/12). Vorher-Bilder aller sieben Minispiele, Titel, Beitritt, Hauptmenü, Testarena, Regeln, Ergebnis und Siegerehrung in `docs/screenshots/v0_5/vorher/`. Alle 20 Pakete in `assets/_incoming/` geprüft (alle CC0, D83). Fragerunde: ohne Testergebnis weiter (D82), alle sieben Arenen (D84). WP 2: Stilproben derselben Szene (Autoscooter-Arena mit Riesenrad, Achterbahn, Zelten, Lichterketten) in drei Stilen und drei Stimmungen; Leonardo wählt Spielzeug-Plastik ohne Umrisslinien (D85) und den Tagesverlauf im Turnier mit Option „Tageszeit“ (D86). Neu: `core/look/` mit `Look` (Umgebung je Stimmung mit AgX, Tiefennebel, Glow, SSAO auf Hoch; Materialien je Stoffart; Figurenmaterial; `restyle()` für fremde Modelle), `ParkProps` (Riesenrad, Zelt, Achterbahn aus Kontrollpunkten, Lichterkette, Fahnenmast, Laterne), `ParkWheel`, Wasser-Shader mit Schaumkante (D87). `StageKit` nutzt den Look, Figur glänzt wie lackiertes Spielzeug. Turnier, Freies Spiel, Siegerehrung, Menüs und Testarena wählen ihre Stimmung. `docs/ART_GUIDE.md` (verbindlich). Vorgezogen aus WP 3: `tools/asset_audit.gd` mit Start über `-- --tool-asset_audit` (D88), Kenney Coaster Kit (Bäume, Buden) in `assets/third_party/`, CREDITS. ROADMAP 5.1 verschoben (D82).
Entscheidungen: D82 bis D88; Q25 erledigt; Q26 teilweise
Getestet: Unit 31/31; compile 122 Dateien, 0 Fehler; m1 50/50; m2 39/39; games 12/12. Stilproben und Autoscooter mit neuem Licht als Bild geprüft. Asset-Audit Stand v0.4: Wackelwaben schätzungsweise 608 Draw Calls (über Budget 400), Schafe hüten 147.000 Dreiecke.
Probleme / Bekannte Fehler: Arenen selbst sind noch die alten Grundformen (kommt in WP 6); große Wasserflächen der alten Arenen spiegeln die Sonne stark. Farbwirkung und Bildrate nur auf Leonardos Rechner prüfbar.
Nächster Schritt: Haltepunkt 1, Leonardo schaut die Bilder an; danach WP 3 (Asset-Pipeline), WP 4 (Look-Grundlage), WP 5 (Figur).
Aktuelle Kopie liegt in: `C:\Users\wad32muj\Agentenraum\partypark` (nach dem Zurückschreiben)

## 2026-10-21: Erweiterte Asset-Recherche mit Direktlinks und Download-Skript

Agent und Umgebung: Claude (Cowork), nur Doku und Hilfsskript, kein Spielcode geändert
Erledigt: `docs/ASSET_QUELLEN.md` neu gegliedert (Waffen, Park und Arenen, einzelne Minispiele, Menü/UI, Texturen und Himmel, Audio, Selbstbau) mit rund 40 geprüften Quellen, Lizenzen und Direktlinks (Kenney, KayKit, Quaternius, Poly Haven, ambientCG, Google Fonts). Neues Skript `tools/download_assets.ps1` lädt alle Pakete mit Direktlink nach `assets/_incoming/<name>/` (Gruppen Basis, Erweitert, Audio). GAME_DESIGN 9.7 mit sechs Schießspiel- und Minigolf-Ideen. Prompts 04 (Vorbereitung per Skript, Blaster für die Zerfetzung, gemeinsame Waffen-Szenen) und 06 angepasst.
Entscheidungen: keine; alles Vorschlag
Getestet: Download-Adressen am 2026-10-21 auf den Herstellerseiten geprüft; Skript nicht ausgeführt (keine PowerShell in der Cloud).
Probleme / Bekannte Fehler: Für Hüte gibt es kein freies Paket mit klarer CC0-Lizenz, Vorschlag: selbst bauen. Kenney kann Download-Adressen ändern, dann von Hand laden.
Nächster Schritt: Leonardo führt `tools/download_assets.ps1` aus, lädt die itch.io-Pakete und Schriften von Hand, dann neuer Chat mit `docs/prompts/04_patch_v0_5.md`.
Aktuelle Kopie liegt in: `C:\Users\wad32muj\Agentenraum\partypark`

## 2026-10-21: Planung v0.5 „Neuer Look“ und Übergabe an Antigravity

Agent und Umgebung: Claude (Cowork), nur Doku, kein Code geändert
Erledigt: Stand nach v0.4 gesichtet (sieben Minispiele, Effekte, Sound, Ansager, Grafikstufen, Messmodus, Export, GitHub-Vorlage; Tests bei Leonardo offen). Versionsplan umgestellt (D80): v0.5 Grafik, v0.6 Mehr Chaos, v0.7 Der Park, v0.8 Party-Joker, v0.9 Rettet den Park und Für alle. Freie Asset-Quellen recherchiert und mit Lizenzen in `docs/ASSET_QUELLEN.md` festgehalten (Kenney Coaster Kit und Input Prompts, KayKit, Quaternius, Poly Haven, ambientCG). Prompt `docs/prompts/04_patch_v0_5.md` neu geschrieben (vorherige Fassung „Mehr Chaos“ ist in `06_patch_v0_6.md` aufgegangen). Neu: `docs/prompts/05_uebergabe_antigravity.md` und `docs/prompts/06_patch_v0_6.md` für die Arbeit in Antigravity (D81). GAME_DESIGN Abschnitt 8 und Versionsverweise angepasst. Neue offene Fragen Q25 bis Q27.
Entscheidungen: D80, D81
Getestet: nichts (nur Doku). Asset-Seiten sind aus der Cloud-Umgebung nicht erreichbar (Proxy 403), deshalb lädt Leonardo die Pakete nach `assets/_incoming/`.
Probleme / Bekannte Fehler: Testergebnis v0.4 und Messwerte der Radeon 780M stehen weiter aus.
Nächster Schritt: Leonardo lädt die Pakete aus `docs/ASSET_QUELLEN.md` (Abschnitt „Empfohlene Pakete“) nach `assets/_incoming/`, dann neuer Chat mit `docs/prompts/04_patch_v0_5.md`.
Aktuelle Kopie liegt in: `C:\Users\wad32muj\Agentenraum\partypark`

## 2026-10-20: Patch v0.4 „Spieleabend“ abgeschlossen (WP 4 bis 9)

Agent und Umgebung: Claude (Cowork), Variante B, Godot 4.7.2 headless, Bildschirmfotos mit Vulkan-Software-Renderer, Export mit Vorlagen 4.7.2
Erledigt: Leonardo wünschte, ohne Testrückmeldung weiterzuarbeiten (D66, Haltepunkte übersprungen). WP 4: Ansager „Hodenhüpfer“ als trockener Kommentator (D67, D68): Autoload `Announcer`, Sprechblase mit Gesicht, Silben-Geplapper, Spruchliste `core/announcer/announcer_lines.json` mit 8 Ereignissen, eingebunden in MatchFlow, Siegerehrung und Ausscheiden; Minispiele melden knappe Entscheidungen über `was_close()`. WP 5: Grafikstufen Niedrig/Mittel/Hoch (FSR, Schatten, MSAA), Leistungsanzeige mit F3 oder Option, Messmodus `-- --bench` mit `user://bench.txt`, `docs/PERFORMANCE.md` (D69, D77). WP 6: Wackelwaben (D70, D73: 3 Ebenen à 91 Waben), Heiße Kartoffel (D71), zusätzlich Zerfetzung als Ego-Shooter mit Splitscreen und comichafter Zerfetzung (D49, D72, D76: `SplitScreen`, `ShooterAbility`, zweiter Stick `get_aim()`); 12 neue Geräusche. WP 7: `docs/MINIGAME_GUIDE.md`, `tools/new_minigame.gd` mit Unit-Test. WP 8: Q09 → privates GitHub mit Actions (Vorlage `tools/ci/tests.yml`, von Leonardo nach `.github/workflows/` zu kopieren, weil `.github` für Claude gesperrt ist; `docs/GITHUB_ANLEITUNG.md`, D74, D79); Liste leerer `.gitkeep` in TESTANLEITUNG_V0_4 Nr. 30. WP 9: `export_presets.cfg` Windows und Linux (D78), `docs/EXPORT_UND_BAZZITE.md`. Fehler behoben: Lambda auf freigegebene Figur im Schafe-Spiel (Tween statt SceneTreeTimer), Ordner für Bildschirmfotos im Smoke-Test M2. Version 0.4.0.
Entscheidungen: D66 bis D79; Q09 erledigt; neue offene Fragen Q23 (Ansager-Optik), Q24 (Zerfetzung-Details)
Getestet: Unit 31/31; compile 117 Dateien, 0 Fehler; m1 50/50; m2 39/39 (sieben Minispiele im Freien Spiel, Ansager spricht); games 12/12. Simulation Computer gegen Computer: Wackelwaben 25 bis 40 s, Heiße Kartoffel ca. 40 s mit 12 bis 14 Weitergaben, Zerfetzung 50 bis 70 s, Riese gegen Zwerge ausgeglichen. Bildschirmfotos: Splitscreen mit vier Ego-Ansichten, Ansager-Sprechblase. Exporte Windows und Linux erzeugt, Linux-Export startet und durchläuft den Messmodus. Nicht prüfbar: Klang, Vibration, echte Bildrate, Controller, Bazzite.
Probleme / Bekannte Fehler: Im headless Smoke-Test mit `--fixed-fps` erscheint gelegentlich die Jolt-Warnung „job system exceeded the maximum number of jobs“ (trat schon vor v0.4 auf, ohne Folgen). Messwerte auf der Radeon 780M fehlen. Zerfetzung rendert vier Ansichten mit Schatten, Bildrate dort besonders prüfen. Haltepunkte 1 und 2 ohne Rückmeldung.
Nächster Schritt: Leonardo testet nach `docs/TESTANLEITUNG_V0_4.md` (1 bis 30), richtet GitHub ein, misst mit `-- --bench`. Danach neuer Chat mit `docs/prompts/04_patch_v0_5.md`.
Aktuelle Kopie liegt in: `C:\Users\wad32muj\Agentenraum\partypark` (nach dem Zurückschreiben)

## 2026-10-20: Patch v0.4, WP 1 bis 3 (Feedback, Effekte, Sound), Haltepunkt 1

Agent und Umgebung: Claude (Cowork), Variante B, Godot 4.7.2 headless (Bildschirmfotos mit Vulkan-Software-Renderer)
Erledigt: Ausgangswert grün (Unit 18/18, compile 78/0, m1 50/50, m2 30/30). Fragerunde: Versionsplan übernommen (D47), neue Spiele Wackelwaben, Heiße Kartoffel und ein Ego-Shooter mit echtem Splitscreen (D48, D49), Ansager mit Brabbelstimme (D50). Spieleabend-Feedback (Q22): Autoscooter mit Tastatur schwer steuerbar, Grafik dürftig, beim Riesen keine Seile sichtbar, Tauziehen etwas langweilig. WP 1: Seile beim Riesen sichtbar gewickelt (`RopeTube`, Ringe außen, Abschütteln fliegt weg, D52), Tauziehen mit Kraftakt (Y), 30 s, mehr Zug, federndes Seil (D53), Computer-Zwerge zögerlicher mit Pausen (D58, Simulation 8 von 16 Zwergsiege), Q13 und Q14 bleiben (D54, D57). Neue `MinigameSandbox` und Smoke-Test `--smoke-games`. WP 2: Effekt-Baukasten `core/fx/` mit Autoload `Fx`, `CameraShaker`, lokalem Hitstop, sechs Partikel-Vorlagen mit Pool und Obergrenze 700, Squash-Impulsen, Option „Bildschirmwackeln“, eingebaut in Figur, MatchFlow (Konfetti) und alle vier Minispiele nach D55/D56. WP 3: Busse Music/Sfx/Voice, Autoload `Sfx`, Generator `tools/sfx_gen.gd` mit 42 selbst erzeugten Geräuschen (inkl. sechs Ansager-Silben), Lautstärkeregler in den Optionen, Geräusche in Menüs, Ablauf und allen Minispielen (D59 bis D62).
Entscheidungen: D47 bis D65; Q13, Q14, Q16, Q17, Q21 erledigt; Q15 teilweise; Q22 (Feedback) in Arbeit
Getestet: Unit 23/23; compile 96 Dateien, 0 Fehler; m1 50/50; m2 32/32 (neu: Bildschirmwackeln umschalten); games 9/9 (alle Spiele, Partikel-Obergrenze, Wackeln, Geräusche vorhanden). Bildschirmfotos: Seile am Riesen, Kraftbalken im Tauziehen, Partikel im Autoscooter sichtbar. Klang, Vibration, Bildrate und Controller nur bei Leonardo prüfbar.
Probleme / Bekannte Fehler: Computer gegen Computer sind Runden kurz (Riese 10 bis 35 s, Schafe teils unter 30 s); Kraftakt im Tauziehen bei Computern sehr häufig (Platzhalter 4 Synchrontakte). Autoscooter-Steuerung unverändert bis zum Controllertest (D51).
Nächster Schritt: Haltepunkt 1, Leonardo testet nach `docs/TESTANLEITUNG_V0_4.md` Teil 1. Danach WP 4 (Ansager).
Aktuelle Kopie liegt in: `C:\Users\wad32muj\Agentenraum\partypark` (nach dem Zurückschreiben)

## 2026-10-20: Bestandsaufnahme und Versionsplan bis v1.0

Agent und Umgebung: Claude (Cowork), nur Doku, kein Code geändert
Erledigt: Stand gesichtet (M1 bis M3, Menüs, 4 Minispiele, 18 Unit-Tests, Smoke-Tests, Godot 4.7.2). Recherche bei Partyspielen und genrefremden Spielen. ROADMAP um einen Versionsplan v0.4 bis v1.0 erweitert (Spieleabend, Mehr Chaos, Der Park, Party-Joker, Rettet den Park, Für alle, Eröffnung). GAME_DESIGN: Schnellbau-Liste 9.5 (4 Spiele), 18 neue Minispielideen in 9.6, neue Formate, Ideenspeicher für Funktionen (Abschnitt 12), Parkrundfahrt als Hybrid-Vorschlag für Q01. Neue offene Fragen Q16 bis Q21. Prompt für den nächsten Patch: `docs/prompts/03_patch_v0_4.md`.
Entscheidungen: keine; alles als Vorschlag markiert
Getestet: nichts (nur Doku)
Probleme / Bekannte Fehler: Spieleabend (ROADMAP 3.6) noch nicht zurückgemeldet.
Nächster Schritt: Neuer Chat mit `docs/prompts/03_patch_v0_4.md`.
Aktuelle Kopie liegt in: `C:\Users\wad32muj\Agentenraum\partypark`

## 2026-10-20: Startfehler „Could not find type MinigameInfo“ behoben

Agent und Umgebung: Claude (Cowork), Variante B
Erledigt: Leonardo meldete, dass das Spiel nach dem Zurückschreiben von M2/M3 nicht startete (Autoload `MinigameRegistry` und Titelbildschirm fanden die neuen Klassen nicht). Ursache: Der Klassen-Cache `.godot/global_script_class_cache.cfg` im Ordner stammte noch vom Stand M1, weil die neuen Dateien von außen kamen und der Editor noch nicht neu gescannt hatte. Aktuellen Cache aus der Cloud-Kopie in den Ordner geschrieben; Vorgehen in `CLAUDE.md` (Variante B, Schritt 5) ergänzt.
Entscheidungen: keine
Getestet: Cache-Inhalt geprüft (36 Klassen); Start bei Leonardo steht aus.
Probleme / Bekannte Fehler: Ist der Editor beim Zurückschreiben geöffnet, kann er den alten Cache wieder speichern. Dann im Editor „Projekt → Aktuelles Projekt neu laden“.
Nächster Schritt: wie im Eintrag darunter.
Aktuelle Kopie liegt in: `C:\Users\wad32muj\Agentenraum\partypark`

## 2026-10-19: Menüs, Schnellturnier, Freies Spiel und vier Minispiele (M2, M3)

Agent und Umgebung: Claude (Cowork), Variante B, Tests mit Godot 4.7.2 (Leonardo nutzt 4.7, D41)
Erledigt: Testergebnis M1 von Leonardo: „klappt alles“ (Windows, Godot 4.7, vor allem mit Tastatur). Drei Designrunden (D29 bis D40). Menüs: Titel, Hauptmenü, Optionen mit Speicherung (`Settings`-Autoload), `MenuList`, `MenuBackdrop`. Framework: `TeamFormat`, `TeamAssigner`, `MinigameInfo`, `MinigameCatalog`, `MinigameRegistry`, `MinigameContext`, `MinigameResult`, `Scoring`, `Minigame`, `MatchFlow` (Ankündigung, Regeln mit Bereit, Countdown, Zeitlupe, Ergebnis), `MinigameHud`. Spielarten: Schnellturnier mit Zwischenstand und Siegerehrung, Freies Spiel mit Teamwahl. Minispiele: Autoscooter, Tauziehen, Riese gegen Zwerge, Schafe hüten, jeweils mit Computergegnern (`AIProfile`, drei Stärken). Spielfigur erweitert (eigene Bewegungsmodelle, Skalierung, Teamring, Ausscheiden). Pause-Menü „Zum Hauptmenü“. Tests: `tests/run_tests.gd` mit 18 Unit-Tests, Smoke-Tests m1, m2, compile.
Entscheidungen: D29 bis D46; Q05 bis Q07 erledigt; neue offene Fragen Q13 (Teampunkte), Q14 (Teamfarben), Q15 (Balance)
Getestet: Unit-Tests 18/18; `--smoke-compile` 0 Fehler; `--smoke-m1` 50/50; `--smoke-m2` 30/30 (komplettes 5-Runden-Turnier, jedes Minispiel, Optionen); Simulation Computer-Riese gegen Computer-Zwerge: Zwerge gewinnen nach ca. 57 von 75 s. Bildschirmfotos mit Forward+ (Software-Vulkan) geprüft. Echte Controller, Vibration und Bildrate offen.
Probleme / Bekannte Fehler: Balance ist geschätzt (Q15). Untätige Menschen verlieren Tauziehen in ca. 10 s. Platzhaltergrafik überall. Leere `.gitkeep`-Dateien in Ordnern mit Inhalt können gelöscht werden.
Nächster Schritt: Leonardo testet nach `docs/TESTANLEITUNG_M3.md` (Spieleabend, ROADMAP 3.6); danach Balance (Q15), Q13, Q14 klären. Für die nächste Sitzung `docs/prompts/02_spieleabend_und_ausbau.md` verwenden.
Aktuelle Kopie liegt in: `C:\Users\wad32muj\Agentenraum\partypark`

## 2026-10-19: Tastenhinweise je Gerät

Agent und Umgebung: Claude (Cowork), Variante B
Erledigt: Erster Test von Leonardo unter Windows mit Godot 4.7: Projekt startet, Tastatur funktioniert, aber die Start-Taste der Tastatur (Esc) war nicht erkennbar, weil alle Hinweise Controller-Tasten nannten. Neu: `InputSource.get_action_label()`, `get_kind_name()`, `get_move_label()`; `GamepadInput` erkennt Xbox-, PlayStation- und Nintendo-Controller am Namen; `KeyboardInput` nennt Tasten im aktuellen Layout; Hilfsklasse `ui/input_hints.gd`. Beitrittskarten zeigen pro Spieler dessen Tasten, die Hinweiszeile nennt Beitritts- und Starttasten je Gerät, Arena und Verbindungshinweis nennen die Pause-Tasten je Gerät, das Pause-Menü zeigt die Bedienung des Öffnenden.
Entscheidungen: D28
Getestet: Smoke-Test 47 von 47 grün mit Godot 4.6.2 headless und Godot 4.7.2 mit Forward+ (Vulkan, Software-Renderer), Bildschirmfotos geprüft.
Probleme / Bekannte Fehler: keine neuen. Controllertest weiter offen.
Nächster Schritt: Leonardo testet weiter nach `docs/TESTANLEITUNG_M1.md`, zuerst mit Tastatur, dann mit Controllern.
Aktuelle Kopie liegt in: `C:\Users\wad32muj\Agentenraum\partypark`

## 2026-10-19: Meilenstein M1 „Kern“ umgesetzt

Agent und Umgebung: Claude (Cowork), Variante B aus `CLAUDE.md` (Dateiübertragung, keine Shell auf Leonardos Rechner). Arbeitskopie in der Cloud, Änderungen in den Projektordner zurückgeschrieben.
Erledigt: Designrunde mit Leonardo (Q02, Q03, Q04, Q08, Startregel, Pause-Menü). Eingabeschicht `InputBindings`, `InputSource`, `GamepadInput`, `KeyboardInput` (zwei Debugspieler), `AIInput` (Gerüst), Autoload `InputRouter` mit Doppelgänger-Schutz und Latch für kurze Drücke. Autoload `PlayerRoster` mit `PlayerSlot`, Platzhalterfarben, Computer-Auffüllen. Autoload `Game` mit Szenenwechsel, Pause-Menü und Verbindungs-Pause samt Übernahme. Beitrittsbildschirm mit Podesten und Karten, Knubbelfigur mit Laufen, variablem Sprung, Schubsen mit Rückstoß, optischem Wackeln, Testarena mit Abgrund und Respawn, `ArenaCamera`. Hauptszene gesetzt. Smoke-Test `tests/smoke/m1_smoke.gd`. Testanleitung `docs/TESTANLEITUNG_M1.md`. ARCHITECTURE, AGENTS (Befehle), README aktualisiert.
Entscheidungen: D15 bis D27; neue offene Fragen Q10 (Spielerfarben), Q11 (Platzhalter im Beitrittsbildschirm), Q12 (Bewegungswerte nach Test)
Getestet: headless Import mit Godot 4.6.2 fehlerfrei; `--quit-after` Lauf von Hauptszene und Testarena ohne Fehler; Smoke-Test headless 37 von 37 grün; zusätzlich mit Forward+ (Vulkan, Software-Renderer unter Xvfb) 37 von 37 grün und Bildschirmfotos von Beitritt, Arena, Pause und Verbindungshinweis geprüft. Nachtrag: Import und Smoke-Test (headless und Forward+) auch mit Godot 4.7.2 grün, das Projekt läuft unverändert unter 4.7. Echte Controller, Vibration, Steam Input und Bazzite noch nicht getestet.
Probleme / Bekannte Fehler: Computergegner stehen in M1 nur herum (KI folgt in M3). Leere `.gitkeep`-Dateien in Ordnern, die jetzt Dateien enthalten, können gelöscht werden (Variante B kann nicht löschen). `--check-only` meldet bei Skripten mit Autoloads fälschlich Fehler, siehe AGENTS.md.
Nächster Schritt: Leonardo testet nach `docs/TESTANLEITUNG_M1.md` und meldet zurück; Ergebnis hier eintragen, Q10 bis Q12 klären, Werte justieren. Danach M2 (ROADMAP 2.1 bis 2.6), vorher Q06, Q07 und Ablauf von Regelbildschirm und Übungsrunde klären.
Aktuelle Kopie liegt in: `C:\Users\wad32muj\Agentenraum\partypark` (Git-Commit dort durch Leonardo)

## 2026-10-19: Umzug in den lokalen Projektordner

Agent und Umgebung: Claude (Cowork)
Erledigt: Projekt aus dem Claude-Projekt in den verbundenen Ordner `C:\Users\wad32muj\Agentenraum\partypark` verschoben. Den Ordner `.git` dürfen die Fernzugriffs-Werkzeuge nicht schreiben, deshalb legt Leonardo das Git-Repository lokal neu an; die bisherigen vier Einrichtungs-Commits entfallen. Die Kopien im Claude-Projekt wurden entfernt, dort liegt nur noch ein Hinweis auf den Ordner. `CLAUDE.md`, `AGENTS.md`, `README.md` und Prompt 01 auf den neuen Ablauf umgestellt. Abgleich-Tag heißt jetzt `sync/folder`.
Entscheidungen: D14, Q09 angepasst
Getestet: headless Import mit Godot 4.6.2 fehlerfrei.
Probleme / Bekannte Fehler: Ohne Shell auf Leonardos Rechner kann Claude im Ordner keine Dateien löschen oder verschieben, nur schreiben.
Nächster Schritt: Leonardo führt im Ordner `git init` und den ersten Commit aus (siehe README). Dann neuer Chat mit `docs/prompts/01_prototyp.md` und verbundenem Projektordner, Beginn mit Klärung von Q02 bis Q05 und Q08, dann Meilenstein M1.
Aktuelle Kopie liegt in: `C:\Users\wad32muj\Agentenraum\partypark`

## 2026-10-19: Projekt eingerichtet

Agent und Umgebung: Claude (Cowork)
Erledigt: Ideensammlung und Planung mit Leonardo. Projektverzeichnis `partypark/` mit leerem Godot-4.6-Projekt (Jolt, Forward+), Ordnerstruktur, Git, `.gitignore`, `.gitattributes`, `.editorconfig`. Kontextdokumente `AGENTS.md`, `CLAUDE.md`, `README.md`, `docs/GAME_DESIGN.md`, `docs/ARCHITECTURE.md`, `docs/DECISIONS.md`, `docs/ROADMAP.md`. Hilfsskript `tools/pack_snapshot.sh`. Prompt für den ersten Prototyp in `docs/prompts/01_prototyp.md`.
Entscheidungen: D01 bis D13, offene Fragen Q01 bis Q09
Getestet: `godot --headless --import` mit Godot 4.6.2 läuft fehlerfrei durch.
Probleme / Bekannte Fehler: Claude-Projektdokumente können keine Binärdateien speichern. Ein Base64-Schnappschuss wurde verworfen, weil er beim Lesen den Chat-Kontext füllt. Lösung: Textdateien einzeln im Projekt, komplettes Repo als `partypark.zip` beim Nutzer, das in neuen Chats angehängt wird (siehe `CLAUDE.md`).
Nächster Schritt: Neuer Chat mit `docs/prompts/01_prototyp.md` und angehängtem ZIP, Beginn mit Klärung von Q02 bis Q05 und Q08, dann Meilenstein M1.
Aktuelle Kopie liegt in: Claude-Projekt „Godot local 4 player“ unter `partypark/` und `partypark.zip` bei Leonardo
