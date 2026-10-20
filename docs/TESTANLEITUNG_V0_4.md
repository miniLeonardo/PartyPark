# Testanleitung Patch v0.4 „Spieleabend“

Ergebnis bitte als „Nummer: ok“ oder „Nummer: Problem, was genau passiert ist“ zurückmelden, dazu Eindrücke. Es wird im DEVLOG eingetragen. Am besten mit Controllern testen (D51), Tastatur nur ergänzend.

Vor dem ersten Start: Godot-Editor öffnen, warten, bis unten der Import der neuen Geräusche (`assets/audio/sfx`) durchgelaufen ist. Erscheint beim Start „Could not find type …“, im Editor „Projekt → Aktuelles Projekt neu laden“.

## Teil 1: Haltepunkt nach WP 1 bis 3 (Feedback, Effekte, Sound)

Automatisch geprüft (Cloud, Godot 4.7.2): Unit 23/23, compile 96 Dateien ohne Fehler, Smoke M1 50/50, Smoke M2 32/32, Smoke Games 9/9 (jedes Minispiel mit vier Computern, Partikel-Obergrenze, Kamera-Wackeln, alle Geräusche vorhanden). Nicht prüfbar in der Cloud: Klang, Vibration, Bildrate, Controller.

### Geräusche (D59 bis D62)

1. Titel, Beitritt, Hauptmenü: Beitreten macht ein „Boing“ (je Spieler etwas höher), Austreten ein fallendes „Boing“, Navigieren ein leises Tick, Bestätigen ein Plopp nach oben, Zurück ein Plopp nach unten. Klingt das weich-comichaft und nicht nervig?
2. Optionen: neue Einträge „Bildschirmwackeln“, „Musik“, „Effekte“, „Stimme“. Effekte und Stimme spielen beim Ändern ein Probegeräusch. Werte bleiben nach Neustart erhalten. Musik hat noch keinen Inhalt.
3. Vor jedem Minispiel: Bereit-Druck macht ein Plopp, Countdown 3, 2, 1 piept, „Los!“ ist ein heller Akkord. Am Ende eine kleine Fanfare (bei verlorenem Schafe hüten eine traurige Tonfolge).
4. Pause öffnen und schließen: eigene Töne; im Pausenmenü klingen Navigation und Auswahl.

### Effekte (D55, D56)

5. Allgemein: Springen „Boing“, harte Landung staubt, Schubsen „Wusch“, getroffene Figur „Bonk“ mit Staubwölkchen, beim Erscheinen Sterne in Spielerfarbe.
6. **Autoscooter:** Rempler frieren beide Wagen ganz kurz ein (Hitstop), Sterne an der Aufprallstelle, Turbo-Rempler wackelt den Bildschirm leicht. Ins Wasser fallen: Platscher und starkes, aber dezentes Wackeln.
7. **Riese gegen Zwerge:** Stampfen wackelt mittel, Staubring breitet sich aus; getroffene Zwerge sehen Sterne. **Neu (D52):** Wer um den Riesen läuft, zieht ein Seil hinter sich her, das sich sichtbar um ihn legt; fertige Seile sind dicke Ringe außen am Riesen. Abschütteln (Y) lässt einen Ring wegfliegen. Sieht man jetzt gut, wie weit die Zwerge sind?
8. **Tauziehen (D53):** jetzt 30 s. Jeder Zug spritzt Schlamm, das Seil federt sichtbar. Synchrone Züge füllen oben den Kraftbalken des Teams („Kraft ■■□□“); ist er voll, steht „Kraftakt bereit!“ und Y gibt einen großen Ruck mit Wackeln. Ist es jetzt spannender? Kommt der Kraftakt zu oft oder zu selten (Platzhalter: 4 Synchrontakte)?
9. **Schafe hüten:** Bellen staubt und „wufft“, jedes Schaf im Gehege gibt Sterne und einen hellen Ton, der Wolf heult beim Erscheinen und jault beim Wegschubsen.
10. Am Rundenende fällt Konfetti über den Siegern.
11. Optionen → Bildschirmwackeln „Aus“: Stampfen und Rausfallen wackeln nicht mehr, alles andere bleibt.
12. **Riese gegen Zwerge mit Computern (D58):** Computer-Zwerge laufen jetzt zwischendurch weg und verschnaufen. Fühlt sich ein Computer-Zwerg fair an, wenn du Riese bist?
13. **Bildrate:** Läuft alles flüssig, auch wenn viel gleichzeitig staubt (Autoscooter mit 4 Spielern)? Falls nicht, bitte sagen, in welchem Spiel.
14. **Autoscooter mit Controller (D51):** Wie fühlt sich die Steuerung mit Stick an (Stick lenkt, A Gas halten, X Turbo)? Hier entscheiden wir, ob sie geändert wird.

## Teil 2: WP 4 bis 9 (Ansager, Leistung, neue Spiele, Export)

