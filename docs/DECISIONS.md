# Partypark: Entscheidungen und offene Fragen

Neue Einträge unten anfügen, alte nie löschen. Überholte Entscheidungen mit „ersetzt durch Dxx“ markieren.
Spalte „Von“: **L** = Leonardo, **KI** = technische Entscheidung eines Agenten (Name und Umgebung in Klammern).

## Entscheidungen

| ID | Datum | Entscheidung | Begründung | Von |
|---|---|---|---|---|
| D01 | 2026-10-19 | Engine Godot 4.6.x, GDScript, kein .NET | Open Source, nativer Export für Windows und Linux, Textdateien gut für KI-Arbeit | L |
| D02 | 2026-10-19 | 3D-Spiel | Wunsch von Leonardo | L |
| D03 | 2026-10-19 | Bis zu 4 lokale Spieler mit Gamepads, ein Bildschirm, kein Splitscreen | Couch-Erlebnis, einfacher und performanter auf Handhelds | L |
| D04 | 2026-10-19 | Zielplattformen Windows und Linux (Bazzite) | Wunsch von Leonardo | L |
| D05 | 2026-10-19 | Teamformate: 4 gegen Computer, Jeder gegen jeden, 2 gegen 2, 1 gegen 3 (asymmetrisch) | Abwechslung wie bei Nintendo-Minispielsammlungen | L |
| D06 | 2026-10-19 | Arbeitstitel „Partypark“ | Wunsch von Leonardo, später änderbar | L |
| D07 | 2026-10-19 | Projektstruktur feature-basiert, `AGENTS.md` als zentrale KI-Regeldatei, Doku in `docs/` | Wechsel zwischen Claude und Antigravity ohne Kontextverlust | L |
| D08 | 2026-10-19 | Spieldesignentscheidungen werden immer bei Leonardo erfragt | Wunsch von Leonardo | L |
| D09 | 2026-10-19 | Jolt Physics als 3D-Physik | stabiler und schneller als die alte Godot-Physik, seit 4.4 integriert | KI (Claude, Cowork) |
| D10 | 2026-10-19 | Renderer Forward+, Fenster 1280×720, interne Auflösung 1920×1080 | Standard für 3D; Mobile als Ausweichoption für Handhelds | KI (Claude, Cowork) |
| D11 | 2026-10-19 | Eingabe über eigene `InputSource`-Abstraktion pro Spieler statt globaler Aktionen | Godot-Aktionen unterscheiden keine Controller; Computergegner nutzen dieselbe Schnittstelle | KI (Claude, Cowork) |
| D12 | 2026-10-19 | Erste Spielart ist das Schnellturnier | schnellster Weg, jedes neue Minispiel zu testen | L (Empfehlung angenommen) |
| D13 | 2026-10-19 | Code und Bezeichner Englisch, Kommentare und Doku Deutsch | KI-Werkzeuge arbeiten mit englischen Bezeichnern am zuverlässigsten, Doku bleibt für Leonardo lesbar | KI (Claude, Cowork) |
| D14 | 2026-10-19 | Hauptablage ist der Ordner `C:\Users\wad32muj\Agentenraum\partypark` auf `ulb-pc10039`, nicht das Claude-Projekt | Wunsch von Leonardo; echte Dateien, direkt für Godot, Git und Antigravity nutzbar | L |
| D15 | 2026-10-19 | Spielfigur: eigene runde Knubbelfigur (Bohnen-/Kapselform, große Augen), Spielerfarbe färbt den ganzen Körper (Q02) | aus Grundformen sofort baubar, gut lesbar aus jeder Kamerahöhe, eigenständiger Stil | L (Empfehlung angenommen) |
| D16 | 2026-10-19 | Bewegungsgefühl: knackige, präzise Steuerung; Wackeln, Squash und Stretch nur optisch am Modell (Q02) | fair in kompetitiven Minispielen und trotzdem lustig | L (Empfehlung angenommen) |
| D17 | 2026-10-19 | Thema Freizeitpark, Grafikstil Low-Poly; freie Kenney-/Quaternius-Pakete erst nach Zustimmung und Klärung von Q09 (Q03) | passt zum Namen, Hub aus Q01 bleibt möglich | L (Empfehlung angenommen) |
| D18 | 2026-10-19 | Gamepad-Belegung (Position wie Xbox-Pad): A `jump`, X `push`, B `action`, Y `special`, Start `pause`; in Menüs A `confirm`, B `back` (Q04) | Springen und Schubsen nebeneinander unter dem Daumen | L (Empfehlung angenommen) |
| D19 | 2026-10-19 | Computergegner füllen fehlende Plätze auf 4 auf, im Beitrittsbildschirm umschaltbar, Standard an (Q08) | 2v2 und 1v3 brauchen 4 Plätze; reine Menschenrunden bleiben möglich | L (Empfehlung angenommen) |
| D20 | 2026-10-19 | Beitritt: A tritt bei, B tritt aus; sobald mindestens ein Mensch beigetreten ist, startet jeder Beigetretene mit Start | schnell, keine Hostrolle | L (Empfehlung angenommen) |
| D21 | 2026-10-19 | Pause-Menü: jeder kann pausieren, jeder kann navigieren und fortsetzen; Inhalt vorerst Weiter, Zurück zum Beitritt, Spiel beenden | Wunsch von Leonardo (abweichend von der Empfehlung „wer öffnet, bedient“) | L |
| D22 | 2026-10-19 | Tastatur-Debugspieler spiegeln das Gamepad: Spieler „Tastatur links“ WASD, Leertaste = A, E = B, F = X, Q = Y, Esc = Start; Spieler „Tastatur rechts“ Pfeiltasten, Num0 oder Enter = A, Num2 oder Rücktaste = B, Num1 oder Ö = X, Num3 oder Ä = Y, Num+ oder P = Start (physische Tastenpositionen). Nur in Debug-Builds | Testen ohne Controller | KI (Claude, Cowork) |
| D23 | 2026-10-19 | Doppelt erkannte Controller (Steam Input: echtes plus virtuelles Pad) werden beim Beitritt abgefangen: Drücken mehrere freie Geräte im selben Frame Bestätigen, tritt nur eines bei | sonst belegt ein Controller zwei Plätze | KI (Claude, Cowork) |
| D24 | 2026-10-19 | `InputSource` merkt sich Tastendrücke aus Eingabe-Ereignissen zwischen zwei Abfragen („Latch“), zusätzlich zur Zustandsabfrage | sehr kurze Drücke gehen bei niedriger Bildrate (Handheld) sonst verloren | KI (Claude, Cowork) |
| D25 | 2026-10-19 | Hauptszene ist direkt `ui/join_screen/join_screen.tscn`, kein separates `main.tscn`; Szenenwechsel, Pause und Verbindungs-Pause liegen im Autoload `Game` | weniger Zwischenschichten; ARCHITECTURE angepasst | KI (Claude, Cowork) |
| D26 | 2026-10-19 | Menüs (Beitritt, Pause) navigieren über `InputSource` mit abgeleiteten Aktionen `nav_up/down/left/right`, nicht über Godot-Fokus und `ui_*`-Aktionen | Godots UI-Aktionen reagieren auf alle Geräte gleichzeitig und umgehen die Spielerzuordnung | KI (Claude, Cowork) |
| D27 | 2026-10-19 | Automatischer Durchlauf `tests/smoke/m1_smoke.gd` mit simulierten Tastatur- und Gamepad-Ereignissen, Start über `-- --smoke-m1` | prüft Beitritt, Steuerung, Pause, Verbindungsabbruch ohne echte Controller | KI (Claude, Cowork) |

