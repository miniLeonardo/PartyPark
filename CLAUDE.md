@AGENTS.md

# Ergänzungen für Claude

> [!NOTE]
> **Hinweis zur Umgebung (Stand 2026-10-21, D89):** Diese Datei beschreibt die historische Arbeitsweise von Claude (Cowork) über die Dateibrücke. Seit dem 21.10.2026 ist Google Antigravity die primäre Entwicklungsumgebung (lokal unter Windows mit echter Hardware und Shell). Claude holt den aktuellen Stand immer über das zentrale Git-Repository (`https://github.com/sudoMrMCaffe/PartyPark.git`).

Alle Regeln aus `AGENTS.md` gelten. Diese Datei beschreibt nur, wie Claude in Cowork mit dem Projektordner auf Leonardos Rechner arbeitet.

## Wo das Projekt liegt

1. **Hauptablage:** `C:\Users\wad32muj\Agentenraum\partypark` auf dem Rechner `ulb-pc10039`. Dieser Ordner ist die einzige maßgebliche Kopie. Das Git-Repository darin legt Leonardo lokal an; Claude kann den Ordner `.git` über die Fernzugriffs-Werkzeuge weder lesen noch schreiben.
2. Der Ordner muss in der Cowork-Sitzung verbunden sein („Ordner hinzufügen“ in der Claude-Desktop-App). Ist er es nicht, Leonardo zu Beginn darum bitten.
3. Im Claude-Projekt „Godot local 4 player“ liegt nur ein Hinweisdokument, keine Projektdateien. Keine Kopien dorthin schreiben, damit keine zweite Version auseinanderläuft.

## Arbeitsweise

### Variante A: Shell auf Leonardos Rechner verfügbar (`device_bash`)

Direkt im Ordner arbeiten: lesen, bearbeiten, `git` ausführen. Für headless Godot-Prüfungen entweder Godot in der lokalen Shell nutzen (falls installierbar) oder nur die nötigen Dateien in die Cloud-Umgebung holen (Variante B).

### Variante B: Nur Dateiübertragung verfügbar (stage/commit)

1. **Sitzung beginnen:** Ordner rekursiv auflisten (`device_list_dir`) und alle Dateien in die Cloud-Umgebung holen (`device_stage_files`, max. 50 Dateien pro Aufruf, `.godot/` und `builds/` auslassen). Die gestagten Dateien landen unter `/mnt/user-data/uploads/partypark/…`; von dort nach `/home/claude/partypark` kopieren. Die `mtimeMs` jeder Datei merken.
2. Godot für Prüfungen bereitstellen (falls nicht vorhanden):
   ```
   mkdir -p /home/claude/godot-bin && cd /home/claude/godot-bin
   curl -sSL -o g.zip https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip
   unzip -q g.zip
   ```
   Danach `/home/claude/godot-bin/Godot_v4.7.2-stable_linux.x86_64 --headless --path /home/claude/partypark --import`
   Für Bildschirmfotos mit echtem 3D-Rendering: `apt-get install -y mesa-vulkan-drivers`, dann mit `xvfb-run -a -s "-screen 0 1920x1080x24" <godot> --path . --rendering-driver vulkan --resolution 960x540 --fixed-fps 60 -- --smoke-m2 --short --shots=<ordner>` (langsam, im Hintergrund starten).
3. In der Cloud-Kopie `git init` ausführen, alles committen und `git tag sync/folder` setzen. Dieses Git dient nur dazu, eigene Änderungen zu erkennen, es ersetzt nicht das Repository im Ordner.
4. In `/home/claude/partypark` arbeiten und dort committen.
5. **Zurückschreiben:** `bash tools/pack_snapshot.sh` listet alle seit dem Tag `sync/folder` geänderten Dateien. Jede geänderte Datei nach `/mnt/user-data/outputs/partypark/<pfad>` kopieren und mit `device_commit_files` an denselben Pfad im Ordner schreiben, für bestehende Dateien mit `expectedMtimeMs`. Danach `git tag -f sync/folder` setzen.
   Wurden neue Skripte mit `class_name` angelegt, zusätzlich `.godot/global_script_class_cache.cfg` aus der Cloud-Kopie (nach `--import`) in den Ordner schreiben. Sonst kennt Godot die neuen Klassen erst nach „Projekt → Aktuelles Projekt neu laden“ im Editor, und das Spiel bricht beim Start mit „Could not find type …“ ab.
6. Leonardo eine passende Commit-Nachricht vorschlagen, damit er die Änderungen lokal committet.
7. Gelöschte oder verschobene Dateien kann Variante B nicht entfernen. Leonardo die betroffenen Pfade nennen, damit er sie selbst löscht.

## Sitzung beginnen (beide Varianten)

1. Prüfen, ob der Projektordner verbunden ist.
2. Pflichtlektüre aus `AGENTS.md` lesen und den Stand kurz zusammenfassen.

## Spieldesignfragen stellen

Nutze für Designentscheidungen das Werkzeug `AskUserQuestion` (bis zu 4 Fragen pro Aufruf, je 2 bis 4 Optionen, Empfehlung als erste Option mit „(Empfohlen)“). Antworten sofort in `docs/DECISIONS.md` eintragen.

## Sitzung oder Meilenstein abschließen

1. DEVLOG, ROADMAP, DECISIONS aktualisieren (siehe `AGENTS.md`).
2. Git-Commit (Variante A direkt im Ordner, Variante B in der Cloud-Kopie plus Commit-Vorschlag für Leonardo).
3. Bei Variante B alle Änderungen in den Ordner zurückschreiben (siehe oben).
4. Leonardo die Testanleitung geben und sagen, welche Dateien sich geändert haben.

## Grenzen dieser Umgebung

1. Controller können in der Cloud nicht getestet werden, nur Leonardo kann das am eigenen Rechner.
2. Der Projektordner liegt auf einem Arbeitsrechner. Für Tests auf Bazzite oder die Übergabe an Antigravity auf einem anderen PC empfiehlt sich ein privates Git-Repository als Austauschweg (offene Frage Q09).
