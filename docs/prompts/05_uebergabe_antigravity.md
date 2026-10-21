# Prompt 05: Übergabe an Google Antigravity und Abschluss von v0.5

Stand 2026-10-21: v0.5 „Neuer Look“ wurde in Claude (Cowork) nur bis einschließlich WP 2 umgesetzt (Stil steht, Look-System, ART_GUIDE, Prüfskript, erstes Asset-Paket). Der Rest von v0.5 (WP 3 bis 10) und alle weiteren Patches laufen in Antigravity (D89).

Im Projektordner den aktuellen Stand committen und auf GitHub pushen (Commit-Vorschlag: `v0.5 WP1-2: Stil, Look-System, ART_GUIDE, Asset-Audit`). Dann in Antigravity den Ordner `C:\Users\wad32muj\Agentenraum\partypark` öffnen und diesen Text als erste Nachricht schicken. Teil A und Teil B können im selben Gespräch laufen; wird es lang, gilt der Abschnitt „Kontext sichern“.
Das lokale Git soll auf mein online Git repo https://github.com/sudoMrMCaffe/PartyPark übertragen werden
---

Du übernimmst ab jetzt die Entwicklung von **Partypark**, einem lokalen 3D-Partyspiel für bis zu 4 Spieler an einem Bildschirm (Godot 4.7, GDScript, Jolt, Forward+, Windows und Linux/Bazzite). Bisher hat Claude (Cowork) daran gearbeitet, über eine Dateibrücke ohne eigene Shell auf meinem Rechner und mit Software-Rendering in der Cloud. Du arbeitest jetzt direkt lokal: Terminal, Godot mit echter Grafikkarte, Git. Ich bin Leonardo, Ideengeber und Spieldesigner.

`AGENTS.md` im Projektstamm wird von Antigravity automatisch geladen und gilt vollständig, insbesondere: **Spieldesign entscheide ich.** Alles, was beeinflusst, wie das Spiel sich spielt, anfühlt, aussieht oder anhört, schlägst du vor und fragst mich, bevor du es umsetzt. Für alles Sichtbare gilt zusätzlich `docs/ART_GUIDE.md`.

# Teil A: Übergabe (noch keine neuen Funktionen)

## A1: Einlesen

1. Pflichtlektüre aus `AGENTS.md`: `docs/DEVLOG.md` (die obersten Einträge), `docs/ROADMAP.md` (v0.5 und v0.6), `docs/DECISIONS.md` (bis D89, offene Fragen), danach `docs/ART_GUIDE.md`, `docs/ARCHITECTURE.md`, `docs/MINIGAME_GUIDE.md`, `docs/PERFORMANCE.md`, `docs/ASSET_QUELLEN.md` und `docs/prompts/04_patch_v0_5.md` (enthält die ausführlichen Leitlinien für WP 3 bis 10).
2. `CLAUDE.md` nur überfliegen: Sie beschreibt die alte Dateibrücke (Variante B, Klassen-Cache von außen schreiben, Commit-Vorschläge) und gilt für dich nicht.
3. Fasse mir in höchstens sechs Sätzen zusammen, wo das Projekt steht und was in v0.5 noch fehlt.

## A2: Umgebung prüfen

1. Git: `git status`, Branch, Remote `origin` (privates GitHub-Repository, D74), letzter Commit. Gibt es uncommittete Änderungen, frag mich, bevor du etwas tust.
2. Godot: Im Projektstamm liegt `Godot_v4.7.2-stable_win64_console.exe` (per `.gitignore` ausgeschlossen). Fehlt es, frag mich nach dem Pfad. Prüfungen in PowerShell aus dem Projektstamm:
   ```
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --import
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/run_tests.gd
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --smoke-compile
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --smoke-m1
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --smoke-m2
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --smoke-games
   .\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --tool-asset_audit
   ```
   Erwartet (Stand 2026-10-21): Unit 31/31, compile 122 Dateien ohne Fehler, m1 50/50, m2 39/39, games 12/12. Abweichungen erst melden, dann beheben.