## Offene Fragen

Beim Klären in die Tabelle oben übernehmen und hier als erledigt markieren.

| ID | Frage | Wann klären | Status |
|---|---|---|---|
| Q01 | Herzstück langfristig: Freizeitpark-Hub oder Brettspiel? | vor Phase 4 | offen |
| Q02 | Welche Spielfigur (Tier, Kartoffel, Roboter, Männchen …) und wie wackelig/physikalisch? | Beginn Prototyp | erledigt (D15, D16) |
| Q03 | Thema und Grafikstil (Low-Poly mit Kenney/Quaternius vorgeschlagen) | Beginn Prototyp | erledigt (D17) |
| Q04 | Tastenbelegung der abstrakten Aktionen | Beginn Prototyp | erledigt (D18) |
| Q05 | Welche 4 Minispiele im Vertical Slice? (Vorschlag: Eisscholle, Ruderboot, Geisterhaus, Staubsauger-Boss) | Beginn Prototyp | offen |
| Q06 | Punktesystem und Turnierlänge | Meilenstein Turnier | offen |
| Q07 | Gewichtung der Teamformate und Aufholmechanik | Meilenstein Turnier | offen |
| Q08 | Fehlende Spieler mit Computergegnern auffüllen? | Meilenstein Kern | erledigt (D19) |
| Q09 | Privates Git-Repository (z. B. GitHub) als Austauschweg zwischen Arbeitsrechner, Spiele-PC/Bazzite und Antigravity? | vor erstem Test auf Bazzite | offen |
| Q10 | Spielerfarben bestätigen (Platzhalter: Blau, Zinnoberrot, Gelb, Blaugrün aus der farbsehschwächen-sicheren Okabe-Ito-Palette) | nach Test M1 | offen |
| Q11 | Platzhalter im Beitrittsbildschirm bestätigen: Titel „PARTYPARK“, Y schaltet Computergegner um, Texte der Hinweiszeile | nach Test M1 | offen |
| Q12 | Bewegungswerte nach dem ersten Controllertest feinjustieren (Tempo 7 m/s, Sprunghöhe ca. 1,7 m, Schubsstärke 12 m/s, Kamera) | nach Test M1 | offen |
