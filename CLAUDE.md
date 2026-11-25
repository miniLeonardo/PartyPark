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

## Planung im Nextcloud-Deck (seit 2026-11-22)

Leonardos zentraler Planungsort ist das Deck seiner Nextcloud (xorbi.de, Board „PartyPark“, ID 6, Listen Ideen → ▶ Für Claude → In Arbeit → Für Leonardo: testen & prüfen → Fertig, dazu „Nicht umsetzten/ verworfen“). Roadmap-Punkte stehen dort mit ihrer Nummer aus `docs/ROADMAP.md` im Titel (z. B. „8.1 Joker-Karten“), Minispiel- und sonstige Ideen mit ihrer Nummer aus `docs/IDEEN.md` (M…, P…). Neue Idee = neue Nummer in `docs/IDEEN.md` und neue Karte in „Ideen“; Statuswechsel = Karte verschieben. Alle Ideen bleiben Vorschlag (D08).

1. Zu Beginn jeder Sitzung, ohne dass Leonardo darauf hinweist, die Liste „▶ Für Claude“ lesen. Die Karte „ℹ So funktioniert diese Liste“ ist kein Auftrag. Liegen Karten dort, Leonardo kurz nennen, was ansteht, und von oben nach unten umsetzen; seine aktuelle Bitte im Chat geht vor.
2. Beim Start die Karte nach „In Arbeit“, am Ende nach „Für Leonardo: testen & prüfen“ (Controllertest, Entscheidung, Handgriff von ihm) oder „Fertig“, jeweils mit kurzer Notiz (Version, Ergebnis).
3. Zugriff (seit 2026-11-24, bevorzugt): REST-API als Nextcloud-Benutzer `claude`, ohne SSH: `powershell -NoProfile -File C:\Users\wad32muj\Agentenraum\_nextcloud-deck\deck.ps1 todo 6` (Aufträge), `... move KARTEN-ID "Liste" "Notiz"`, weitere Befehle im Kopf von `deck.ps1`, Hinweise in der README daneben. `deck.env` nie ausgeben oder kopieren.
4. Älterer Zugriff (nur falls die API nicht geht): Leonardo öffnet die PuTTY-Verknüpfung „Goneo (Claude)“ (liegt in `C:\Users\wad32muj\Agentenraum\LeoWeb`) und meldet sich an, danach ohne Passwort `plink -share -batch -load goneo "BEFEHL"`. Nie nach Passwörtern fragen, nie `-pw`. Werkzeug: `C:\Users\wad32muj\Agentenraum\LeoWeb\dashboard\tools\deck-card.php` nach `~/htdocs/_mcd/tmp/` kopieren, in `~/htdocs/cloud` mit `php8.4 -d memory_limit=512M ~/htdocs/_mcd/tmp/deck-card.php todo 6` (Aufträge) bzw. `move KARTEN-ID "Liste" "Notiz"` ausführen, danach `~/htdocs/_mcd/tmp` leeren. PHP über stdin stürzt bei goneo ab. Vor Änderungen am Deck die Tabellen `oc_deck_*` sichern; Anleitung und Fallstricke stehen in `C:\Users\wad32muj\Agentenraum\LeoWeb\CLAUDE.md`, Abschnitt „Planung im Nextcloud-Deck“. Auf goneo nur in `~/htdocs/_mcd` schreiben.

## Grenzen

Controller, Vibration, Klang und echte Bildrate auf Leonardos Geräten kann nur Leonardo prüfen.
