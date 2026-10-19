# Partypark: Regeln für KI-Agenten

Diese Datei ist die zentrale Arbeitsanweisung für jede KI, die an diesem Projekt arbeitet (Claude, Google Antigravity/Gemini oder andere). `CLAUDE.md` verweist hierher. Antigravity liest `AGENTS.md` im Projektstamm automatisch als Regeldatei. Halte diese Datei unter 12.000 Zeichen.

## Projekt in einem Satz

Partypark ist ein lokales 3D-Partyspiel im Stil der Nintendo-Minispielsammlungen (Mario Party, Wii Party, Nintendo Land) für bis zu 4 Spieler an einem Bildschirm mit Controllern, gebaut mit Godot 4.6 für Windows und Linux (Bazzite).

## Pflichtlektüre zu Beginn jeder Sitzung

Lies in dieser Reihenfolge, bevor du Code änderst:

1. `AGENTS.md` (diese Datei)
2. `docs/DEVLOG.md`, mindestens den letzten Eintrag: aktueller Stand und nächster Schritt
3. `docs/ROADMAP.md`: wo stehen wir, was ist als Nächstes dran
4. `docs/DECISIONS.md`: was ist bereits entschieden, was ist offen
5. Bei Bedarf `docs/GAME_DESIGN.md` (Spielinhalt) und `docs/ARCHITECTURE.md` (Technik)

Fasse dem Nutzer danach in zwei bis drei Sätzen zusammen, wo das Projekt steht, und bestätige den nächsten Schritt.

## Goldene Regeln

1. **Spieldesign entscheidet Leonardo.** Bevor du etwas umsetzt, das beeinflusst, wie sich das Spiel spielt, anfühlt, aussieht oder anhört, frage nach. Biete 2 bis 4 konkrete Optionen an, markiere deine Empfehlung und begründe sie in einem Satz. Bündle mehrere Fragen, statt einzeln nachzuhaken. Bis zur Antwort darfst du an technisch unabhängigen Teilen weiterarbeiten oder einen klar gekennzeichneten Platzhalter verwenden.
2. **Was als Spieldesignentscheidung gilt:** Steuerung und Tastenbelegung, Bewegungsgefühl (Tempo, Sprunghöhe, Trägheit), Kameraperspektive, Regeln, Siegbedingungen und Punktevergabe eines Minispiels, Dauer von Runden, Teamzuweisung, Schwierigkeit und Verhalten der KI-Gegner, Figuren, Thema, Grafikstil, Farben, Sound und Musik, Texte und Namen, Menüabläufe, Auswahl und Reihenfolge der Minispiele.
3. **Technische Entscheidungen** (Code-Struktur, Benennung, Algorithmen, Hilfsklassen) triffst du selbst. Größere Weichenstellungen trägst du in `docs/DECISIONS.md` ein.
4. **Kontext sichern.** Eine Sitzung oder ein Meilenstein ist erst abgeschlossen, wenn `docs/DEVLOG.md` (neuer Eintrag oben), `docs/ROADMAP.md` (Status) und `docs/DECISIONS.md` (neue Entscheidungen und offene Fragen) aktualisiert sind. Schreibe so, dass eine andere KI auf einem anderen PC ohne Chatverlauf weitermachen kann.
5. **Immer lauffähig.** Das Projekt muss nach jedem Schritt fehlerfrei starten. Lieber kleine, getestete Schritte als große Umbauten.
6. **Keine neuen Abhängigkeiten ohne Rückfrage.** Addons, Plugins und fremde Assets nur nach Zustimmung. Erlaubte Lizenzen: CC0, CC-BY, MIT, vergleichbar freie. Jede fremde Datei wird in `assets/CREDITS.md` mit Quelle und Lizenz eingetragen.
7. **Doku nicht umschreiben, sondern ergänzen.** Alte Einträge in DEVLOG und DECISIONS bleiben stehen. Überholte Entscheidungen werden als „ersetzt durch Dxx“ markiert.

## Technik

| Bereich | Festlegung |
|---|---|
| Engine | Godot 4.6.x (Standard-Build, kein .NET) |
| Sprache | GDScript mit statischer Typisierung |
| Physik | Jolt Physics (in `project.godot` gesetzt) |
| Renderer | Forward+; bei Performanceproblemen auf Handhelds ist Mobile die Ausweichoption |
| Zielplattformen | Windows x86_64 und Linux x86_64 (Bazzite, auch Handhelds wie Steam Deck) |
| Eingabe | bis zu 4 Gamepads gleichzeitig, Tastatur nur als Debug-Eingabe |
| Bildschirm | ein gemeinsamer Bildschirm, kein Splitscreen |

