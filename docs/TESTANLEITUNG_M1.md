# Testanleitung Meilenstein M1 „Kern“

Stand: 2026-10-19. Ergebnis bitte als Liste „Nummer: ok“ oder „Nummer: Problem, was genau passiert ist“ zurückmelden; es wird im DEVLOG eingetragen.

Automatisch bereits geprüft (Cloud, ohne echte Controller): headless Import fehlerfrei, Smoke-Test `godot --headless --path . -- --smoke-m1` mit 37 von 37 Prüfungen grün (simulierte Tastatur- und Gamepad-Eingaben, Beitritt, Doppelgänger-Schutz, unabhängige Steuerung, Deadzone, Sprung, Schubsen, Pause, Abziehen, Wiederanstecken, Übernahme, Respawn, Rückkehr zum Beitritt). Was nur am echten Rechner geht, steht unten.

## Teil A: Windows (Arbeitsrechner oder Spiele-PC)

1. Godot 4.6.x starten, Projekt `partypark` importieren bzw. öffnen. Im Ausgabe-Panel unten dürfen keine roten Fehler stehen. Godot ergänzt beim ersten Speichern `uid`-Einträge in `.tscn`-Dateien; das ist normal und darf mit committet werden.
2. **F5** drücken. Der Beitrittsbildschirm erscheint mit vier Podesten. Bei eingeschalteten Computergegnern stehen dort blasse Figuren mit „CPU“.
3. **Tastatur:** Leertaste drücken. Spieler 1 (blau) wird „Tastatur links“, die Figur steht auf Podest 1 und hüpft bei jeder weiteren Leertaste. Enter drücken: Spieler 2 wird „Tastatur rechts“. E bzw. Rücktaste lässt sie wieder austreten.
4. **Controller:** Einen Controller nach dem anderen A drücken lassen. Jeder belegt den nächsten freien Platz, die Karte zeigt den Controllernamen, der Controller vibriert kurz. Mit B austreten, mit A wieder beitreten. Bis zu 4 Controller gleichzeitig ausprobieren.
5. Prüfen, dass A auf Controller X nur die Figur von Controller X hüpfen lässt.
6. **Y** auf einem beigetretenen Controller schaltet „Computer auffüllen“ an und aus (Hinweiszeile unten).
7. **Start** auf einem beigetretenen Controller startet die Testarena. Es stehen so viele Figuren wie Plätze belegt sind (mit Computer immer 4; Computer stehen in M1 nur herum).
8. In der Arena bewegt jeder seine Figur mit linkem Stick oder Steuerkreuz. Prüfen: keine Figur reagiert auf einen fremden Controller; ein leicht angetippter Stick bewegt nichts (Deadzone).
9. **A** springt. Kurz tippen ergibt einen kleinen, lang halten einen hohen Sprung. Auf die lila Stufen, die graue Rampe und über die Lücke zur Sandinsel rechts springen.
10. **X** schubst. Getroffene fliegen ein Stück weg und wackeln. Vibration: Schubsender kurz und schwach, Getroffener stark.
11. Über eine Kante in den Abgrund laufen. Die Figur erscheint über ihrem Startpunkt wieder, der Controller vibriert.
12. Die Kamera hält alle Figuren im Bild und zoomt heraus, wenn sie sich verteilen.
13. **Start** öffnet das Pause-Menü, der Titel nennt den Spieler. Ein anderer Spieler kann mit dem Stick navigieren und auswählen (D21). B oder Start schließt. Alle drei Einträge ausprobieren: Weiter, Zurück zum Beitritt (Menschen bleiben beigetreten), Spiel beenden.
14. **Abziehen:** Während der Arena einen Controller trennen (Kabel ziehen oder Bluetooth aus). Das Spiel pausiert mit „Controller getrennt, Spieler N“. Denselben Controller wieder verbinden: Der Platz wird automatisch übernommen, das Spiel läuft weiter.
15. **Übernahme:** Wieder einen Controller trennen und dann auf einem anderen, noch nicht beigetretenen Controller A drücken. Er übernimmt den Platz.
16. **Doppelte Controller:** Falls Steam läuft, prüfen, ob ein Controller beim Beitritt zwei Plätze belegt (sollte nicht passieren). Im Ausgabe-Panel steht pro erkanntem Gerät eine Zeile „InputRouter: Controller verbunden (ID, Name)“. Bitte notieren, wie viele Zeilen pro physischem Controller erscheinen.
17. **Gefühl (Q12):** Tempo, Sprunghöhe, Trägheit, Schubsstärke, Wackeln und Kameraabstand bewerten. Alle Werte stehen im Inspektor: `player/player.tscn` (Knoten Player: Laufen, Schwerkraft, Rückstoß; JumpAbility; PushAbility; Visual: Feder und Laufen) und `modes/test_arena/test_arena.tscn` (Knoten ArenaCamera). Tipp: `test_arena.tscn` öffnen und **F6** drücken, dann treten alle Tastaturen und Controller automatisch bei.
18. **Aussehen (Q10, Q11):** Sind die vier Spielerfarben gut unterscheidbar, auch auf dem Fernseher? Passen Titel, Texte und die Y-Taste für Computergegner?

## Teil B: Bazzite (Desktop-Modus, Handheld oder PC)

1. Godot 4.6.x als Flatpak `org.godotengine.Godot` installieren und den Projektordner übertragen (USB-Stick oder Git, siehe Q09).
2. Godot aus einem Terminal starten, damit die Ausgabe sichtbar ist: `flatpak run org.godotengine.Godot --path <Projektordner>`. Projekt öffnen, F5.
3. Schritte A2 bis A15 mit den vorhandenen Controllern wiederholen. Auf dem Steam Deck zählt der eingebaute Controller als eigener Spieler.
4. Schritt A16 hier besonders beachten: Unter Bazzite stellt Steam Input Controller oft als virtuelles Xbox-Pad bereit. Bitte die Zeilen „InputRouter: Controller verbunden“ im Terminal notieren und prüfen, ob ein Controller zwei Plätze belegen kann.
5. Bildrate grob einschätzen (flüssig oder ruckelig), besonders auf einem Handheld.
6. Vibration auf jedem Controller prüfen (Beitritt, Schubsen, Absturz).
