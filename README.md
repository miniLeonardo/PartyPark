# Partypark

Lokales 3D-Partyspiel für bis zu 4 Spieler mit Controllern, inspiriert von Mario Party, Wii Party und Nintendo Land. Gebaut mit Godot 4.7 für Windows und Linux (Bazzite).

Status: Version 0.4 „Spieleabend“ mit Titel, Beitritt, Hauptmenü, Optionen, Schnellturnier, Freiem Spiel, Effekten, selbst erzeugten Geräuschen, Ansager und sieben Minispielen (Autoscooter, Tauziehen, Riese gegen Zwerge, Schafe hüten, Wackelwaben, Heiße Kartoffel, Zerfetzung mit Splitscreen). Test mit Controllern und auf Bazzite steht aus. Aktueller Stand immer im obersten Eintrag von [`docs/DEVLOG.md`](docs/DEVLOG.md).

## Schnellstart

1. Godot **4.7.x** (Standard-Version, nicht .NET) von godotengine.org herunterladen.
   Bazzite: am einfachsten als Flatpak `org.godotengine.Godot` über die Softwareverwaltung.
2. Godot starten, „Importieren“ wählen und die Datei `project.godot` in diesem Ordner öffnen.
3. Spiel starten mit F5 (Titel → A drücken → Beitritt → Start → Hauptmenü). Ohne Controller: Leertaste bzw. Enter lassen zwei Tastatur-Debugspieler beitreten (Belegung in `docs/DECISIONS.md`, D22).

## Dokumente

| Datei | Wofür |
|---|---|
| [`AGENTS.md`](AGENTS.md) | Regeln für jede KI, die am Projekt arbeitet (wird von Antigravity automatisch gelesen) |
| [`CLAUDE.md`](CLAUDE.md) | Zusatzregeln für Claude in Cowork, verweist auf AGENTS.md |
| [`docs/GAME_DESIGN.md`](docs/GAME_DESIGN.md) | Spielidee, Teamformate, Minispiel-Pool |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | technischer Aufbau |
| [`docs/DECISIONS.md`](docs/DECISIONS.md) | alle Entscheidungen und offenen Fragen |
| [`docs/ROADMAP.md`](docs/ROADMAP.md) | Phasen und Meilensteine mit Status |
| [`docs/DEVLOG.md`](docs/DEVLOG.md) | Tagebuch: was wann von wem gemacht wurde, nächster Schritt |
| [`docs/MINIGAME_GUIDE.md`](docs/MINIGAME_GUIDE.md) | Bauanleitung für neue Minispiele |
| [`docs/PERFORMANCE.md`](docs/PERFORMANCE.md) | Messmodus und Leistungsmesswerte |
| [`docs/GITHUB_ANLEITUNG.md`](docs/GITHUB_ANLEITUNG.md) | privates GitHub-Repository mit automatischen Tests |
| [`docs/EXPORT_UND_BAZZITE.md`](docs/EXPORT_UND_BAZZITE.md) | Exportieren und Test auf Bazzite |
| [`docs/TESTANLEITUNG_V0_4.md`](docs/TESTANLEITUNG_V0_4.md) | aktuelle Testanleitung |
| [`docs/prompts/`](docs/prompts/) | fertige Prompts für KI-Sitzungen |

## Weiterarbeiten mit einer anderen KI oder auf einem anderen PC

Der gesamte Kontext steckt in den Dateien, nicht im Chatverlauf. So gelingt der Wechsel:

1. **Aktuelle Kopie holen.** Maßgeblich ist der Ordner `C:\Users\wad32muj\Agentenraum\partypark`. Auf einen anderen PC kommt er per Git-Repository (empfohlen, sobald eingerichtet) oder als kopierter Ordner inklusive `.git`.
2. **Ordner in Antigravity öffnen.** `AGENTS.md` im Projektstamm wird automatisch als Regeldatei geladen.
3. **Erster Prompt in der neuen Umgebung:**
   > Lies AGENTS.md und befolge die Pflichtlektüre. Fasse mir den Stand zusammen und schlage den nächsten Schritt aus der ROADMAP vor. Stelle Spieldesignfragen immer mir.
4. **Im DEVLOG vermerken**, dass die Arbeit jetzt in der neuen Umgebung stattfindet, damit nicht zwei Kopien auseinanderlaufen.
5. Godot 4.7.x auf dem neuen PC installieren und das Projekt importieren. Der Ordner `.godot/` wird dabei automatisch neu erzeugt.

## Git

Einmalig im Projektordner einrichten (Git für Windows vorausgesetzt):

```
cd C:\Users\wad32muj\Agentenraum\partypark
git init -b main
git add -A
git commit -m "Phase 0: Projektgerüst und KI-Übergabedoku"
```

Commit-Nachrichten auf Deutsch mit Meilenstein-Präfix, z. B. `M1: Beitrittsbildschirm`. Für die dauerhafte Ablage mit Grafiken und Sounds empfiehlt sich ein privates Repository auf GitHub oder einem ähnlichen Dienst (offene Frage Q09).
