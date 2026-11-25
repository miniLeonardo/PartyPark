# Testanleitung v0.7.2 „Ideen aus dem Deck“

Stand 2026-11-25 (Claude). Am besten mit 2 bis 4 Controllern. Start: Godot-Editor F5.
Ergebnis bitte je Nummer mit ok / nicht ok / Bemerkung zurückmelden.

## P3 Handicap je Spieler (D135)

1. Im Beitrittsbildschirm steht auf jeder Spielerkarte „Stufe: Normal“. Steuerkreuz oder Stick links/rechts wechselt zwischen Profi, Normal und Entspannt; Austreten setzt wieder auf Normal.
2. Im Spiel ist die Stufe nirgends zu sehen.
3. Spürbar? Entspannt läuft etwa 10 % schneller, wird von Schubsern weniger weit geschleudert und hat im Tauziehen ein 1,5-fach größeres Taktfenster; Profi umgekehrt (etwas langsamer, rutscht weiter, engeres Fenster). Passen die Stärken? (Werte oben in `core/teams/handicap.gd`)

## P2 Kronenjagd im Park (D134)

4. Mit mindestens 2 Spielern im Park die Krone oben vom Turm holen: Oben erscheint „KRONENJAGD 60“, über allen Köpfen steht die Tragezeit, der Führende hat ein ♛.
5. Krone abschubsen und aufheben: Die Zeit zählt nur beim Träger weiter.
6. Nach 60 s: Banner „… ist König des Parks!“, Konfetti, die Parkbesucher jubeln; nach 4 s fliegt die Krone zurück auf die Turmspitze, eine neue Jagd startet beim nächsten Aufsetzen.
7. Allein im Park startet keine Jagd.

## P1 Doppelgänger-Gewusel (D132, D133, D136, D137)

8. Freies Spiel → Doppelgänger-Gewusel (1 gegen 3). Regelbildschirm: Wächter und Doppelgänger haben eigene Texte und Tasten.
9. Doppelgänger: Y lässt die eigene Figur 0,7 s in Spielerfarbe aufblinken. Findet ihr eure Figur zuverlässig? Verrät das Blinken zu viel?
10. Die aktive Bude hat eine leuchtende Kugel und einen Ring am Boden. B an der aktiven Bude 2 s halten erledigt die Aufgabe (leichtes Vibrieren währenddessen), danach leuchtet eine andere. 4 Aufgaben gewinnen.
11. Laufen Doppelgänger und Besucher wirklich gleich schnell und sehen gleich aus? Was verrät euch als Wächter am meisten?
12. Wächter: Stick bewegt das rote Fadenkreuz, A (oder rechte Schultertaste) schießt; 3 Schüsse, 1,5 s Nachladen. Treffer auf einen Doppelgänger färbt ihn ein und nimmt ihn raus, ein Besucher plumpst um und steht nach 3 s wieder auf.
13. Fühlt sich die Runde fair an? (Spieltest mit Computern: Wächter gewinnt etwa 5 von 12 Runden, Dauer 35 bis 90 s.)

## Optik (5.3, 5.4)

14. Randlicht „dezent“ (D138): Figuren haben am Abend einen leichten hellen Rand. Stört er irgendwo?
15. Kenney-Modelle (Bäume, Buden, Besucher im Park, Blaster) nutzen jetzt komprimierte Texturen: Sehen Farben gestuft oder in der Ferne verwaschen aus?
16. Optionen → Grafikstufe wechseln: Glow und Umgebungsverdeckung (SSAO) ändern sich sofort, nicht erst in der nächsten Szene.
