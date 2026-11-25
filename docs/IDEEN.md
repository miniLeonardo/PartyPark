# Partypark: Ideen (M und P)

Diese Datei sammelt Spielideen mit fester Nummer, passend zu den Karten im Nextcloud-Deck „PartyPark“. **M-Nummern** sind noch nicht gebaute Minispiele aus `docs/GAME_DESIGN.md` Abschnitt 9 (ähnliche Ideen zusammengefasst), **P-Nummern** neue Vorschläge, die dort noch nicht stehen. Roadmap-Punkte (5.x bis 10.x) stehen weiter nur in `docs/ROADMAP.md`.

Alles hier ist **Vorschlag** (D08, AGENTS Regel 1): Vor der Umsetzung wird jede Idee mit Leonardo abgestimmt, die Entscheidung kommt als Dxx in `docs/DECISIONS.md`. Neue Idee = nächste freie Nummer hier und neue Karte im Deck; wird eine Idee gebaut, Karte verschieben und hier „gebaut (Dxx)“ ergänzen. Nummern werden nie neu vergeben. Mechaniken aus anderen Spielen sind erlaubt, Figuren, Namen, Grafiken und Musik nicht (ROADMAP Leitplanke 5).

## M: Minispiele aus dem Pool

### M1 Zielscheiben-Rallye

Schießbude mit Fadenkreuz je Spieler auf Klappziele und Pappfiguren, Fehlschüsse auf Oma-Figuren kosten Punkte. Die Wurfbude (Bälle auf Dosenpyramiden) ist hier als Variante eingeschlossen. Für v0.6 ausgewählt (D93).

Herkunft: `docs/GAME_DESIGN.md`, 9.7 target_rally und 9.6 shooting_gallery.

### M2 Achterbahn-Bremser

Wagen rollt auf eine Kante zu, wer am knappsten bremst, gewinnt; mehrere Durchgänge. Für v0.6 ausgewählt (D93).

Herkunft: `docs/GAME_DESIGN.md`, 9.6 coaster_brake.

### M3 Imbissbude

Einer brät, einer bedient; Bestellungen schneller als das andere Team abarbeiten. Für v0.6 ausgewählt (D93).

Herkunft: `docs/GAME_DESIGN.md`, 9.6 snack_stand.

### M4 Wildwasserbahn

Jeder steuert ein Ruder, Synchronität entscheidet; Freizeitpark-Gewand des alten Ruderboots. Für v0.6 ausgewählt (D93).

Herkunft: `docs/GAME_DESIGN.md`, 9.6 log_flume (ersetzt rowing).

### M5 Der Spielleiter

Der Solo-Spieler kippt die Arena und lässt Hindernisse fallen, das Team überlebt 60 s. Für v0.6 ausgewählt (D93).

Herkunft: `docs/GAME_DESIGN.md`, 9.6 game_master.

### M6 Gleisbau

Achterbahnzug rollt unaufhaltsam, Team holt Schienenstücke und legt sie rechtzeitig. Für v0.6 ausgewählt (D93).

Herkunft: `docs/GAME_DESIGN.md`, 9.6 track_builder.

### M7 Zuckerwatte-Duell

Reaktionsspiel mit Fehlsignalen, zu früh drücken heißt aussetzen; auch als Finalduell geeignet.

Herkunft: `docs/GAME_DESIGN.md`, 9.5 quick_draw.

### M8 Karussell-Chaos

Drehende Scheibe mit Fliehkraft und Goldringen in der Mitte; die Eisscholle (Sumo auf schmelzendem Eis) ist als Variante eingeschlossen.

Herkunft: `docs/GAME_DESIGN.md`, 9.5 carousel und 9 ice_floe.

### M9 Farbkrieg

Boden einfärben, meiste Fläche nach 60 s; das Farbbeutel-Fort (2v2 mit Fahnenklau) als Variante.

Herkunft: `docs/GAME_DESIGN.md`, 9.6 paint_park, 9.7 paint_fort.

### M10 Geisterbahn-Jagd

Unsichtbarer Geist gegen drei Jäger mit Lichtkegeln, Vibration verrät Nähe; Parkwächter als umgekehrte Variante.

Herkunft: `docs/GAME_DESIGN.md`, 9 ghost_house, 9.7 ghost_blasters, 9.6 park_guard.

### M11 Gummiband-Rennen

Zwei Spieler an einem Gummiband im Hindernislauf; der Sänftenträger (wackelnde Ladung zu zweit tragen) als Variante.

Herkunft: `docs/GAME_DESIGN.md`, 9.6 chained_race, 9 sedan_carry.

### M12 Staubsauger-Boss

Saugroboter jagt alle, Eingesaugte werden freigeklopft; Grundlage für den Endboss der Kampagne.

Herkunft: `docs/GAME_DESIGN.md`, 9 vacuum_boss.

### M13 Achterbahn-Reparatur

Lecks, Funken, Schrauben gleichzeitig beheben; Park-Fassung des Raumschiff-Flickens.

