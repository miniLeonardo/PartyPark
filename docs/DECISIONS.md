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

## Offene Fragen

Beim Klären in die Tabelle oben übernehmen und hier als erledigt markieren.

| ID | Frage | Wann klären | Status |
|---|---|---|---|
| Q01 | Herzstück langfristig: Freizeitpark-Hub oder Brettspiel? | vor Phase 4 | offen |
| Q02 | Welche Spielfigur (Tier, Kartoffel, Roboter, Männchen …) und wie wackelig/physikalisch? | Beginn Prototyp | offen |
| Q03 | Thema und Grafikstil (Low-Poly mit Kenney/Quaternius vorgeschlagen) | Beginn Prototyp | offen |
| Q04 | Tastenbelegung der abstrakten Aktionen | Beginn Prototyp | offen |
| Q05 | Welche 4 Minispiele im Vertical Slice? (Vorschlag: Eisscholle, Ruderboot, Geisterhaus, Staubsauger-Boss) | Beginn Prototyp | offen |
| Q06 | Punktesystem und Turnierlänge | Meilenstein Turnier | offen |
| Q07 | Gewichtung der Teamformate und Aufholmechanik | Meilenstein Turnier | offen |
| Q08 | Fehlende Spieler mit Computergegnern auffüllen? | Meilenstein Kern | offen |
| Q09 | Privates Git-Repository (z. B. GitHub) als Austauschweg zwischen Arbeitsrechner, Spiele-PC/Bazzite und Antigravity? | vor erstem Test auf Bazzite | offen |
