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
