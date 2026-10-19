# Testanleitung Menüs, Schnellturnier und vier Minispiele (M2, M3)

Stand: 2026-10-19. Ergebnis bitte als „Nummer: ok“ oder „Nummer: Problem, was genau passiert ist“ zurückmelden, dazu Eindrücke zum Spielspaß. Es wird im DEVLOG eingetragen.

Automatisch bereits geprüft (Cloud, ohne echte Controller, Godot 4.7.2): 18 Unit-Tests grün (Teamauslosung, Punkte, Registry); Smoke-Test M1 50 von 50; Smoke-Test M2 30 von 30 (Titel → Beitritt → Hauptmenü → komplettes Turnier mit 5 Runden → Siegerehrung → jedes Minispiel im Freien Spiel → Optionen). Dabei spielten 3 Computer mit einem untätigen Tastaturspieler; alle vier Spiele enden korrekt.

## Teil A: Ablauf und Menüs

1. F5. Der Titel „PARTYPARK“ erscheint, unten steht, welche Taste welches Gerät drücken soll. A (bzw. Leertaste/Enter) tritt bei und öffnet den Beitritt.
2. Weitere Spieler treten bei, Start (Tastatur: Esc bzw. P) führt ins Hauptmenü.
3. Hauptmenü: mit Stick hoch/runter wählen, bei „Schnellturnier“ mit links/rechts 5 oder 10 Runden einstellen. B führt zurück zum Beitritt.
4. „Optionen“: Computer-Stärke, Vibration, Vollbild, Turnierlänge mit links/rechts ändern. Nach einem Neustart des Spiels müssen die Werte noch da sein.
5. „Testarena“ funktioniert wie bisher; Pause → „Zum Hauptmenü“ führt zurück.

## Teil B: Schnellturnier

6. Schnellturnier mit 5 Runden starten. Vor jeder Runde: Ankündigung (Spielname, Format, Teams in Farbe), dann Regelbildschirm mit den Tasten deines Geräts. Jeder Mensch drückt A für „Bereit“, Computer sind sofort bereit. Dann 3, 2, 1, Los.
7. Am Ende jeder Runde kurze Zeitlupe, dann Ergebnis mit Plätzen und Punkten. A geht weiter zum Zwischenstand, A zur nächsten Runde.
8. Prüfen: Dasselbe Format kommt nie zweimal hintereinander. Im „1 gegen 3“ ist der Spieler mit den wenigsten Punkten der Riese.
9. Nach der letzten Runde: Siegerehrung mit Podest und Konfetti, A führt ins Hauptmenü.
10. Während eines Minispiels Start drücken: Pause-Menü erscheint, „Weiter“ setzt fort, ohne dass deine Figur springt.

## Teil C: Die vier Minispiele (am besten zusätzlich einzeln über „Freies Spiel“)

11. **Autoscooter (Jeder gegen jeden):** Stick lenkt, A halten gibt Gas, X Turbo. Rempler schieben andere weg, durch die vier Lücken in der Bande fällt man ins Wasser. 3 Leben, wer zuletzt fährt, gewinnt (sonst nach 90 s die meisten Leben). Fühlt sich das Lenken gut an? Ist der Turbo zu stark/schwach?
12. **Tauziehen (2 gegen 2):** Oben pulsiert ein Ring. A drücken, wenn der weiße Ring den gelben Kreis trifft. Über dem Kopf erscheint „Zug!“, „Synchron!“ (beide im Team im selben Takt) oder „Daneben!“. Der Takt wird schneller. Zu einfach, zu schwer, zu lang?
13. **Riese gegen Zwerge (1 gegen 3):** Riese: A stampft nach kurzem Ausholen (Ring zeigt die Schockwelle), Y schüttelt ein Seil ab (alle 6 s). Zwerge: eng um den Riesen laufen, jede volle Runde wickelt ein Seil (Ringe am Riesen, Anzeige „Seile x / 5“), A springt über die Schockwelle. Ist das ausgeglichen?
14. **Schafe hüten (alle gegen Computer):** Schafe laufen vor euch weg; X bellt (Ring) und scheucht sie stark. 10 Schafe ins weiße Gehege oben. Nach 45 s kommt ein Wolf und jagt Schafe heraus; mit X schubsen, dann flieht er für 6 s.
15. **Freies Spiel:** Spiel aus der Liste wählen. Bei Tauziehen setzt sich jeder mit links/rechts selbst in Team Orange oder Lila (Computer gleichen aus), A startet nur bei 2 gegen 2. Bei Riese gegen Zwerge wählt man mit links/rechts den Riesen.
16. **Computer-Stärke:** einmal auf „Leicht“ und einmal auf „Schwer“ spielen. Merkt man den Unterschied?

## Teil D: Nur am echten Rechner

17. Vibration in allen Spielen (Rempler, Stampfen, Seil, Bellen), und dass „Vibration aus“ in den Optionen wirklich alles abschaltet.
18. Bildrate in allen vier Spielen, besonders Schafe hüten (12 Schafe) und auf dem Handheld.
19. Vollbild an/aus.
20. Offene Fragen beim Spielen mitdenken: Q13 (Punkte in Teamspielen), Q14 (Teamfarben Orange/Lila), Q15 (Balance).
