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

## 2026-11-25: Deck-Aufträge P1, P2, P3, 5.3, 5.4

Agent und Umgebung: Claude (Claude Code), lokal mit Git; 5.3 und 5.4 von zwei Unteragenten in eigenen Arbeitskopien
Erledigt: P1 Doppelgänger-Gewusel als 8. Minispiel (`minigames/doppelganger/`, 1 gegen 3, 32 Besucher als echte Player-Figuren mit eigener KI-Quelle). P2 Kronenjagd im Park (`modes/hub/tower/crown_hunt.gd`, Krone hat Signal `taken`, Besucher `cheer()`). P3 Handicap (`core/teams/handicap.gd`, `PlayerSlot.handicap`, Beitritt links/rechts; wirkt auf Tempo, Schubs-Wucht, Tauziehen-Fenster). 5.3: Asset-Audit mit Texturen und Paketübersicht, Atlanten komprimiert, Budget in ART_GUIDE Abschnitt 13. 5.4: Emission zentral, Glow/SSAO je Grafikstufe, Randlicht-Stufen (`--rims=` in der Stilprobe). Nebenbei: `Blaster.fire_effect` nutzte die nicht vorhandene Partikelvorlage „sparks“; `--smoke-compile` überspringt `.claude/`.
Entscheidungen: D132 bis D138 (L), D139, D140 (KI); Q27 geschlossen. P1-Plan: Artefakt „Doppelgänger-Gewusel Bauplan“.
Getestet: Unit 38/38, compile, m1, m2, games, hub (40 Prüfungen), Spieltest P1 12 Läufe (Wächter 5/12, 35 bis 90 s); Bildschirmfoto P1 mit Fenster geprüft.
Probleme / Bekannte Fehler: Wackelwaben über dem Draw-Call-Budget (604 von 400, Waben einzeln); Randlicht kostet ca. 30 Draw Calls, auf Handhelds messen (5.9). Handicap- und P1-Werte sind Platzhalter bis zum Controllertest.
Nächster Schritt: Controllertest nach `docs/TESTANLEITUNG_V0_7_2.md` (und offen `TESTANLEITUNG_V0_7_1.md`), danach 7.10.
Aktuelle Kopie liegt in: lokal (Commit), Push nach Rückfrage

## 2026-11-20: Projektordner aufgeräumt

Agent und Umgebung: Claude (Claude Code), lokal mit Git
Erledigt: Versionierte Dateien von 1.706 auf 479. Ungenutzte Asset-Pakete (Castle, Food, Input Prompts, Particle, Toy Car, Quaternius Farm) und ungenutzte Modelle entfernt; Originale bleiben lokal in `assets/_incoming/`, CREDITS angepasst. Bildschirmfotos (19 MB) entfernt, verbindliche Stilvorlagen nach `docs/stil/`, `docs/screenshots/` nicht mehr versioniert. Neues `docs/archiv/`: alte DEVLOG-Einträge, D01 bis D99, erledigte Roadmap-Phasen, Prompts 01 bis 08, alte Testanleitungen, GitHub-Anleitung (alle unverändert verschoben). Pflichtlektüre von ca. 127.000 auf 53.000 Zeichen; `AGENTS.md` mit Projektkarte und schlanker Leseliste, `CLAUDE.md` und README auf den heutigen Ablauf. Entfernt: Cowork-Werkzeug `pack_snapshot.sh`, doppelte CI-Datei, Bildskript `haltepunkt1_smoke`, „Claude outputs“, leere `.gitkeep`.
Getestet: Import sauber; Unit 31/31, compile 151/0, m1, m2, games, hub OK.
Nächster Schritt: wie im Eintrag darunter (Controllertest nach `docs/TESTANLEITUNG_V0_7_1.md`).
Aktuelle Kopie liegt in: GitHub `miniLeonardo/PartyPark` und lokal

## 2026-11-20: Minispiel-Durchsicht – alle 7 Spiele getestet, Fehler und Fairness behoben

