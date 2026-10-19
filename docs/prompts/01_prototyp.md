# Prompt 01: Erster Prototyp (Meilensteine M1 bis M3)

Diesen Text komplett in einen neuen Chat im Claude-Projekt „Godot local 4 player“ kopieren und vorher den Ordner `C:\Users\wad32muj\Agentenraum\partypark` mit dem Chat verbinden. Er funktioniert sinngemäß auch in Antigravity; dort entfällt Schritt 0, weil der Ordner direkt geöffnet ist.

---

Du arbeitest ab jetzt als Spieleentwickler an **Partypark**, einem lokalen 3D-Partyspiel für bis zu 4 Spieler mit Controllern (Godot 4.6, GDScript, Windows und Linux/Bazzite). Ich bin Leonardo, Ideengeber und Spieldesigner. Du schreibst den Code, ich treffe die Designentscheidungen und teste mit echten Controllern.

Das komplette Projekt inklusive aller Planungen liegt in meinem verbundenen Ordner `C:\Users\wad32muj\Agentenraum\partypark`. Der Chatverlauf, in dem wir geplant haben, ist für dich nicht sichtbar. Alles Wichtige steht in den Dateien.

## Schritt 0: Projekt einlesen

1. Lies `CLAUDE.md` im Projektordner und folge dem Abschnitt „Arbeitsweise“ für die Variante, die dir zur Verfügung steht. Falls der Ordner nicht verbunden ist, sag mir Bescheid.
2. Stelle Godot 4.6.2 für headless Prüfungen bereit und prüfe mit `--headless --import`, dass das Projekt fehlerfrei lädt.

## Schritt 1: Einlesen und Stand bestätigen

1. Lies die Pflichtlektüre aus `AGENTS.md` vollständig: `AGENTS.md`, `docs/DEVLOG.md`, `docs/ROADMAP.md`, `docs/DECISIONS.md`, `docs/GAME_DESIGN.md`, `docs/ARCHITECTURE.md`.
2. Fasse mir in drei bis fünf Sätzen zusammen, was du verstanden hast und wie du vorgehen willst. Wenn dir in Architektur oder Plan etwas fragwürdig erscheint, sag es jetzt.

## Schritt 2: Erste Designrunde

Bevor du Code schreibst, kläre mit `AskUserQuestion` die offenen Fragen, die M1 betreffen. Pro Frage 2 bis 4 konkrete Optionen, deine Empfehlung als erste Option mit „(Empfohlen)“ und einem Satz Begründung. Kurze, vorstellbare Beschreibungen, gern mit Verweis auf bekannte Spiele.

1. **Q02 Spielfigur:** Was für eine Figur, und wie fühlt sie sich an (präzise wie Mario, wackelig wie Fall Guys, schwer wie Human Fall Flat)?
2. **Q03 Thema und Stil:** z. B. Freizeitpark, Bauernhof, Büro, Weltraum; Low-Poly mit freien Kenney/Quaternius-Assets als Vorschlag.
3. **Q04 Tastenbelegung:** Belegung von `jump`, `action`, `push`, `special`, `confirm`, `back`, `pause` auf dem Gamepad.
4. **Q08 Computergegner:** fehlende Plätze auffüllen oder nicht?

Für den Anfang reichen Platzhalter-Grafiken (Kapseln, Würfel in Spielerfarben). Echte Assets kommen erst nach meiner Zustimmung und nach Klärung von Q09 (Git-Repository für Binärdateien).

Trage die Antworten sofort in `docs/DECISIONS.md` ein.

## Schritt 3: Meilenstein M1 „Kern“

Umsetzen gemäß `docs/ARCHITECTURE.md` (Abschnitte 2, 3, 6, 7) und `docs/ROADMAP.md` (1.1 bis 1.7):

1. `InputRouter` als Autoload mit der Abstraktion `InputSource` und den Umsetzungen `GamepadInput` und `KeyboardInput` (Debug, zwei Tastaturspieler auf WASD und Pfeiltasten genügen). `AIInput` als leeres Gerüst.
2. Zuordnung Gerät zu Spielerplatz, `just_pressed` selbst berechnet, Deadzone für Sticks, Vibration.
3. Verbindungsabbruch: Spiel pausiert mit Hinweis, neuer Controller kann den Platz übernehmen.
4. `PlayerRoster` mit 4 Plätzen und gut unterscheidbaren Spielerfarben.
5. Beitrittsbildschirm: Jeder drückt Bestätigen auf seinem Controller, sieht seine Figur in seiner Farbe erscheinen, kann wieder austreten. Start, sobald mindestens ein Spieler bereit ist und Bestätigen gedrückt wird (genaue Regel ist Design: fragen).
6. Spielfigur (`CharacterBody3D`) mit Laufen, Springen, Schubsen inklusive Rückstoß. Alle Bewegungswerte als `@export`, damit ich sie im Editor tunen kann.
7. Testarena mit Boden, ein paar Hindernissen, Abgrund mit Respawn und `ArenaCamera`, die alle Spieler im Bild hält.
8. Pause-Menü, das jeder Spieler öffnen kann.
9. Hauptszene in `project.godot` setzen.

**Abnahmekriterien M1:**

1. Headless Import ohne Fehler, `--quit-after` Lauf der Hauptszene ohne Laufzeitfehler.
2. 4 Controller treten bei und steuern unabhängig je eine Figur; kein Controller beeinflusst eine fremde Figur.
3. Abziehen und Wiederanstecken eines Controllers funktioniert.
4. Mit Tastatur-Debugspielern ist das Ganze auch ohne Controller testbar.