3. Bildschirmfotos mit echter Grafikkarte, ohne `--headless`, z. B. `--path . --resolution 1280x720 -- --smoke-style_probe --shots=docs/screenshots/check --moods=noon,golden,evening`. Prüfe, ob die Bilder den Stilproben in `docs/screenshots/v0_5/stilproben/` entsprechen (dort mit Software-Renderer erzeugt; Abweichungen in Licht und Glanz sind möglich und müssen mir gezeigt werden).
4. Spiel einmal sichtbar starten (`--path .`), damit ich sehe, dass es läuft.
5. GitHub Actions: Gibt es `.github/workflows/tests.yml`? Falls nicht, aus `tools/ci/tests.yml` anlegen (D79 galt nur wegen der Dateibrücke). Nach dem nächsten Push prüfen, ob die Actions grün sind (`gh run list`, falls die GitHub-CLI installiert ist, sonst mich fragen).

## A3: Arbeitsweise umstellen

1. `AGENTS.md`, Abschnitt „Arbeitsumgebungen“: Antigravity ist die Hauptumgebung (lokal unter Windows, Git und GitHub als Austauschweg). Die Befehle aus A2 als Windows-Variante bei „Nützliche Befehle“ ergänzen, inklusive Bildschirmfotos und `--tool-asset_audit`. `AGENTS.md` bleibt unter 12.000 Zeichen und nennt keine Werkzeugnamen einer bestimmten KI.
2. Absatz „Rückfragen“ in `AGENTS.md`: Designfragen im Chat als nummerierte Fragen mit Optionen A, B, C, Empfehlung zuerst mit einem Satz Begründung, höchstens vier auf einmal, dann auf Antwort warten und in `docs/DECISIONS.md` eintragen. Vor jedem größeren Arbeitspaket ein Implementierungsplan als Artefakt mit Freigabe. Bei optischen Fragen immer erst Bilder (2 bis 3 Varianten derselben Ansicht), dann fragen.
3. `CLAUDE.md` oben mit Hinweis versehen: Nur für Claude (Cowork) über die Dateibrücke; seit 2026-10-21 ist Antigravity die Hauptumgebung, Stand immer über Git holen.
4. Antigravity-Skills anlegen (`.agents/skills/<name>/SKILL.md`; Dateiformat vorher in der Antigravity-Dokumentation prüfen):
   1. `partypark-tests`: alle Prüfungen aus A2 ausführen und zusammenfassen.
   2. `partypark-screenshots`: festgelegte Ansichten (jedes Minispiel, Titel, Beitritt, Hauptmenü, Siegerehrung) in allen drei Stimmungen rendern und als Galerie ablegen.
   3. `partypark-minigame`: neues Minispiel nach `docs/MINIGAME_GUIDE.md` und `docs/ART_GUIDE.md` mit `tools/new_minigame.gd`, Konzeptrunde mit mir, Computergegner, Arena als `.tscn`, Smoke-Test, Messmodus, Asset-Audit.
   4. `partypark-patch-abschluss`: Testanleitung, DEVLOG, ROADMAP, DECISIONS, Versionsnummer, Commit, Push, Actions prüfen.
5. Sicherheitsregeln: Keine Dateien löschen, nichts installieren, nichts herunterladen und nie `git push --force` ohne meine ausdrückliche Zustimmung. Commits mit deutschen Nachrichten und Präfix (z. B. `v0.5 WP6: Themen-Arenen`).
6. Ist der Godot-Editor bei mir offen, während du Dateien änderst, sag mir, wann ich „Projekt → Aktuelles Projekt neu laden“ ausführen soll. Nach neuen `class_name`-Skripten immer `--headless --import`.
7. DEVLOG-Eintrag „Übergabe an Antigravity“ (Agent und Umgebung: Modell in Antigravity), ROADMAP 6.0 auf erledigt, Commit `Übergabe: Antigravity als Hauptumgebung`, Push nach meiner Freigabe.

# Teil B: Rest von v0.5 „Neuer Look“ abschließen

