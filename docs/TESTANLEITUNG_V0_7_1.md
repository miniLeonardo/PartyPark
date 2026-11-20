# Testanleitung v0.7.1 „Spielbarkeit Park“

Stand 2026-11-20 (Claude). Am besten mit 2 Controllern, sonst Tastatur links (WASD, Leertaste) und rechts (Pfeile, Enter).
Start: Godot-Editor F5 → Beitritt → Hauptmenü „Freizeitpark (Lobby)“, oder direkt `.\Godot_v4.7.2-stable_win64.exe --path . -- --hub`.
Ergebnis bitte je Nummer mit ok / nicht ok / Bemerkung zurückmelden.

## Park allgemein

1. Im Park laufen nur eure eigenen Figuren herum, keine Computer (D124).
2. Wege, Zonenböden, Karussellboden und Pavillon-Podest kann man ohne Springen betreten (Stufenhilfe).
3. Unten steht die Tastenzeile passend zu euren Geräten (nicht mehr fest „A: Springen“).
4. Kamera-Leine (D121): Lauft in entgegengesetzte Richtungen. Am Bildrand geht es nicht weiter, zurück geht es sofort. Beide bleiben gut erkennbar. Fühlt sich die Leine zu eng oder zu weit an? (Werte `leash_half_extent` in `Hub`, `hub_max_distance` in `HubCamera`.)

## Kletterturm (D122)

5. Der Start ist an der Westseite (Schild „START Kletterturm“). Der Weg läuft vorne herum (zur Kamera) nach oben.
6. Passage 1 (Holzstufen bis 6 m), Passage 2 (Metallstufen bis 12 m, in der Mitte eine Plattform, die auf und ab fährt), Passage 3 (gelbe Pfähle bis 18 m). Ist alles mit dem Controller schaffbar? Wie schwer fühlt es sich an (zu leicht / passt / zu schwer)?
7. Wer in Passage 2 oder 3 einen Sprung verpatzt, landet auf dem dunklen Netz der Etage darunter (6 m bzw. 12 m) und nicht ganz unten.
8. Oben: In die schwebende Krone hineinlaufen setzt sie auf. Schubst ein anderer den Träger, fliegt die Krone weg und bleibt irgendwo liegen; Hinlaufen hebt sie auf.
9. Den roten Knopf oben betreten: Konfetti und Ansager-Spruch mit eurem Namen (vorher stand dort „{winner}“).
10. Die Kamera zeigt Kletternde und Spieler am Boden gleichzeitig, und oben verdeckt nichts mehr die Figuren.

## Spielplatz

11. Rutsche (Spielzeug-Wiese, Westen): Treppe hinauf, oben auf die blaue Bahn, man wird schneller, am roten Ende springt man ab.
12. Trampoline: Hinauflaufen oder -springen wirft hoch, aus größerer Höhe höher.
13. Karussell (Rummel, Osten): Man fährt mit und wird leicht nach außen gedrückt. Durch die Mittelsäule kann man nicht mehr laufen.
14. Wippe: kippt nur, wenn jemand darauf steht, und taucht nicht mehr in den Boden.

## Minispiele aus dem Park (D123, D125)

15. Eine Bude: Ein Spieler allein auf der blauen Platte zeigt „1/2 Alle auf die Platte!“. Springen startet nichts.
16. Alle auf der Platte: Countdown 3-2-1. Geht einer runter, bricht er ab.
17. Das Minispiel läuft in seiner normalen Arena (ohne Brunnen, Rasen oder Parkbesucher darin), mit Computern aufgefüllt. Herunterfallen scheidet wieder aus.
18. Nach dem Ergebnis landet ihr vor der Bude (nicht auf der Platte), und das Spiel startet nicht von selbst neu.
19. Turnier-Pavillon: Die Platte und der lila Rundenschalter sind sichtbar. Nur Menschen schalten 5/10 Runden um.
20. Turnier aus dem Pavillon starten, über Pause „Zum Hauptmenü“ abbrechen, dann ein Turnier aus dem Hauptmenü spielen: Danach geht es ins Hauptmenü, nicht in den Park.

## Minispiele (Durchsicht 2026-11-20)

Am einfachsten über Hauptmenü → Freies Spiel, oder direkt `.\Godot_v4.7.2-stable_win64.exe --path . -- --play=<id>` (IDs: bumper_cars, tug_of_war, giant_vs_dwarfs, sheep_herding, hex_fall, hot_potato, blaster_brawl).

21. Autoscooter: Ein Ring unter dem Wagen wächst beim Aufladen und leuchtet gelb, wenn der Turbo (X) bereit ist (D128). Frontal-Zusammenstöße fühlen sich fair an (beide fliegen zurück). Nach dem Rausfallen setzt man nicht direkt auf einem anderen Wagen ein.
22. Tauziehen: Gemeinsam im Takt drücken zieht deutlich stärker, der Kraftakt (Y) braucht 6 Synchrontakte (D126). Am Ende steht die Seilmarke am Ziel, und „Zug!“ verschwindet von den Köpfen.
23. Riese gegen Zwerge: Holt der Riese zum Stampfen aus, füllt sich ein roter Kreis am Boden (D127). Zwerge kommen nur durch eigenes Umrunden voran, nicht wenn der Riese an ihnen vorbeiläuft. Fällt der Riese, kippen die Seilringe mit.
24. Schafe hüten: Ein Schaf zählt erst, wenn es ganz im Gehege ist (Zähler flackert nicht mehr). Den Wolf verjagt man mit Schubsen (steht jetzt in der Tastenerklärung). Er rennt weg statt im Boden zu versinken. Nach Spielende bleiben die Schafe stehen.
25. Wackelwaben: Auf einer Fuge zwischen zwei Waben stehen bleiben rettet nicht mehr; beide Waben fallen. Wer stillsteht, fällt durch.
26. Heiße Kartoffel: Der Bombenträger hat einen blinkenden roten Ring und Pfeil, schneller kurz vor der Explosion (D128). Über den Zaun springen geht nicht mehr.
27. Zerfetzung: Unten rechts ist der eigene Spielzeug-Blaster mit Mündungsblitz zu sehen (D129). Dauerfeuer überhitzt nach einigen Sekunden. Schüsse gehen nicht mehr durch Kisten, wenn man direkt davor steht. Mit 2 oder 3 Spielern zeigen die freien Viertel eine Trefferübersicht statt einer Karte von oben. Bei Zeitablauf: weniger erlittene Treffer gewinnen, bei Gleichstand mehr verteilte (D130, bitte bestätigen).
28. Allgemein: Läuft alles flüssig? Besonders Zerfetzung mit 4 Spielern bitte mit F3 (Leistungsanzeige) prüfen.
