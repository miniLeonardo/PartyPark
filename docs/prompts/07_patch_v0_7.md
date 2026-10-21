# Prompt 07: Patch v0.7 „Der Park“ (Antigravity)

In Antigravity verwenden, sobald Patch v0.6 „Mehr Chaos“ vollständig abgeschlossen ist (Version 0.6.0 in `project.godot`, Rache-Modus aktiv, 13 Minispiele spielbar, Zeitlupen-Wiederholung, Bonustitel). Kann im selben Gespräch oder in einem neuen gestartet werden.

---

Du entwickelst **Partypark**, ein lokales 3D-Partyspiel für bis zu 4 Spieler an einem Bildschirm (Godot 4.7, GDScript, Jolt, Forward+, Windows und Linux/Bazzite), lokal in Antigravity mit PowerShell-Terminal, Godot und Git. Ich bin Leonardo, Ideengeber und Spieldesigner.
`AGENTS.md` gilt vollständig: **Spieldesign, Regeln, Park-Layout, Jump'n'Run-Schwierigkeit, Optik und Klang entscheide ich nach deinen Vorschlägen.** Technische Entscheidungen triffst du selbst.

Quellen für den Stand: `docs/DEVLOG.md` (oberster Eintrag), `docs/ROADMAP.md` (Abschnitt v0.7), `docs/DECISIONS.md` (D98: Q01 entschieden – Lobby-Hub statt Brettspiel), `docs/GAME_DESIGN.md` (Abschnitt 10 und 12), `docs/ASSET_QUELLEN.md`, `docs/ARCHITECTURE.md`, `docs/MINIGAME_GUIDE.md`, `docs/ART_GUIDE.md`, `docs/PERFORMANCE.md`, letzte Testanleitung `docs/TESTANLEITUNG_V0_6.md`.

## Ziel des Patches

Patch v0.7 bringt das **Herzstück von Partypark** (Q01, D98): Ein voll begehbares **interaktives 3D-Lobby-Areal (Freizeitpark-Hub)**, das als nahtlose und lebendige Brücke zwischen den Minispielen dient. Anstelle von trockenen Menüs oder langsamen Brettspiel-Runden bewegen sich alle 4 Spieler gemeinsam durch einen bunten Freizeitpark. 

Im Mittelpunkt steht der **pure Bewegungsspaß**:
1. Knackiges Platforming, Trampoline, Rutschen, Drehkreuze und Schubser-Zonen.
2. Ein **forderndes, schwieriges Jump'n'Run (Parkour / Kletter-Turm)** als sportliche Herausforderung mit Belohnung an der Spitze (z. B. Partykrone, Aussichtsplattform, Konfettikanone).
3. **Attraktions-Stationen:** Minispiele und Turniere werden direkt über Portale, Buden und Aktivierungs-Plattformen im Park betreten („Alle Spieler auf das Podest“).

## Schritt 0: Gesundheitscheck & Vorbereitung

1. **Tests ausführen:** Nutze den Skill `partypark-tests`:
   ```powershell
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/run_tests.gd
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --smoke-compile
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --smoke-m1
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --smoke-m2
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --smoke-games
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --tool-asset_audit
   ```
   Rote Tests zuerst beheben. Version in `project.godot` muss mindestens `0.6.0` sein.

2. **Entwickler-Schnellstart für die Park-Lobby:**
   Ergänze in `core/game.gd` das Argument `--hub` bzw. `--lobby`, damit das Lobby-Areal direkt und ohne Umwege gestartet werden kann.

## Schritt 1: Lagebild und Spieldesign-Abstimmung

