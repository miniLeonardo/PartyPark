# Partypark: Game Design

Stand: 2026-10-19 (nach M3). Status je Abschnitt: **entschieden**, **Vorschlag** (noch nicht bestätigt) oder **offen**. Was hier als Vorschlag steht, darf erst nach Rückfrage bei Leonardo umgesetzt werden (siehe `AGENTS.md`).

## 1. Vision (entschieden)

Ein lustiges, sehr abwechslungsreiches 3D-Partyspiel für bis zu 4 Spieler auf der Couch. Jeder hat einen Controller, alle schauen auf einen Bildschirm. Vorbild sind die Minispielsammlungen von Nintendo: kurze Runden, sofort verständliche Regeln, viel Schadenfreude und Momente, über die man lacht.

Kernerlebnis: „Noch eine Runde!“ Jedes Minispiel ist in unter 10 Sekunden erklärt und in 1 bis 3 Minuten gespielt.

## 2. Plattformen und Eingabe (entschieden)

| Punkt | Festlegung |
|---|---|
| Spieler | 1 bis 4 lokal, fehlende Plätze mit Computergegnern auffüllen, im Beitritt abschaltbar (D19) |
| Eingabe | Gamepads (Xbox, PlayStation, Steam Deck, Switch-Pro über Steam Input)(Tastatureingabe zum Testen des spiels) |
| Plattformen | Windows, Linux (Bazzite, auch Handheld) |
| Darstellung | 3D, ein gemeinsamer Bildschirm, kein Splitscreen |

## 3. Teamformate (entschieden)

| Format | Kurz | Beschreibung |
|---|---|---|
| Alle gegen den Computer | 4vCPU | Koop gegen Bosse, Wellen oder Zeit |
| Jeder gegen jeden | FFA | klassisches Gegeneinander |
| Zwei gegen zwei | 2v2 | Teamspiele, Paarungen wechseln |
| Einer gegen drei | 1v3 | asymmetrisch, der Solo-Spieler hat eine starke Sonderrolle |

Später denkbar: 1v1-Duelle, wenn zwei Spieler gleichauf liegen.

## 4. Rahmen: Wie die Minispiele zusammenhängen (offen)

Die Minispiele bilden einen gemeinsamen Pool. Darüber liegen Spielarten, die den Pool nutzen:

| Spielart | Beschreibung | Status |
|---|---|---|
| Schnellturnier | 5 oder 10 zufällige Minispiele, 3/2/1/0 Punkte, Siegerehrung (D31, D32) | gebaut |
| Freizeitpark-Hub | begehbares 3D-Gelände, Attraktionen sind Minispiele (wie Nintendo Land). Passt zum Namen Partypark | Vorschlag |
| Brettspiel | Würfeln, Felder, Münzen, Sterne, Feldfarben bestimmen das Teamformat (wie Mario Party) | Idee, später |
| Koop-Kampagne | Abfolge von 4vCPU-Spielen mit wiederkehrendem Endboss | Idee, später |
| Freies Spiel | einzelnes Minispiel wählen, Teams selbst festlegen (D40) | gebaut |

**Offene Frage:** Was ist langfristig das Herzstück, Hub oder Brettspiel?

## 5. Teamzuweisung (entschieden, D32)

1. Glücksrad oder Würfel vor jeder Runde, Formate gewichtet (1v3 seltener)
2. Aufholmechanik: Der Letztplatzierte wird Solo-Spieler im 1v3 und bekommt die starke Rolle
3. 2v2-Paarungen zufällig, aber nie zweimal hintereinander dieselbe
4. Im Brettspielmodus später über Feldfarben

## 6. Ablauf jedes Minispiels (entschieden, D33: ohne Übungsrunde)

1. **Ankündigung:** Name, Teamformat, Teams farbig dargestellt
2. **Regelbildschirm:** ein Satz Ziel, Steuerung mit Controller-Symbolen, kleine Vorschau
3. ~~Übungsrunde~~ entfällt (D33); stattdessen drückt jeder auf dem Regelbildschirm A für „Bereit“
4. **Countdown** 3, 2, 1, Los
5. **Spiel**
6. **Ende:** kurze Zeitlupe beim entscheidenden Moment
7. **Ergebnis:** Sieger-Pose, Verlierer-Animation, Punkte fliegen ins Gesamtergebnis

## 7. Spielfigur (entschieden, D15, D16)

