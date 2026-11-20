# Partypark

Lokales 3D-Partyspiel für bis zu 4 Spieler mit Controllern, inspiriert von Mario Party, Wii Party und Nintendo Land. Gebaut mit Godot 4.7 für Windows und Linux (Bazzite).

Stand: Version 0.7.1. Ein begehbarer Freizeitpark dient als Lobby, mit Kletterturm, Spielplatz, Minispiel-Buden und Turnier-Pavillon. Dazu kommen sieben Minispiele (Autoscooter, Tauziehen, Riese gegen Zwerge, Schafe hüten, Wackelwaben, Heiße Kartoffel, Zerfetzung), Schnellturnier und Freies Spiel. Den aktuellen Stand nennt immer der oberste Eintrag in [`docs/DEVLOG.md`](docs/DEVLOG.md).

## Schnellstart

1. Godot **4.7.x** (Standard, nicht .NET) installieren. Unter Windows reicht `Godot_v4.7.2-stable_win64.exe` im Projektordner, unter Bazzite das Flatpak `org.godotengine.Godot`.
2. Projekt importieren (`project.godot`) und mit F5 starten: Titel → A → Beitritt → Start → Hauptmenü. Ohne Controller treten mit Leertaste bzw. Enter zwei Tastatur-Spieler bei.
3. Direktstarts: `-- --hub` (Park), `-- --play=<minispiel-id>` (ein Minispiel).

## Dokumente

| Datei | Wofür |
|---|---|
| [`AGENTS.md`](AGENTS.md) | Regeln, Befehle und Projektkarte für jede KI (Antigravity liest sie automatisch) |
| [`CLAUDE.md`](CLAUDE.md) | Zusätze für Claude |
| [`docs/DEVLOG.md`](docs/DEVLOG.md) | Tagebuch: Stand und nächster Schritt |
| [`docs/ROADMAP.md`](docs/ROADMAP.md) | Versionsplan mit Status |
| [`docs/DECISIONS.md`](docs/DECISIONS.md) | Entscheidungen ab D100 und offene Fragen |
| [`docs/GAME_DESIGN.md`](docs/GAME_DESIGN.md) | Spielidee, Formate, Ideenspeicher |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | technischer Aufbau |
| [`docs/ART_GUIDE.md`](docs/ART_GUIDE.md) | verbindlicher Grafikstil (Vorlagen in `docs/stil/`) |
| [`docs/MINIGAME_GUIDE.md`](docs/MINIGAME_GUIDE.md) | Bauanleitung für neue Minispiele |
| [`docs/TESTANLEITUNG_V0_7_1.md`](docs/TESTANLEITUNG_V0_7_1.md) | aktuelle Testanleitung |
| [`docs/EXPORT_UND_BAZZITE.md`](docs/EXPORT_UND_BAZZITE.md), [`docs/PERFORMANCE.md`](docs/PERFORMANCE.md) | Export, Bazzite, Leistung |
| [`docs/ASSET_QUELLEN.md`](docs/ASSET_QUELLEN.md) | freie Asset-Quellen mit Lizenzen |
| [`docs/archiv/`](docs/archiv/) | Abgeschlossenes: alte DEVLOG-Einträge, D01 bis D99, erledigte Phasen, Prompts, alte Testanleitungen |

## Weiterarbeiten auf einem anderen PC oder mit einer anderen KI

1. `git clone https://github.com/miniLeonardo/PartyPark.git`, Godot 4.7.x installieren, Projekt einmal importieren.
2. Erster Prompt: „Lies AGENTS.md und befolge die Pflichtlektüre. Fasse mir den Stand zusammen und schlage den nächsten Schritt vor. Spieldesignfragen stellst du mir.“
3. Den Umgebungswechsel im DEVLOG vermerken.

Commit-Nachrichten auf Deutsch, z. B. `v0.8: Joker-Karten`.