Haltepunkte wurden auf Wunsch übersprungen (D66); Teil 1 und Teil 2 können zusammen getestet werden. Automatisch geprüft: Unit 31/31, compile 117 Dateien ohne Fehler, Smoke M1 50/50, M2 39/39 (alle sieben Spiele im Freien Spiel), Games 12/12, Linux-Export startet und durchläuft den Messmodus.

### Ansager (D67, D68)

15. Vor jedem Minispiel erscheint unten links Hodenhüpfer (graues Gesicht mit Brille) mit einem trockenen Spruch zum Spiel; der Text läuft Buchstabe für Buchstabe, dazu Brabbel-Silben. Bewegt sich der Mund?
16. Am Rundenende kommentiert er Sieg, Unentschieden, knappe Entscheidungen oder eine verlorene Koop-Runde; bei der Siegerehrung den Turniersieger. Wenn jemand ausscheidet, sagt er manchmal etwas dazu.
17. Der Ansager blockiert nichts: Weiterdrücken geht jederzeit. Optionen → „Stimme“ regelt seine Lautstärke.
18. Passen Ton und Sprüche? Die Sprüche stehen in `core/announcer/announcer_lines.json` und können direkt geändert werden.

### Leistung (D69)

19. F3 schaltet oben links die Leistungsanzeige ein und aus (fps, Frametime, 1 % tief, Draw Calls, Partikel). Optionen → „Leistungsanzeige“ macht dasselbe dauerhaft.
20. Optionen → „Grafik“ Niedrig/Mittel/Hoch: Bei Niedrig verschwinden die Schatten und das Bild wird etwas weicher, bei Hoch werden die Kanten glatter.
21. Messmodus: Projekt → Projekteinstellungen („Erweiterte Einstellungen“ an) → Editor → Ausführen → Hauptlauf-Argumente `-- --bench`, F5. Jedes Spiel läuft 22 s mit Computern, danach schließt sich das Spiel. Ergebnis `%APPDATA%\Godot\app_userdata\Partypark\bench.txt` bitte schicken oder in `docs/PERFORMANCE.md` eintragen. Argument danach wieder leeren.

### Neue Minispiele

22. **Wackelwaben (D70, D73):** Drei Ebenen aus Waben übereinander. Betretene Waben werden hell, wackeln 0,6 s und fallen. Man fällt auf die Ebene darunter, unter der untersten ist Wasser. Laufen, Springen, Schubsen. Letzter gewinnt, nach 90 s die höchste Ebene. Wie lange dauert eine Runde mit Menschen? (Computer: 25 bis 40 s.)
23. **Heiße Kartoffel (D71):** Einer bekommt die Bombe über dem Kopf, läuft 15 % schneller und gibt sie mit X (Schubsen) weiter. Die Lunte brennt sichtbar ab, das Ticken wird schneller, die Bombe glüht. Beim Knall fliegt der Halter raus, Umstehende werden weggeschleudert. Neue Bombe nach kurzer Pause, bis einer übrig ist.
24. **Zerfetzung (D72, D49):** Bildschirm in vier Ansichten aus Ego-Sicht. Linker Stick laufen, rechter Stick umsehen, X feuern (halten = Dauerfeuer, Balken unten überhitzt), A springen. Nahe am Gegner wird das Fadenkreuz langsamer (Zielhilfe). Nach 3 Treffern zerplatzt die Figur in Stücke ihrer Farbe, ihre Ansicht zeigt dann die Arena von oben. Wie fühlen sich Zielen und Zielhilfe an? Läuft es flüssig (F3)?
25. Mit der Tastatur (nur Debug): In Zerfetzung drehen A/D bzw. links/rechts, W/S laufen vor und zurück.

### Bauanleitung, Git und Export

26. `docs/MINIGAME_GUIDE.md` einmal durchlesen: Ist verständlich, wie ein neues Minispiel entsteht?
27. GitHub nach `docs/GITHUB_ANLEITUNG.md` einrichten (dabei `tools/ci/tests.yml` nach `.github/workflows/` kopieren). Nach dem ersten Push unter „Actions“ prüfen, ob „Tests“ grün wird.
28. Export-Vorlagen installieren und beide Profile exportieren (`docs/EXPORT_UND_BAZZITE.md` Abschnitte 1 und 2). Startet `builds/windows/Partypark.exe`?
29. Bazzite-Test nach `docs/EXPORT_UND_BAZZITE.md` Abschnitt 5 (B1 bis B9).

### Aufräumen (bitte selbst löschen, Claude kann im Ordner nicht löschen)

30. Diese leeren Platzhalter liegen in Ordnern, die inzwischen Dateien enthalten, und können weg: `assets/audio/.gitkeep`, `core/input/.gitkeep`, `core/minigame/.gitkeep`, `core/teams/.gitkeep`, `minigames/.gitkeep`, `modes/tournament/.gitkeep`, `player/.gitkeep`, `tests/.gitkeep`, `tools/.gitkeep`, `ui/.gitkeep`. Behalten: `assets/fonts`, `assets/models`, `assets/textures`, `modes/hub`.