Eine gemeinsame Figur für alle Minispiele, damit Steuerung und Animationen nur einmal gebaut werden. Grundfähigkeiten: Laufen, Springen, Schubsen, Aktionstaste. Pro Minispiel werden Fähigkeiten an- oder abgeschaltet oder ersetzt (Werfen, Tragen, Taschenlampe).

Entschieden: eigene runde Knubbelfigur, ganzer Körper in Spielerfarbe, präzise Steuerung mit optischem Wackeln. In Teamformaten zusätzlich ein farbiger Ring unter den Füßen (Q14).

## 8. Grafik- und Tonstil (Thema entschieden, D17)

Vorschlag: einheitlicher Low-Poly-Stil mit freien Paketen von Kenney und Quaternius (CC0), kräftige Farben, jede Spielerfarbe klar unterscheidbar (auch für Farbsehschwäche prüfen). Thema und Tonalität sind offen.
Wichtig: Performance muss stimmen, das Spiel muss auf einer Integrierten Radeon 780m mit 60fps laufen

## 9. Minispiel-Pool (Ideen, alle noch Vorschlag)

### Alle gegen den Computer

| ID | Name | Idee |
|---|---|---|
| vacuum_boss | Staubsauger-Boss | Riesiger Saugroboter jagt alle durchs Wohnzimmer; Eingesaugte müssen freigeklopft werden |
| spaceship_repair | Raumschiff flicken | Lecks stopfen, Feuer löschen, Strom umleiten, alles gleichzeitig |
| castle_defense | Burgverteidigung | Gegnerwellen, jeder bemannt eine andere Kanone |
| sheep_herding | Schafe hüten | Chaotische Herde gemeinsam ins Gehege treiben |

### Jeder gegen jeden

| ID | Name | Idee |
|---|---|---|
| ice_floe | Eisscholle | Sumo auf schmelzendem Eis, wer zuletzt steht, gewinnt |
| musical_chairs | Reise nach Jerusalem | Musik stoppt, ein Stuhl zu wenig |
| bumper_cars | Autoscooter | Gegner aus der Arena schubsen, Leben zählen |
| quick_draw | Western-Duell | Reaktionstest, wer zu früh drückt, fliegt |
| hot_potato | Heiße Kartoffel | Bombe per Berührung weitergeben, Zündschnur zufällig |
| color_war | Farbkrieg | Meiste Bodenfläche in eigener Farbe nach 60 Sekunden |

### Zwei gegen zwei

| ID | Name | Idee |
|---|---|---|
| rowing | Ruderboot | Jeder steuert ein Ruder, Synchronität entscheidet |
| beach_volley | Strand-Volleyball | mit viel zu großem Wasserball |
| sedan_carry | Sänftenträger | Zwei tragen eine wackelnde Ladung durch einen Parcours |
| tug_of_war | Tauziehen | Rhythmus-Drücken statt Hämmern |

### Einer gegen drei

| ID | Name | Solo-Rolle | Team-Rolle |
|---|---|---|---|
| ghost_house | Geisterhaus | unsichtbarer Geist | drei Jäger mit Taschenlampen, Vibration bei Nähe |
| giant_vs_dwarfs | Riese gegen Zwerge | riesig, langsam, stampft | winzig, bringen ihn mit Seilen zu Fall |
| chase | Fangen | Vorsprung, wird gejagt | Jäger mit grober Karte |
| chef_and_mice | Koch und Mäuse | Koch mit Pfanne und Fallen | Mäuse stehlen Käse |

**Problem geheimer Informationen auf einem Bildschirm:** Nintendo Land nutzte dafür einen zweiten Bildschirm. Lösungsideen für uns: Vibration, Geräusche, kurzes Aufblitzen im Licht, Regeln, die auch mit offenen Karten funktionieren.

## 10. Vertical Slice für den ersten Prototyp (entschieden, D30, gebaut)

Je ein Spiel pro Format, im Schnellturnier spielbar:

1. FFA: Autoscooter (`bumper_cars`, D34)
2. 2v2: Tauziehen (`tug_of_war`, D35)
3. 1v3: Riese gegen Zwerge (`giant_vs_dwarfs`, D36)
4. 4vCPU: Schafe hüten (`sheep_herding`, D37)

Ursprünglicher Vorschlag (Eisscholle, Ruderboot, Geisterhaus, Staubsauger-Boss) bleibt im Pool für später.

## 11. „Juice“: Was das Spiel lustig macht (Vorschlag)

Bildschirmwackeln, kurze Freeze-Frames bei Treffern, übertriebene Ragdoll- oder Wackelanimationen, Partikel, Soundeffekte für jede Aktion, witzige Ansager-Texte, Verlierer-Animationen.