Ziel unverändert (ROADMAP v0.5): Partypark sieht aus wie ein fertiges, liebevolles Partyspiel, einheitlich im Stil „lackiertes Spielzeug im Freizeitpark“ (D85), in allen drei Tageszeiten (D86), lesbar für vier Spieler, 60 fps auf einer integrierten Radeon 780M. Die ausführlichen Leitlinien je Paket stehen in `docs/prompts/04_patch_v0_5.md`, Abschnitt „Technische Leitlinien“; sie gelten mit den **Nachbesserungen** unten. Wo sich beides widerspricht, gelten die Nachbesserungen und `docs/ART_GUIDE.md`.

## B1: Offene Arbeitspakete

| WP | ROADMAP | Inhalt | Entscheidung bei mir |
|---|---|---|---|
| 3 | 5.3 | Asset-Pipeline fertigstellen: genutzte Dateien aus `assets/_incoming/` nach `assets/third_party/<paket>/`, Importvorgaben, CREDITS, Größenbudget, Git LFS nur falls nötig | Q27 nur falls nötig |
| 4 | 5.4 | Look-Grundlage vervollständigen (Umgebung und Materialien gibt es schon in `core/look/`), Grafikstufen erweitern | Feinabstimmung mit Bildern |
| 5 | 5.5 | Spielfigur-Feinschliff, Augen, Ausdrücke, Posen, Zubehör-Platz | mit Bildern |
| 5a | neu | Waffen für Schießspiele (siehe Nachbesserung 1) | Blaster-Auswahl, Q24 |
| 6 | 5.6 | Park-Kulisse und sieben Themen-Arenen (D84) | Thema je Arena (Q26), mit Bildern |
| 7 | 5.7 | Effekte veredeln | wenige |
| 8 | 5.8 | Menüs, UI, Tastensymbole, Siegerehrung, Ansager-Optik | Schrift, Ansager (Q23) |
| 9 | 5.9 | Leistung und Grafikstufen | Voreinstellungen |
| 10 | 5.10 | Nachher-Galerie, Testanleitung, Abschluss | keine |

**Haltepunkte:** nach WP 5a (Figur und Waffen), nach WP 6 (Arenen) und am Ende: Bilder zeigen, kurze Testanleitung, auf Feedback warten. Sage ich „ohne Feedback weiter“, nur Tests grün halten und weitermachen (D66).

## B2: Nachbesserungen gegenüber dem bisherigen Stand