Herkunft: `docs/GAME_DESIGN.md`, 9.6 coaster_repair (ersetzt spaceship_repair).

### M14 Roboter-Invasion

Wellen von Spielzeugrobotern, Team verteidigt Fahrgeschäfte mit Upgrades; Burgverteidigung als Variante.

Herkunft: `docs/GAME_DESIGN.md`, 9.7 robot_invasion, 9 castle_defense.

### M15 Bau-Chaos

Jeder baut ein Hindernis in den Parcours, Punkte nur, wenn nicht alle und nicht keiner durchkommen.

Herkunft: `docs/GAME_DESIGN.md`, 9.6 build_chaos.

Weitere Pool-Ideen ohne eigene Nummer (bei Bedarf nachnummerieren): Reise nach Jerusalem, Strand-Volleyball, Zwei Köpfe ein Körper, Zuckerwatte-Kugel, Geisterbahn-Gedächtnis, Pünktchenfresser, Fangen, Koch und Mäuse, Wellenbad-Krake, Maskottchen-Parade, Minigolf-Chaos, Wasserpistolen-Duell (Kandidat für 6.6).

## P: Neue Vorschläge

### P1 Doppelgänger-Gewusel

1v3: Drei Spieler verstecken sich unter gleich aussehenden Parkbesuchern und erledigen unauffällig Aufgaben, der Wächter muss sie am Verhalten erkennen und hat nur drei Fangnetze. Löst das Problem geheimer Informationen auf einem gemeinsamen Bildschirm, weil alle alles sehen. Empfohlen.

Status: gebaut 2026-11-25 als `minigames/doppelganger/` (D132, D133: Blaster statt Netz, D136, D137).

Herkunft: neu (Claude, 2026-11-22).

### P2 Kronenjagd im Park

Wer die Turmkrone holt, startet 60 Sekunden Kronenjagd; gezählt wird die Tragezeit, die anderen schubsen sie herunter. Baut fast nur auf Krone (D108), Schubsen und Ansager auf. Empfohlen.

Status: gebaut 2026-11-25 (D134), `modes/hub/tower/crown_hunt.gd`.

Herkunft: neu (Claude, 2026-11-22).

### P3 Handicap je Spieler

Jeder wählt im Beitritt eine Stufe (Profi, Normal, Entspannt), die Minispiele über einen Faktorsatz berücksichtigen (Tempo, Trefferradius, Reaktionsfenster). Damit spielen Kinder und Geübte gemeinsam. Empfohlen.

Status: gebaut 2026-11-25 (D135), `core/teams/handicap.gd`.

Herkunft: neu (Claude, 2026-11-22).

### P4 Entenangeln

FFA am Kirmesbecken: Gummienten auf Kreisbahn angeln, goldene zählen dreifach, Haken der anderen verheddern. Klein und leicht für die Grafik.

Herkunft: neu (Claude, 2026-11-22).

### P5 Kettenkarussell-Ringstechen

FFA im Kettenkarussell: durch Gewichtsverlagerung Schwung holen und Ringe an Masten schnappen, Rempler lassen Gegner zurückpendeln. Auch als Gerät im Park.

Herkunft: neu (Claude, 2026-11-22).

### P6 Popcorn-Regen

FFA: Popcorn aus einer Riesenmaschine mit dem Eimer auf dem Kopf fangen, Schubsen wirft einen Teil aus, angebrannte Körner lassen den Eimer überkochen.

Herkunft: neu (Claude, 2026-11-22).

### P7 Formwand

FFA: Eine Wand mit Figurloch rückt heran, wer rechtzeitig die passende Haltung einnimmt, schlüpft durch. Braucht die Posen aus ROADMAP 5.5.

Herkunft: neu (Claude, 2026-11-22).

### P8 Hau den Lukas

Park-Station am Rummel: Kraftbalken im richtigen Moment stoppen, Glocke und Tagesrekord. Sehr kleiner Aufwand, gut für Wartezeiten.

Herkunft: neu (Claude, 2026-11-22).

### P9 Park-Ereignisse

Zufällige Ereignisse im Park: kleine Parade, Ballonverkäufer, Sommerregen mit Pfützen. Nur Kulisse, keine Computerspieler (D124).

Herkunft: neu (Claude, 2026-11-22).

### P10 Siegertipp

Auf dem Regelbildschirm tippt jeder heimlich auf den Sieger, richtige Tipps bringen einen kleinen Bonus. Abschaltbar.

Herkunft: neu (Claude, 2026-11-22).

### P11 Feste Spielerprofile

Profile mit Name, Lieblingsfarbe, Hut und Statistik, beim Beitritt wählbar. Grundlage für Sammelalbum, Rekorde und Bonustitel.

Herkunft: neu (Claude, 2026-11-22).

### P12 Dynamische Auflösung

Technik: Die 3D-Auflösung passt sich bei Einbrüchen automatisch an, damit 60 fps auf Radeon 780M und Steam Deck gehalten werden.

Herkunft: neu (Claude, 2026-11-22).
