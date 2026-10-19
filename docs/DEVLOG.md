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
