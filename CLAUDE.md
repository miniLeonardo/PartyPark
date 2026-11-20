@AGENTS.md

# Ergänzungen für Claude

Alle Regeln aus `AGENTS.md` gelten. Hier steht nur, was speziell für Claude gilt.

## Arbeitsweise (Stand 2026-11-20)

1. Claude arbeitet direkt im Projektordner `C:\Users\wad32muj\Agentenraum\partypark` mit Shell, Git und Godot (Claude Code). Der frühere Ablauf über die Cowork-Dateibrücke (Variante B, `sync/folder`) ist abgeschafft; Details stehen nur noch in der Git-Historie.
2. Zu Beginn: `git status` und `git pull`, dann die Pflichtlektüre aus `AGENTS.md`.
3. Godot liegt im Projektordner: `./Godot_v4.7.2-stable_win64_console.exe --headless --path . ...` (Befehle in `AGENTS.md`). Headless-Läufe immer mit Zeitlimit starten (`timeout 600 ...`), damit ein hängender Test nicht blockiert.
4. Prozesse nur über ihre eigene PID beenden, nie per Programmname (Leonardo hat eventuell den Godot-Editor offen).
5. Bildschirmfotos mit echter Grafik: Smoke-Tests mit Fenster und `--shots=<ordner>` (z. B. `--smoke-games --short --shots=docs/screenshots/check`). Der Ordner ist nicht versioniert.
6. Designfragen mit dem Werkzeug `AskUserQuestion` stellen (bis zu 4 Fragen, Empfehlung als erste Option mit „(Empfohlen)“), Antworten sofort in `docs/DECISIONS.md` eintragen.
7. Für breite Prüfungen (mehrere Minispiele, viele Dateien) Unteragenten parallel einsetzen und ihnen die Projektkarte aus `AGENTS.md` mitgeben.

## Sitzung abschließen

1. DEVLOG (kurz), ROADMAP, DECISIONS aktualisieren.
2. Alle Testsuiten laufen lassen (Liste in `AGENTS.md`), bei Minispiel-Änderungen zusätzlich `--smoke-playtest`.
3. Commit auf Deutsch; pushen nach Rückfrage.
4. Leonardo eine nummerierte Testanleitung geben und sagen, welche Dateien sich geändert haben.

## Grenzen

Controller, Vibration, Klang und echte Bildrate auf Leonardos Geräten kann nur Leonardo prüfen.
