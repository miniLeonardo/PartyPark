# Testanleitung Patch v0.7 „Der Park“

Ergebnis bitte als „Nummer: ok“ oder „Nummer: Problem, was genau passiert ist“ zurückmelden, dazu persönliche Eindrücke. Es wird im DEVLOG eingetragen. Am besten mit bis zu vier Gamepads testen, Tastatur ergänzend.

---

## Schnellstart

1. **Direkt aus dem Hauptmenü:** Im Hauptmenü den neuen Menüeintrag **„Freizeitpark (Lobby)“** wählen.
2. **Entwickler-Schnellstart über die Konsole:**
   ```powershell
   .\Godot_v4.7.2-stable_win64_console.exe --hub
   ```
   (Startet direkt in den Freizeitpark mit 4 Spielern: alle angeschlossenen Gamepads/Tastaturen werden belegt, freie Plätze mit Bots gefüllt).
3. **Fertige Windows-EXE testen:** Die neu gebaute eigenständige Datei `builds/windows/Partypark.exe` starten.

---

## Teil 1: Kletterturm & Jump'n'Run (D100, D107, D108)

1. **Aufstieg am Kletterturm (Nord-Zone):**
   - Laufe von der zentralen Plaza durch das Tor nach Norden zum 20 Meter hohen Kletterturm.
   - Passage 1: Holzspiral-Balken und Trampolin-Sprung auf Plattform 1 (6 m).
   - Passage 2: Rotierende Drehkreuze und Schwebestufen auf Plattform 2 (12 m).
   - Passage 3: Schmale Balancier-Pfähle und Launchpad zur Spitze (20 m).
   - *Frage an Leonardo:* Fühlt sich der Parkour knackig und fordernd an? Reichen die beiden Auffangnetze bei Fehltritten aus, um Frust zu vermeiden?

2. **Siegerkrone (D108):**
   - Erreiche die Aussichtsplattform an der Turmspitze.
   - Nimm die schwebende Siegerkrone auf: Setzt sie sich sichtbar auf deinen Kopf?
   - Lass dich von einem Mitspieler schubsen: Springt die Krone im weiten Bogen ab, prallt am Boden ab und kann vom Mitspieler aufgesetzt werden?

3. **Konfetti-Buzzer:**
   - Tritt auf den großen roten Buzzer auf der Turmspitze. Lösen Konfetti-Explosion, Jubelsound, Ansagerspruch und leichtes Bildschirmwackeln sauber aus?

---

## Teil 2: Bewegungs- & Platforming-Spielplatz (D103 bis D106)

4. **Ost-Trampolin (D103):**
   - Springe auf das große runde Trampolin in der Rummel-Zone.
   - Federt ein normaler Sprung sanft ab (~8 m)? Wenn du von höherer Position herabfällst: Katapultiert dich das Trampolin dynamisch bis zu 22 Meter hoch in den Himmel?

5. **Schanzen-Rutsche (D104):**
   - Klettere auf den Holzturm der Rutsche in der West-Zone und rutsche die Rampe hinab.
   - Gleitet die Figur ohne Reibung rasant nach unten? Lässt sich der Rutschwinkel per Stick leicht korrigieren? Hebt die Figur an der Auslauf-Schanze ab?

6. **Rummel-Karussell (D105):**
   - Betrete das sich drehende Karussell im Rummelplatz.
   - Dreht sich die Spielfigur mit? Ist die Zentrifugalkraft spürbar, die Figuren nach außen drängt?

7. **Wippe & Teich-Pendel (D106):**
   - Teste die physikalische Wippe: Kippt der Balken physikalisch zur schwereren Seite, wenn sich Spieler darauf bewegen?
   - Fahre mit der Schwebefähre über den Teich und nutze den Vertikallift zum Kletterturm.

---

## Teil 3: Attraktions-Portale & Minispiel-Einstieg (D109 bis D112)

8. **Kirmes-Buden (D109):**
   - Laufe den Süd-Boulevard entlang. Sind die Minispiel-Buden mit bunten Baldachin-Dächern, Themen-Wimpeln und leuchtenden Aktivierungs-Platten gut erkennbar?

9. **Ready-Countdown (D111):**
   - Stelle alle menschlichen Spieler auf die leuchtende Platte einer Minispiel-Bude.
   - Startet der 3-Sekunden-Countdown mit Tonsignalen (Tick, Tick, Tick, Los!)?
   - Bricht der Countdown sofort ab, wenn ein Spieler die Platte vor Ablauf verlässt?

10. **Nahtlose Rückkehr in die Lobby (WP 7):**
    - Nach Ablauf des Countdowns startet das Minispiel.
    - Spiele das Minispiel zu Ende: Kehren alle Spieler nach der Ergebnis-Anzeige nahtlos und unversehrt in den Freizeitpark zurück?

11. **Turnier-Pavillon (D110):**
    - Gehe zum großen Turnier-Pavillon am Kopf des Süd-Boulevards.
    - Wechsle die Rundenzahl (5 oder 10 Runden) über den Umschalter.
    - Betrete mit allen Spielern die Aktivierungs-Platte des Pavillons: Startet das Turnier und führt es nach der Siegerehrung wieder in den Park zurück?

12. **Wegweiser (D112):**
    - Sind die bunten Wegweiser an den Kreuzungen der Plaza klar lesbar und weisen zuverlässig den Weg?

---

## Teil 4: Großraum-Kamera & Parkbesucher (D113 bis D117)

13. **Kameraführung & Offscreen-Pfeile (D113):**
    - Bewegen sich Spieler weit auseinander: Stoppt der Zoom sanft bei maximal 46 Metern Abstand?
    - Erscheinen für Spieler außerhalb des Sichtfelds bunte Pfeile in ihrer Spielerfarbe am Bildschirmrand inklusive Meter-Distanz?

14. **Turm-Neigung (D114):**
    - Klettere den Turm hinauf: Neigt sich der Kamerawinkel dynamisch von 48° (am Boden) auf bis zu 38° (in Kletterhöhe), um eine freie Sicht auf das Parkpanorama zu bieten?

15. **Lebendige Parkbesucher (D115):**
    - Beobachte die 30 Kenney Mini Characters am Wegrand: Haben sie lebendige Idle-Animationen (Wippen, Winken, Kopfbewegen)?
    - Renne nah an ihnen vorbei oder lande neben ihnen: Jubeln und hüpfen sie freudig auf?

16. **Pulsierende Lichterketten (D116):**
    - Schwingt die Lichtstärke der bunten Glühbirnen über der Plaza sanft im Takt?
    - Teste die Abend-Stimmung (Optionen → Tageszeit „Abend“): Leuchten Lichterketten und Parklaternen abends deutlich intensiver?

17. **Audio-Atmosphäre (D117):**
    - Höre auf die Klangkulisse:
      - Plaza: Heiteres Parkgemurmel und Vogelgesang.
      - Rummel (Ost): Fröhliches Kirmes-Bimmeln.
      - Turm (Nord): Sanfte Windböen in Kletterhöhe.

---

## Teil 5: Leistung & Standalone-Build

18. **Bildrate (F3):**
    - Drücke F3: Werden auch im vollen Park mit 4 Spielern und 30 Besuchern stabile 60 fps erreicht?
19. **Partypark.exe:**
    - Lässt sich die eigenständige Datei `builds/windows/Partypark.exe` ohne Entwicklungsumgebung direkt starten und spielen?