Agent und Umgebung: Claude (Claude Code), direkt im Ordner mit Godot 4.7.2 (Windows, echte Grafikkarte); Codeprüfung zweier Spielgruppen durch Unteragenten
Erledigt:
- Neues Werkzeug `tests/smoke/playtest_smoke.gd` (`--smoke-playtest`, D131): jedes Spiel mehrfach mit Computern in allen Stärken plus Läufe mit untätigem Platz 1; misst Dauer, Zeitablauf, Siegverteilung nach Platz, Solo-/Koop-Quote. `MinigameSandbox` gibt den Seed jetzt auch an `Minigame.rng` weiter (wiederholbare Läufe).
- Spielfigur: Am Boden leichter Andruck nach unten. Ohne ihn blieb `is_on_floor()` bei Stillstand wahr, auch wenn der Boden verschwand (Figuren schwebten über gefallenen Waben).
- Autoscooter: Zusammenstöße beidseitig (vorher gewann immer die niedrigere Platznummer: Siege 14 von 16 für Spieler 1+2), gleichzeitig Ausgeschiedene teilen den Platz, Wiedereinstieg mit Abstand zu anderen Wagen, Tastentext korrigiert (A Gas, X Turbo), Turbo-Ring (D128).
- Tauziehen: Seil rastet am Rundenende ein, Zurufe verschwinden, Taktring mittig verankert, D126 (Synchron-Zug ×2, Kraftakt 6 Takte).
- Riese gegen Zwerge: Seilfortschritt nur durch eigenes Umrunden der Zwerge (vorher wickelte der Riese Zwerge durch Vorbeilaufen ein), Seilringe kippen mit, leeres Seil nicht jedes Bild neu gebaut, Warnkreis beim Stampfen (D127).
- Schafe hüten: Wolf versank beim Verjagen im Boden, Schafe liefen nach Rundenende weiter, Zähler flackerte an der Gehege-Öffnung, Kamera schnitt Ecken ab (fov 53), Schubsen (Wolf verjagen) in der Tastenerklärung.
- Wackelwaben: Auch die tragende Nachbarwabe löst aus (vorher überlebte Stillstehen auf einer Fuge ewig: Untätige gewannen 3 von 3), Startpunkte auf Wabenmitten (vorher unterschiedlich: Spieler 1 gewann 0 von 12), Gleichstand bei gleichzeitigem Sturz, Wertung bei Zeitablauf nach zuletzt betretener Ebene, Wasserfläche auf Ausscheidehöhe, Zielregel im Text.
- Heiße Kartoffel: unsichtbare Zaunverlängerung (Zaun war überspringbar, draußen unerreichbar), Rückholung aus der Arena, Opfer sofort aus dem Spiel, Zeitlimit 60 s passend zu info.tres, Bombenträger-Markierung (D128).
- Zerfetzung: Überhitzung griff nie (kühlte zwischen Schüssen), Schüsse gingen an Deckung durch die Kiste (Start jetzt im Auge), Computer-Zielen repariert (keine Zielhilfe für Computer, fester Zielfehler je Ziel, Freigabe 10°), Computer suchen Gegner, Gleichstand nach verteilten Treffern (D130), freie Bildschirmviertel zeigen Trefferübersicht statt Live-Karte und rendern kein 3D, Schatten auf 30 m, Lebenskreise nach `hits_to_out`, Blaster in der Ego-Ansicht mit Mündungsblitz (D129).
- Hub: Ost-Trampolin auf Bodenhöhe (Matte war 0,55 m über dem Rasen, nur springend erreichbar).
Entscheidungen: D126 bis D131 (D130 von Leonardo noch zu bestätigen)
Getestet: Unit 31/31; compile 152/0; m1, m2, games, hub OK. Spieltest 12+6 Läufe je Spiel: Untätige gewinnen nirgends mehr (Wackelwaben, Kartoffel immer Letzter; Zerfetzung Platz 2-3), Siegverteilung Autoscooter [2,5,3,2], Wackelwaben [4,3,4,1], Kartoffel [3,3,3,3]; Riese gewinnt 7/12, Schafe-Team 9/12, Tauziehen ohne Unentschieden. Bildschirmfotos aller Spiele mit echter Grafik geprüft.
Probleme / Bekannte Fehler: Tauziehen zwischen gleich starken Computerteams endet weiter meist per Zeit (mit Menschen zu prüfen). Kleine Reste in ROADMAP 7.10.
Nächster Schritt: Leonardo testet `docs/TESTANLEITUNG_V0_7_1.md` 1-28 mit Controllern, bestätigt D130; danach ROADMAP 7.10 und die Ideenliste aus dem Chat (Auswahl in DECISIONS festhalten).
Aktuelle Kopie liegt in: `C:\Users\wad32muj\Agentenraum\partypark` (Commit lokal)

## 2026-11-20: Spielbarkeit v0.7.1 – Prüfung der Antigravity-Änderungen, Turm neu, Kamera-Leine, Hub-Abläufe