1. Stand in höchstens fünf Sätzen zusammenfassen.
2. In einer Fragerunde im Chat (nummerierte Fragen, Optionen A/B/C, Empfehlung mit Begründung voran, max. 4 Fragen):
   1. **Lobby-Aufbau & Themenbereiche:** Soll der Hub ein großer zentraler Festplatz mit Minispiel-Toren sein oder ein Rundweg mit verschiedenen Themenvierteln (Kirmes, Western, Wasserpark)?
   2. **Das schwierige Jump'n'Run (Parkour):**
      - Wo steht der Parkour (z. B. Gerüst an der Achterbahn, Aufstieg auf das Riesenrad oder Kletterturm im Zentrum)?
      - Welche Belohnung wartet oben (z. B. temporäre goldene Siegerkrone, die man beim Rempler verlieren kann, Aussichtspunkt mit Fotokamera, Konfetti-Buzzer)?
   3. **Start von Minispielen:** Reicht es, wenn ein Spieler die Station aktiviert, oder müssen sich alle beigetretenen Spieler auf die „Ready“-Zone stellen?
   4. **Lobby-Aktivitäten:** Sollen wartende Spieler kleine Minispielzeuge nutzen können (z. B. Spielzeug-Blaster aus `core/weapons/` zum gegenseitigen Wegpusten, Bälle kicken)?
3. Antworten sofort in `docs/DECISIONS.md` eintragen.

## Schritt 2: Arbeitspakete

Vor jedem größeren Paket einen Implementierungsplan als Artefakt vorlegen. Commits auf Deutsch (`v0.7 WP<n>: …`).

| WP | ROADMAP | Inhalt | Designfragen an Leonardo |
|---|---|---|---|
| 1 | 7.1 | Park-Lobby Basis: Großes 3D-Gelände (`modes/hub/`), Bodenbeläge, Wege, Absperrungen, Kulisse | Geländeform, Wegeführung |
| 2 | 7.2 | Bewegungs- & Platforming-Spielplatz: Trampoline (Boing-Sprung), Rutschen, Karussell, bewegliche Plattformen | Physik-Spielereien |
| 3 | 7.3 | Schwieriges Jump'n'Run: Fordernder Parkour mit schmalen Balken, beweglichen Teilen, Rückfall-Sicherung & Belohnung an der Spitze | Hindernis-Typen, Schwierigkeitsgrad |
| 4 | 7.4 | Attraktions-Portale & Minispiel-Einstieg: Stationen für alle 13 Minispiele, Schnellturnier-Bude, Aktivierungs-Zonen | Stations-Optik, Startlogik |
| 5 | 7.5 | Dynamische Kamera für bis zu 4 Spieler im großen Areal (Zooming & Rahmung) | Kameraperspektive |
| 6 | 7.6 | Parkbesucher & Atmosphäre: Kenney Mini Characters am Wegrand, Lichterketten-Beleuchtung, Park-Geräusche | Deko, Park-Leben |
| 7 | 7.7 | Übergänge & MatchFlow: Nahtloser Wechsel zwischen Lobby und Minispielen mit Rückkehr in den Park | Menü-Einbindung |
| 8 | 7.8 | Polishing, Testanleitung v0.7, Build & Export der `.exe` über `partypark-patch-abschluss` | keine |

**Haltepunkte:**
- **Nach WP 3:** Parkour & Bewegungsspielplatz fertig: Video/Bilder zeigen, Schnellstart (`--hub`) bereitstellen, damit Leonardo den Parkour selbst probehüpfen kann!
- **Nach WP 5:** Minispiel-Stationen & Kamera aktiv: Kompletter Ablauf (Lobby → Minispiel → zurück in Lobby) spielbar.

## Qualitätsregeln

1. `AGENTS.md` und `docs/ART_GUIDE.md` gelten vollständig.
2. Der Hub nutzt die `Look`-Materialien und ParkProps in allen drei Stimmungen (`noon`, `golden`, `evening`).
3. Die Steuerung der Spielfigur bleibt knackig und reaktionsschnell (`A` Springen, `B` Zurück, Trigger `RT` für Sprint/Boost).
4. Performance-Budget: Auch im großen Hub-Areal müssen 60 fps auf der Radeon 780M erreicht werden (MultiMesh für Deko, sparsame Punktlichter).

## Abschluss des Patches

1. `docs/TESTANLEITUNG_V0_7.md` schreiben.
2. DEVLOG, ROADMAP v0.7 auf erledigt, DECISIONS aktualisieren, `config/version` auf `0.7.0` setzen.
3. Commit, Push nach Freigabe, CI-Prüfung über GitHub Actions.
4. Neue `Partypark.exe` für Windows bauen und bereitstellen.
5. Prompt für v0.8 „Party-Joker“ vorbereiten.

Beginne jetzt mit Schritt 0.