1. **Waffen (fehlte bisher):** Die Zerfetzung bekommt Spielzeug-Blaster aus dem Kenney Blaster Kit (`assets/_incoming/kenney_blaster-kit_2.1/`, CC0) statt des Platzhalters „Krawumm-Blaster“; Auswahl mit Bildern, Q24 dabei klären (Waffenname, Arena, Überhitzung, Zielhilfe). Jede Waffe als eigene Szene `core/weapons/<name>.tscn` mit einheitlichen Ankerpunkten für Hand und Mündung, Mündungsblitz, Rückstoß-Animation und Geräusch-Hook, angeschlossen an `ShooterAbility`. Weitere Schießspiele (GAME_DESIGN 9.7) sollen diese Szenen wiederverwenden. Zielscheiben und Kisten aus demselben Paket als Deckung nutzen. Realistische Waffen (Quaternius Gun Pack) nur nach meiner Zustimmung.
2. **Keine Umrisslinien (D85):** Alle Hinweise auf Umrisslinien oder Toon-Shader in Prompt 04 entfallen. Grafikstufe „Niedrig“ schaltet stattdessen SSAO, Glow, Kulissen-Details und die Punktlichter der Glühbirnen ab (Emission bleibt).
3. **Alle drei Stimmungen (D86):** Jede Arena, jedes Menü und die Kulisse müssen am Nachmittag, zur goldenen Stunde und im Abendrummel gut aussehen. Abends Lichterketten und Glühbirnen mit Emission; Punktlichter sparsam (Budget im ART_GUIDE). Für jede Arena Bilder in allen drei Stimmungen zeigen.
4. **Bekannte Probleme aus dem Asset-Audit:** Wackelwaben liegen bei geschätzt 608 Draw Calls (Budget 400) und brauchen MultiMesh oder zusammengeführte Meshes; Schafe hüten hat rund 147.000 Dreiecke, beim Einbau der Quaternius-Schafe auf Polygonzahl achten. Große Wasserflächen spiegeln die Sonne zu stark (Rauheit bzw. Glanz im Wasser-Shader anpassen).
5. **Arenathemen (Q26):** Je Arena zwei Themenvorschläge mit Bild, passend zu den freigegebenen Paketen (D83), z. B. Autoscooter mit Toy Car Kit, Heiße Kartoffel an einer Imbissbude (Food Kit), Riese gegen Zwerge an einer Burg (Castle Kit), Schafe hüten auf der Streichelwiese (Farm Animals, Nature Kit), Wackelwaben über dem Wellenbad, Zerfetzung als Blaster-Halle (Blaster Kit, Survival Kit).
6. **Doppelte Pakete:** In `assets/_incoming/` liegen `kenney_blaster-kit` und `kenney_blaster-kit_2.1` sowie `kenney_input-prompts` und `kenney_input-prompts_1.5`. Die Fassungen mit Versionsnummer verwenden; die anderen nach Rückfrage löschen (Ordner ist nicht versioniert).
7. **Hüte:** Für Hüte gibt es kein freies Paket mit klarer Lizenz (`docs/ASSET_QUELLEN.md`, Abschnitt G). In WP 5 nur den Zubehör-Platz vorbereiten und als Probe ein selbst gebautes Partyhütchen zeigen.
8. **Weitere freigegebene Pakete nutzen:** KayKit Platformer (Teamfarben, Absperrungen, Ziellinien), Quaternius Ultimate Platformer (Wolken, 3D-Countdown-Ziffern), Kenney Input Prompts (Tastensymbole), Particle Pack, Emotes Pack (Ausdrücke über den Figuren), UI Pack und Pattern Pack (Menüs). Schriften Fredoka bzw. Lilita One nur, wenn ich sie heruntergeladen habe (OFL-Datei mitliefern).
9. **Offene Testpunkte:** Die nicht getesteten Punkte aus `docs/TESTANLEITUNG_V0_4.md` wandern in `docs/TESTANLEITUNG_V0_5.md` (D82). Echte Messung auf der Radeon 780M (`-- --bench`, alle Grafikstufen) als eigener Abschnitt; Ergebnisse in `docs/PERFORMANCE.md`.
10. **Kein Dateibrücken-Ablauf mehr:** Kein Klassen-Cache von außen schreiben, keine Commit-Vorschläge an mich; du committest selbst nach jedem Arbeitspaket und pushst an den Haltepunkten nach Freigabe.

## B3: Abschluss von v0.5

1. Nachher-Bilder aller Ansichten in allen drei Stimmungen nach `docs/screenshots/v0_5/nachher/`, Galerie `docs/screenshots/v0_5/README.md` mit Vorher-Nachher-Tabelle.
2. `docs/TESTANLEITUNG_V0_5.md` (nummeriert, Rückmeldung als „Nummer: ok/Problem“) mit „Sichtprüfung je Arena“ und „Messung auf der Radeon 780M“.
3. `docs/MINIGAME_GUIDE.md` um Arenenbau, Waffen und ART_GUIDE ergänzen, `docs/ARCHITECTURE.md` um `core/look/`, `core/weapons/` und die Asset-Pipeline.
4. DEVLOG, ROADMAP v0.5 auf erledigt, DECISIONS, `config/version` in `project.godot` auf `0.5.0`, Commit, Push nach Freigabe, Actions grün.
5. `docs/prompts/06_patch_v0_6.md` auf den Stand nach v0.5 bringen (Testzahlen, neue Bausteine), nicht neu erfinden. Dann vorschlagen, v0.6 zu starten.

## Kontext sichern, wenn das Gespräch lang wird

Lauffähigen Stand herstellen, DEVLOG, ROADMAP und DECISIONS so aktualisieren, dass ein neues Gespräch ohne diesen Verlauf weitermacht, Fortsetzungsprompt `docs/prompts/05b_v0_5_fortsetzung.md` schreiben, committen und mir sagen, dass ich neu starten soll.

## Kommunikation

Deutsch, knapp und präzise. Keine Aufzählungen mit Spiegelstrichen; nummerierte Listen und Tabellen sind in Ordnung. Bilder sagen bei Grafikfragen mehr als Beschreibungen.

Beginne jetzt mit Teil A, Schritt A1.