Danach: Doku aktualisieren, committen, alles in den Projektordner zurückschreiben laut `CLAUDE.md` und mir eine **nummerierte Testanleitung** geben (was ich auf Windows und auf Bazzite ausprobieren soll). **Dann stoppen und auf mein Testergebnis warten.**

## Schritt 4: Meilenstein M2 „Minispiel-Framework und Schnellturnier“

Vorher mit `AskUserQuestion` klären: Q06 (Punktesystem, Turnierlänge), Q07 (Gewichtung der Formate, Aufholmechanik) und den Ablauf von Regelbildschirm und Übungsrunde (wie viel Text, wie lange, wer darf überspringen).

Umsetzen gemäß `docs/ARCHITECTURE.md` (Abschnitte 4, 5, 8) und `docs/ROADMAP.md` (2.1 bis 2.6):

1. `TeamFormat`, `MinigameInfo`, `MinigameRegistry`, `Minigame`, `MinigameContext`, `MinigameResult`.
2. `MatchFlow` mit Ankündigung, Regelbildschirm, Übung mit Bereit-Anzeige pro Spieler, Countdown, Spiel, kurzer Zeitlupe am Ende, Ergebnis.
3. `TeamAssigner` als reine Logik mit Tests.
4. Testläufer `tests/run_tests.gd` und Tests für TeamAssigner, Punktevergabe, Registry-Filter.
5. Schnellturnier: Format und Teams auslosen, passendes Minispiel wählen, Punktestand zwischen den Runden, Siegerehrung.
6. Ein absichtlich simples **Platzhalter-Minispiel** („Wer steht nach 20 Sekunden am nächsten zur Mitte“), das alle vier Formate unterstützt, damit das Turnier vor M3 durchspielbar ist.

**Abnahmekriterien M2:** Tests grün, ein komplettes Turnier mit dem Platzhalter-Minispiel ist von Anfang bis Siegerehrung nur mit Controllern spielbar.

Danach wieder: Doku, Commit, Zurückschreiben in den Projektordner, Testanleitung, **stoppen und warten.**

## Schritt 5: Meilenstein M3 „Vertical Slice“

Zuerst Q05 klären: welche vier Minispiele (Vorschlag in `docs/GAME_DESIGN.md` Abschnitt 10). Dann **jedes Minispiel einzeln** in dieser Schleife:

1. Kurzes Konzept mit `AskUserQuestion` abstimmen: Ziel, Siegbedingung, Steuerung, Dauer, Arena, Besonderheit der Teamrollen. Bei 1v3: wie wird die Sonderrolle ausbalanciert und wie lösen wir geheime Informationen auf einem gemeinsamen Bildschirm.
2. Umsetzen als eigener Ordner `minigames/<id>/` mit `info.tres`, nur über die Registry eingebunden.
3. Computergegner über `AIInput`, sodass das Spiel auch mit weniger als 4 Menschen funktioniert (sofern Q08 so entschieden).
4. Doku, Commit, Zurückschreiben in den Projektordner, Testanleitung. **Stoppen und auf mein Feedback warten**, bevor das nächste Minispiel beginnt.

## Arbeitsregeln für die ganze Sitzung

1. `AGENTS.md` gilt vollständig, insbesondere: Spieldesign immer fragen, Projekt immer lauffähig halten, Kontext in DEVLOG, ROADMAP und DECISIONS sichern.
2. Nutze die Aufgabenliste, damit ich den Fortschritt sehe.
3. Nach jeder größeren Änderung headless prüfen. Neue `class_name`-Skripte erst nach einem `--import` als registriert betrachten.
4. `.tscn`-Dateien dürfen ohne `uid`-Einträge geschrieben werden; Godot ergänzt sie beim Import. Komplexe Szenen lieber per Skript zur Laufzeit aufbauen als riesige `.tscn` von Hand zu schreiben, wenn das die Lesbarkeit verbessert.
5. Kleine Commits mit deutschen Nachrichten und Meilenstein-Präfix.
6. Wenn etwas nur auf meinem Rechner geprüft werden kann (Controller, Vibration, Performance, Bazzite), sag das klar und nimm es in die Testanleitung auf.
7. Keine Addons, Plugins oder fremden Assets ohne meine Zustimmung.
8. Antworte auf Deutsch, knapp und präzise. Verwende in deinen Antworten keine Aufzählungen mit Spiegelstrichen, nummerierte Listen und Tabellen sind in Ordnung.

## Kontext sichern, wenn der Chat lang wird

Wenn du merkst, dass dieser Chat sehr lang wird oder ein Meilenstein abgeschlossen ist und ein frischer Start sinnvoll wäre:

1. Bringe den aktuellen Schritt zu einem lauffähigen Stand.
2. Aktualisiere DEVLOG, ROADMAP und DECISIONS so, dass ein neuer Agent ohne diesen Chat weitermachen kann.
3. Schreibe den nächsten Prompt als `docs/prompts/02_<thema>.md` nach dem Muster dieses Prompts, mit allem, was der nächste Chat wissen muss.
4. Alles in den Projektordner zurückschreiben, dann sag mir, dass ich mit dem neuen Prompt einen neuen Chat starten soll.

Beginne jetzt mit Schritt 0.
