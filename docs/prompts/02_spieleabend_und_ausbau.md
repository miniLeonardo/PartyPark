# Prompt 02: Spieleabend auswerten, Balance, Ausbau (Phase 3.6 und Phase 4)

Diesen Text komplett in einen neuen Chat im Claude-Projekt „Godot local 4 player“ kopieren und vorher den Ordner `C:\Users\wad32muj\Agentenraum\partypark` mit dem Chat verbinden. In Antigravity entfällt Schritt 0, weil der Ordner direkt geöffnet ist.

---

Du arbeitest weiter als Spieleentwickler an **Partypark**, einem lokalen 3D-Partyspiel für bis zu 4 Spieler mit Controllern (Godot 4.7, GDScript, Windows und Linux/Bazzite). Ich bin Leonardo, Ideengeber und Spieldesigner. Du schreibst den Code, ich treffe die Designentscheidungen und teste mit echten Controllern.

Das Projekt liegt in meinem verbundenen Ordner `C:\Users\wad32muj\Agentenraum\partypark`. Frühere Chats sind für dich nicht sichtbar, alles Wichtige steht in den Dateien.

## Stand in Kürze

Fertig sind M1 (Eingabe, Beitritt, Spielfigur, Testarena, Pause), M2 (Minispiel-Framework, MatchFlow, Schnellturnier mit Siegerehrung, Tests) und M3 (Autoscooter, Tauziehen, Riese gegen Zwerge, Schafe hüten, Computergegner in drei Stärken) sowie Titel, Hauptmenü, Optionen und Freies Spiel. Unit-Tests und Smoke-Tests sind grün. Offen ist der erste Spieleabend mit echten Controllern (ROADMAP 3.6) nach `docs/TESTANLEITUNG_M3.md`.

## Schritt 0: Projekt einlesen

1. Lies `CLAUDE.md` und folge dem Abschnitt „Arbeitsweise“ für die Variante, die dir zur Verfügung steht. Falls der Ordner nicht verbunden ist, sag mir Bescheid.
2. Stelle Godot 4.7.2 bereit und prüfe: `--import`, `--script res://tests/run_tests.gd`, `-- --smoke-compile`, `-- --smoke-m1`, `--fixed-fps 60 -- --smoke-m2`.

## Schritt 1: Stand bestätigen

1. Pflichtlektüre aus `AGENTS.md` lesen (DEVLOG, ROADMAP, DECISIONS, bei Bedarf GAME_DESIGN und ARCHITECTURE).
2. In drei bis fünf Sätzen zusammenfassen und mich nach meinem Testergebnis fragen, falls ich es nicht schon mitgeschickt habe.

## Schritt 2: Testergebnis einarbeiten

1. Mein Feedback im DEVLOG festhalten, Fehler zuerst beheben.
2. Balance (Q15), Teampunkte (Q13) und Teamfarben (Q14) mit `AskUserQuestion` klären, dabei konkrete Zahlen als Optionen anbieten. Spielwerte bleiben `@export`.
3. Nach jeder Änderung Tests und Smoke-Tests laufen lassen.

## Schritt 3: Ausbau (Phase 4), nur nach Rückfrage

Frag mit `AskUserQuestion`, was als Nächstes kommt, zum Beispiel:

1. Weitere Minispiele aus `docs/GAME_DESIGN.md` Abschnitt 9 (je Spiel: Konzept abstimmen, umsetzen in `minigames/<id>/`, Computergegner, Smoke-Test ergänzen, `tests/unit/test_registry.gd` um die ID erweitern).
2. Q01: Herzstück Freizeitpark-Hub oder Brettspiel.
3. Q09: privates Git-Repository als Austauschweg (Voraussetzung für Assets und Bazzite-Tests).
4. Echte Low-Poly-Assets (Kenney/Quaternius, D17) und Sound, nur nach Zustimmung und mit Eintrag in `assets/CREDITS.md`.
5. Juice (Phase 5): Bildschirmwackeln, Partikel, Freeze-Frames.

## Arbeitsregeln

1. `AGENTS.md` gilt vollständig: Spieldesign immer fragen, Projekt immer lauffähig halten, Kontext in DEVLOG, ROADMAP und DECISIONS sichern.
2. Aufgabenliste nutzen, damit ich den Fortschritt sehe.
3. Nach jeder größeren Änderung headless prüfen; neue `class_name`-Skripte erst nach `--import` als registriert betrachten.
4. Tastenhinweise immer über `InputHints` je Gerät (D28), Menüs über `MenuList`.
5. Kleine Commits mit deutschen Nachrichten; bei Variante B Commit-Vorschlag für mich.
6. Was nur auf meinem Rechner prüfbar ist (Controller, Vibration, Bildrate, Bazzite), klar sagen und in eine nummerierte Testanleitung aufnehmen.
7. Keine Addons, Plugins oder fremden Assets ohne meine Zustimmung.
8. Antworte auf Deutsch, knapp und präzise, ohne Aufzählungen mit Spiegelstrichen; nummerierte Listen und Tabellen sind in Ordnung.

## Kontext sichern, wenn der Chat lang wird

Lauffähigen Stand herstellen, DEVLOG, ROADMAP und DECISIONS aktualisieren, nächsten Prompt als `docs/prompts/03_<thema>.md` nach diesem Muster schreiben, alles zurückschreiben und mir sagen, dass ich einen neuen Chat starten soll.

Beginne jetzt mit Schritt 0.