Agent und Umgebung: Claude (Claude Code), direkt im Ordner `C:\Users\wad32muj\Agentenraum\partypark` mit Shell, Git und Godot 4.7.2 (Windows, echte Grafikkarte). Remote `origin` = `https://github.com/miniLeonardo/PartyPark.git` eingerichtet, lokaler Stand per Fast-Forward von 033a95d auf 213ad3b (v0.7 aus Antigravity) gebracht.
Anlass: Leonardo: „Spiel sehr buggy, Lobby nett, aber Aktivitäten wie das Jump'n'Run funktionieren nicht und sind nicht lösbar, Kamera braucht Überarbeitung.“
Befund (Prüfung aller Hub-Dateien, Teile per Unteragent gegengeprüft):
- Import brach ab: `.blend`-Dateien in `assets/_incoming/` ohne `.gdignore` → Godot wollte Blender, fehlende Coaster-Kit-Modelle, Hub startete nicht. Behoben (`.gdignore`, in `.gitignore` freigegeben).
- Turm unlösbar: Plattformen 1 und 2 und das Gipfeldeck lagen als volle Decken über allen Wegen; über Balken 5 nur 1,1 m Luft bei 1,3 m Figurhöhe; „Netze“ hatten keine Kollision. Die alten Tests teleportierten die Figur zur Krone und blieben deshalb grün.
- Minispiele aus dem Park liefen als Kind des Hubs mitten in der Parkwelt (Brunnen im Autoscooter, Rasen fängt Herunterfallende auf, Ausscheiden unmöglich).
- A = Springen = Bestätigen: Springen auf einem Pad startete Spiele; nach Rückkehr standen alle wieder auf dem Pad → Neustart.
- Figur setzt `velocity.x/z` jedes Bild neu: Karussell-Fliehkraft und Rutschenschub wirkten nie. Rutsche verkehrt herum gebaut (Bahn bergauf, Treppe mit Lücke). Trampolin-Matte ohne Kollision, Sprung schon beim seitlichen Hineinlaufen. Pavillon-Platte und Rundenschalter im Podest versteckt; Schalter reagierte auf Computer.
- Keine Stufen: 0,25-0,4 m hohe Kanten (Zonenböden, Karussell, Podest) wirkten als Wand.
- Kamera: zoomte bis 46 m (Figuren winzig), ignorierte die Kletterhöhe; Computer folgten dem ersten Menschen.
- Ansager-Platzhalter `{winner}` am Buzzer nicht ersetzt; `launched_from_hub` blieb nach Abbruch stehen.
Erledigt:
- Fragerunde mit Leonardo: D121 Kamera-Leine, D122 Turm als Außenspirale mit Netz-Etagen, D123 Pad-Start nur „alle drauf + Countdown“, D124 keine Computer im Park; technisch D125 Minispiele in eigener Szene.
- `Player`: Stufenhilfe `step_height` (nur im Park 0,45 m), `push_velocity` für Geräte, `leash_blocks` für die Leine, `landing_speed`, `get_floor_collider()`.
- `Game.play_minigame_from_hub()` / `return_to_hub()` und neue Szene `modes/hub/hub_minigame.tscn`; Rückkehr neben die Bude (`HubMinigameStation.get_return_position()`); `_leave_match()` setzt Hub-Flags zurück.
- `Hub` neu: nur Menschen, Leine (`leash_half_extent`), Tastenhinweise über `InputHints`, Bot-Wanderlogik entfernt.
- `HubTower` neu (Stufentorte: Wege r 10,5/7/4,6 m, Netze r 8,6/5,8 m, Spitze r 3,5 m, je 9 Stufen à 0,67 m, Fahrstuhl-Plattform in Passage 2, Pfähle in Passage 3, Startschild, Höhenschilder, Fahne statt Dach). Alter Turm-Lift, Fahnenmast in Turmmitte und Zuschauer auf dem Turmweg entfernt, Fundament rund (r 12,8).
- `HubCrown`: schwebt in Weltkoordinaten, landet per Strahl auf jeder Fläche, wird auch liegend aufgehoben.
- `HubCamera`: Abstand aus Bildbreite, Tiefe und Höhe (13 bis 32 m), Neigung 50° → 38°.
- Pads: Countdown nur wenn alle Menschen drauf, Abbruch sobald einer geht, kein A-Start. Pavillon: Platte/Schalter auf das Podest, Schalter nur für Menschen, Säulen mit Kollision.
- Rutsche, Trampolin, Karussell (Fliehkraft, feste Mittelsäule), Wippe (max. 16°, nur Mitfahrer), Schwebeplattform (lokale Position), Fähre höher, Teich ohne Z-Fighting.
- `tests/smoke/hub_smoke.gd` neu: steuert Figuren über `AIInput` mit echter Physik (jeder Turmsprung, Netzsturz, Rutsche, Trampolin, Stufenhilfe, Leine, Kamera, Pads, Minispiel-Szene hin und zurück).
Entscheidungen: D121 bis D125; D107, D113, D119 teilweise ersetzt (markiert)
Getestet: Unit 31/31; compile 151/0; m1 OK; m2 OK; games OK; smoke-hub 33/33 (Turm vollständig mit echten Sprüngen gelöst, 0 Fehlsprünge). Bildschirmfotos mit echter Grafik (1280×720, Fenster) von Plaza, Leine, Turm beim Klettern und Spitze geprüft; 200+ fps auf Hoch. Controller nur bei Leonardo prüfbar.
Probleme / Bekannte Fehler: Wer von einer Turmstufe bewusst nach außen rennt, verfehlt das Netz und landet unten (Netze können wegen der Wege darunter nicht breiter sein). Kleine Reste in ROADMAP 7.10. `tests/smoke/haltepunkt1_smoke.gd` ist ein Bildskript, kein Test.
Nächster Schritt: Leonardo testet nach `docs/TESTANLEITUNG_V0_7_1.md`, danach Balance von Turm und Leine; dann ROADMAP 7.10, erst danach v0.8.
Aktuelle Kopie liegt in: `C:\Users\wad32muj\Agentenraum\partypark` (Commit lokal, noch nicht gepusht)