### Nützliche Befehle

```
# Projekt importieren und auf Ladefehler prüfen (ohne Fenster)
godot --headless --path . --import

# Einzelnes Skript auf Syntaxfehler prüfen
godot --headless --path . --check-only --script res://pfad/zum/skript.gd

# Automatische Tests (sobald vorhanden)
godot --headless --path . --script res://tests/run_tests.gd
```

`godot` steht für die Programmdatei von Godot 4.6.x auf dem jeweiligen System.

## Code-Konventionen

1. Offizieller GDScript-Styleguide: Dateien und Ordner `snake_case`, Klassen `PascalCase` mit `class_name`, Funktionen und Variablen `snake_case`, Konstanten `UPPER_SNAKE_CASE`.
2. Statische Typen überall (`var speed: float = 6.0`, `func get_team() -> int:`).
3. Signale im Perfekt benannt (`player_joined`, `round_finished`).
4. Spielwerte nicht im Code verstecken, sondern als `@export` oder Konstante oben in der Datei, damit Leonardo sie im Editor tunen kann.
5. Bezeichner und Code auf Englisch, Kommentare und Dokumentation auf Deutsch.
6. Eine Szene, ein Hauptskript mit gleichem Namen daneben (`player.tscn` und `player.gd`).
7. **Eingabe:** Gameplay-Code fragt niemals globale Aktionen wie `ui_accept` oder `Input.is_action_pressed()` ohne Gerätebezug ab. Jede Spielereingabe läuft über den zentralen InputRouter (siehe `docs/ARCHITECTURE.md`), der Controller-IDs festen Spielerplätzen zuordnet.
8. Neue Minispiele folgen der Vorlage in `minigames/` und werden über ihre Beschreibungsdatei registriert, nicht per Hand in Menüs eingetragen.

## Ordnerstruktur

| Ordner | Inhalt |
|---|---|
| `core/` | spielweite Systeme: Eingabe, Spieler- und Teamverwaltung, Minispiel-Framework, Autoloads |
| `player/` | Spielfigur, Steuerung, Animationen, Fähigkeiten |
| `minigames/<id>/` | je ein Minispiel: Szene, Skripte, Beschreibungsdatei, eigene Assets |
| `modes/` | Spielarten, die Minispiele aneinanderreihen (Schnellturnier, später Hub und Brettspiel) |
| `ui/` | Menüs, HUD, Regelbildschirm, Ergebnisbildschirm |
| `assets/` | gemeinsam genutzte Modelle, Audio, Schriften, Texturen; `CREDITS.md` für Lizenzen |
| `tests/` | automatische Tests, die headless laufen |
| `tools/` | Hilfsskripte (Export, Packen) |
| `docs/` | Kontext für Menschen und KIs, von Godot ignoriert |
| `builds/` | Export-Ergebnisse, nicht versioniert |

## Testen

1. Nach jeder Änderung: headless Import ohne Fehler und Warnungen im eigenen Code.
2. Logik, die sich ohne Fenster prüfen lässt (Teamzuweisung, Punkte, Turnierablauf), bekommt Tests in `tests/`.
3. Controller-Tests kann nur Leonardo am echten Rechner machen. Formuliere nach jedem Meilenstein eine kurze, nummerierte Testanleitung für ihn und trage das Ergebnis in den DEVLOG ein.
4. Für Tests mit weniger als 4 Controllern gibt es Debug-Spieler (Tastatur oder Dummy), die nur in Debug-Builds verfügbar sind.

## Arbeitsumgebungen

1. **Hauptablage:** `C:\Users\wad32muj\Agentenraum\partypark` auf Leonardos Rechner `ulb-pc10039`. Git-Commits entstehen dort lokal (Leonardo, Antigravity oder eine lokale Shell). Claude (Cowork) arbeitet über den verbundenen Ordner, Details in `CLAUDE.md`.
2. **Antigravity oder andere IDE:** Ordner öffnen, `AGENTS.md` wird automatisch gelesen. Git-Historie liegt im Ordner `.git`.
3. Wechselt die Umgebung, wird das im DEVLOG vermerkt, damit klar ist, welche Kopie die aktuelle ist.

## Definition of Done für eine Aufgabe

1. Projekt startet ohne Fehler, headless Import ist sauber.
2. Neue Spielwerte sind im Editor einstellbar.
3. Offene Designfragen wurden gestellt oder sind als Platzhalter dokumentiert.
4. DEVLOG, ROADMAP und DECISIONS sind aktualisiert.
5. Git-Commit mit aussagekräftiger Nachricht auf Deutsch, zum Beispiel `M1: Controller-Beitritt und Spielerfarben`.