## 2026-10-26: Patch v0.7 Polish Run – Pad-Status, Hub-Kamera, Spieler-Isolation & Logging-System

Agent und Umgebung: Gemini (Antigravity), Windows x86_64 lokal
Erledigt:
- Umfassender Polish-Run für den Freizeitpark-Hub (v0.7) nach Nutzer-Rückmeldung:
  1. Aktivierungs-Plattformen: Vollständiger Zustandsautomat (`IDLE`, `COUNTING`, `TRIGGERED`, `LOCKED`, `COOLDOWN`) in `HubActivationPad`. Beim Minispiel-Start werden alle Pads gesperrt (`lock()`) und bei Rückkehr mit 3.0s Cooldown entsperrt (`unlock(3.0)`). Countdown-Ticks, Abbruch bei Verlassen, leuchtende Emission-Effekte und A-Taste für Sofort-Start.
  2. Hub-Kamera (`HubCamera`): Fokussiert und umschließt primär menschliche Spieler, statt von weit entfernten Plaza-Bots bis ans Limit (46 m) herausgezoomt zu werden. Dynamische Neigung passt sich der tatsächlichen Kletterhöhe an. Schnapp-Funktion (`snap_to_targets()`) verhindert Kamerasprünge bei Szenenrückkehr. Offscreen-Indikatoren drehen nur den Pfeil, halten das P-Label aufrecht und werden während Minispielen sauber ausgeblendet.
  3. Spieler-Isolation & automatische Teilnahme: In `Hub.play_minigame()` werden Hub-Spieler per `p.set_active(false)` aus der Gruppe `players`, Sichtbarkeit und Physik genommen, sodass Minispiele nicht mehr mit 8 Spielern kollidieren. Bei Spielstart werden fehlende Plätze immer per `PlayerRoster.fill_with_cpu()` auf 4 aufgefüllt.
  4. Bot-Navigation korrigiert: Wanderlogik von Computergegnern nutzt `player.world_to_input()`, wodurch Bots zielgenau menschlichen Spielern folgen, anstatt invers wegzulaufen.
  5. Zentrales Logging-System (`core/log.gd`, Autoload `Log`): Gepuffertes Datei-Logging in `user://partypark.log` mit Timestamp, Loglevel und Tag-Filterung (`[HUB]`, `[MATCH]`, `[SYS]`).
  6. Frische Windows-Executable `builds/windows/Partypark.exe` (108.9 MB) fehlerfrei gebaut.
Entscheidungen: D118, D119
Getestet: Unit-Tests 31/31; compile_smoke 149/0; smoke-hub 58/58; smoke-m1 50/50; smoke-m2 39/39; smoke-games 12/12; asset_audit erfolgreich; Windows-Export `builds/windows/Partypark.exe` erfolgreich exportiert.
Probleme / Bekannte Fehler: Neues Git-Repository / Account-Details noch von Leonardo einzutragen bzw. anzugeben.
Nächster Schritt: Git-Remote auf neues Repo umstellen, Committen & Pushen, danach Controllertest v0.7.
Aktuelle Kopie liegt in: PC von Leonardo / lokal in `c:\Users\VM\Desktop\PartyPark`

Ältere Einträge (2026-10-19 bis 2026-10-21): `docs/archiv/DEVLOG_bis_2026-10-21.md`.
