# Partypark: Entscheidungen und offene Fragen

Neue Einträge unten anfügen, alte nie löschen. Überholte Entscheidungen mit „ersetzt durch Dxx“ markieren.
Spalte „Von“: **L** = Leonardo, **KI** = technische Entscheidung eines Agenten (Name und Umgebung in Klammern).

## Entscheidungen

| ID | Datum | Entscheidung | Begründung | Von |
|---|---|---|---|---|
| … | | D01 bis D99 (Grundlagen M1 bis v0.6: Eingabe, Teams, Punkte, Ablauf, Look) stehen in `docs/archiv/DECISIONS_D01-D99.md` und gelten weiter, sofern nicht ersetzt | | |
| D100 | 2026-10-21 | Kletterturm-Parkour & Belohnung: Freistehender, vertikaler Kletterturm im Zentrum mit fordernden Sprungpassagen. An der Spitze wartet eine tragbare goldene Siegerkrone (beim Rempler auf andere Spieler übertragbar) sowie ein Aussichtspunkt mit Konfetti-Buzzer | Zentraler Blickfang und sportlicher Wettstreit für alle Spieler | L (Empfehlung angenommen) |
| D101 | 2026-10-21 | Start von Attraktionen: Alle beigetretenen menschlichen Spieler müssen die jeweilige Aktivierungs-Plattform („Ready-Zone“) betreten | Verhindert versehentliche Starts und gibt allen Spielern Zeit zum gemeinsamen Sammeln | L (Empfehlung angenommen) |
| D102 | 2026-10-21 | Lobby-Aktivitäten & Spielzeuge: Umfangreicher Spielzeugkasten für wartende Spieler (Physik-Bälle zum Kicken, harmlose Spielzeug-Blaster aus core/weapons/ mit Schubser-Effekt, tragbare/werfbare Kisten und kleine Mini-Scooter zum Herumkurven) | Maximaler Warte- und Bewegungsspaß auf dem Festplatz | L |
| D103 | 2026-10-21 | Trampolin-Mechanik: Dynamisches Federn je nach Fallhöhe; je höher der Absprung / Fall, desto höher der Rückprall (Basis 8 m, bis zu 22 m bei tiefem Fall) | Belohnt wagemutige Sprünge aus großer Höhe und Parkour-Verknüpfungen | L |
| D104 | 2026-10-21 | Rutsch-Mechanik: Reine Null-Reibungs-Gleitfläche mit Trägheitsphysik; Figur beschleunigt hangabwärts und muss aktiv per Stick gesteuert werden | Anspruchsvoller und dynamischer Bewegungsspaß | L |
| D105 | 2026-10-21 | Karussell & Drehscheiben: Kontinuierliche Rotation mit spürbarer Fliehkraft, die Spieler nach außen drängt | Erzeugt heitere Rempler-Duelle im Rummel-Bereich | L (Empfehlung angenommen) |
| D106 | 2026-10-21 | Bewegliche Plattformen: Vielfältiger Mix aus physikalischen Wippen (Gewichtsreaktion), Schwebeliften und horizontalen Pendeln | Bietet abwechslungsreiche Platforming-Elemente in der Spielplatz-Zone | L (Empfehlung angenommen) |
| D107 | 2026-10-21 | **(Bauform ersetzt durch D122)** Kletterturm-Schwierigkeit: Knackig fordernder Parkour mit schmalen Balken und vertikalen Sprüngen, abgesichert durch Sicherheitsnetze alle 6 Höhenmeter | Verlangt gutes Sprungtiming und verhindert frustrierende Abstürze bis ganz nach unten | L (Empfehlung angenommen) |
| D108 | 2026-10-21 | Siegerkrone-Verhalten: Krone schwebt auf der Turmspitze; wird sie getragen und der Spieler geschubst, springt sie als Physik-Item mit Bogenflug ab, prallt am Boden ab und kann von jedem neu aufgesammelt werden | Sorgt für chaotische, spannende Gerangel um die Krone | L |
| D109 | 2026-10-21 | Stations-Optik: Minispiel-Stationen sind als bunte Kirmes-Buden mit Themenwimpel, Namensschild und leuchtender Aktivierungs-Platte (pulsiert grün bei Betreten) gestaltet | Fügt sich harmonisch in den Kirmes-Stil des Parks ein | L (Empfehlung angenommen) |
| D110 | 2026-10-21 | Turnier-Pavillon: Das Schnellturnier startet an einem prachtvollen Pavillon am Kopf des Süd-Boulevards mit Rundenzahl-Einstellung und vierfarbigen Spieler-Podesten | Bildet den repräsentativen Abschluss des Attraktions-Boulevards | L (Empfehlung angenommen) |
| D111 | 2026-10-21 | Ready-Countdown: Stehen alle menschlichen Spieler auf der Ready-Zone, läuft ein 3-Sekunden-Countdown mit Tonsignal (3, 2, 1, Los!), der beim Verlassen abbricht | Gibt maximale Kontrolle und verhindert Fehlstarts | L (Empfehlung angenommen) |
| D112 | 2026-10-21 | Wegweiser: Holz-Wegweiserpfähle mit bunten, beschrifteten Richtungspfeilen stehen an zentralen Weggabelungen | Bietet intuitive Orientierung zu Turm, Rummel, Attraktionen und Wiese | L (Empfehlung angenommen) |
| D113 | 2026-10-21 | **(Zoom ersetzt durch D121)** Kamera-Zoom & Offscreen-Pfeile: Sanfte Obergrenze des Kamera-Zooms auf max. 46 m Distanz, damit Figuren gut lesbar bleiben; Spieler außerhalb des Viewports erhalten farbige Indikator-Pfeile am Bildschirmrand | Klare Lesbarkeit und verlässliche Orientierung bei weit verteilten Spielern | L (Empfehlung angenommen) |
| D114 | 2026-10-21 | Dynamische Turm-Neigung: Neigungswinkel passt sich an die Höhe der Kletternden an (48° am Boden, bis zu 38° bei Kletterhöhe) | Bietet optimalen Panoramablick und gute Tiefenwahrnehmung bei Präzisionssprüngen | L (Empfehlung angenommen) |
| D115 | 2026-10-21 | Parkbesucher-Verhalten: Lebendige Zuschauer mit Idle-Animationen (Klatschen, Winken, Hüpfen), die freudig reagieren (Jubeln/Ausweichen), wenn Spieler nah vorbeirennen oder landen | Bringt maximale Lebendigkeit in den Park, ohne Wege zu blockieren oder CPU-Last durch Pfadfindung zu erzeugen | L (Empfehlung angenommen) |
| D116 | 2026-10-21 | Beleuchtungs-Dynamik: Festliche Lichterketten mit sanft pulsierenden bunten Birnen, die am Tag dezent glimmen und am Abend hell strahlen | Schafft optimalen Freizeitpark-Flair und nutzt das 3-Stufen-Beleuchtungssystem stimmungsvoll | L (Empfehlung angenommen) |
| D117 | 2026-10-21 | Park-Klangkulisse: Zonenabhängiges Ambiente mit sanftem Parkgemurmel und Blätterrauschen überall, dezenten Kirmes-Klängen im Rummel und Turmwind in der Höhe | Verstärkt das Entdeckungsgefühl und die Eigenheiten der Themenbereiche | L (Empfehlung angenommen) |
| D118 | 2026-10-26 | Zentrales Logging-System (`GameLog`, Autoload `Log`): Datei-Logging in `user://partypark.log` mit Timestamp und Kategorie-Tags, steuerbar über `--verbose`, `--log`, `--log-level=...`, `--no-log-file` | Schnelle Fehlerdiagnose und Rückverfolgbarkeit von Spielabläufen ohne Debugger | KI (Gemini, Antigravity) |
| D119 | 2026-10-26 | **(A-Sofortstart, Hub-Isolation und Bot-Wanderlogik ersetzt durch D123, D124, D125)** Hub-Isolation, Kamera-Fokussierung & Pad-Zustände: Aktivierungs-Pads erhalten Zustandsautomat (IDLE, COUNTING, TRIGGERED, LOCKED, COOLDOWN) mit A-Sofortstart; Hub-Spieler werden während Minispielen per `set_active(false)` aus Gruppe `players` und Physik genommen; HubCamera priorisiert Menschen und begrenzt bot-bedingtes Auszoomen; Bot-Wanderlogik nutzt `world_to_input()` | Behebt festhängende Pads, Geisterspieler in Minispielen, falsche Kamera-Bildausschnitte und inverse Bot-Navigation | KI (Gemini, Antigravity) |
| D120 | 2026-10-26 | Neues GitHub-Repository https://github.com/miniLeonardo/PartyPark.git und Git-User MiniLeonardo (ersetzt D90) | Umstellung auf neuen GitHub-Account von Leonardo | L |
| D121 | 2026-11-20 | Hub-Kamera als „Leine“: gemeinsame Kamera; wer sich mehr als 14 m (seitlich) bzw. 9 m (Tiefe) von der Gruppenmitte entfernt, kann nicht weiter nach außen laufen. Kamera passt Breite, Tiefe und Kletterhöhe ins Bild, Abstand 13 bis 32 m (ersetzt D113 teilweise: Zoom-Obergrenze 46 m entfällt, Pfeile bleiben als Rückfall). Werte als `@export` in `Hub` und `HubCamera` | Figuren bleiben lesbar, kein Splitscreen nötig | L (Empfehlung angenommen) |
| D122 | 2026-11-20 | Kletterturm neu als Außenspirale (ersetzt D107 in der Bauform): Weg windet sich außen am Turm hoch, Etagen bei 6/12/18 m sind Kontrollpunkte; wer abstürzt, landet im Netz und erscheint auf der zuletzt erreichten Etage. Mittelschwer | Alter Turm war unlösbar (Plattformen lagen als Decke über den Wegen), außen bleibt alles im Kamerabild | L (Empfehlung angenommen) |
| D123 | 2026-11-20 | Minispiel-Start an Buden: alle menschlichen Spieler auf dem Pad → 3-s-Countdown, Verlassen bricht ab, kein Knopf (ersetzt den A-Sofortstart aus D119; D111 gilt wieder) | A ist zugleich Springen, ein Sprung startete versehentlich Spiele | L (Empfehlung angenommen) |
| D124 | 2026-11-20 | Keine Computerfiguren im Park; Computer füllen erst im Minispiel auf (ersetzt Bot-Wanderlogik aus D119) | Ruhiger, übersichtlicher, Kamera und Pads hängen nur an Menschen | L (Empfehlung angenommen) |
| D126 | 2026-11-20 | Tauziehen: Synchron-Zug doppelt so stark, Kraftakt braucht 6 statt 4 Synchrontakte (Spieltest: 10 von 12 Runden endeten per Zeit, Kraftakt entschied mehr als Teamarbeit) | Teamarbeit im Takt soll entscheiden | L (Empfehlung angenommen) |
| D127 | 2026-11-20 | Riese gegen Zwerge: roter Warnkreis in Stampfreichweite füllt sich während des Ausholens | Menschen konnten nicht rechtzeitig springen | L (Empfehlung angenommen) |
| D128 | 2026-11-20 | Rückmeldungen: Turbo-Ring unter dem Autoscooter (füllt sich, leuchtet wenn bereit); blinkender roter Ring mit Pfeil über dem Bombenträger, schneller kurz vor der Explosion | Wichtige Zustände waren nicht sichtbar | L (Empfehlung angenommen) |
| D129 | 2026-11-20 | Zerfetzung: Spielzeug-Blaster (Kenney Blaster Kit) unten rechts in der eigenen Ego-Ansicht mit Mündungsblitz | Waffe war unsichtbar, Modelle lagen ungenutzt im Projekt | L (Empfehlung angenommen) |
| D130 | 2026-11-20 | Zerfetzung bei Zeitablauf: Überlebende nach wenigsten erlittenen Treffern, bei Gleichstand nach meisten verteilten Treffern; Computer suchen ohne Sichtkontakt aktiv Gegner. Gleichzeitig Ausgeschiedene teilen sich den Platz (Autoscooter, Wackelwaben) | Spieltest: Untätige gewannen durch Verstecken; Platzvergabe hing von der Platznummer ab | KI (Claude), Bestätigung durch L offen |
| D131 | 2026-11-20 | Spieltest-Werkzeug `--smoke-playtest`: jedes Minispiel mehrfach mit Computern (Stärke 0-2) plus Läufe mit untätigem Platz 1; misst Dauer, Zeitablauf, Siegverteilung nach Platz, Koop-/Solo-Quote | Balance- und Fairnessfehler (Startvorteil, Untätige gewinnen) früh erkennen | KI (Claude) |
| D125 | 2026-11-20 | Minispiele aus dem Park laufen in einer eigenen Szene (Szenenwechsel), danach Rückkehr in den Park neben die Bude | Vorher entstand die Arena mitten in der Parkwelt mit deren Kollisionen (Brunnen im Autoscooter, kein Ausscheiden durch Herunterfallen) | KI (Claude) |
| D132 | 2026-11-25 | P1 Doppelgänger-Gewusel: Die drei Versteckten spielen reines Koop, Schubsen ist für sie abgeschaltet | Ein Schubser wäre sofortige Selbstentlarvung; Fokus auf unauffälliges Verhalten | L (Empfehlung angenommen) |
| D133 | 2026-11-25 | P1 Doppelgänger-Gewusel: Der Wächter steht mit Spielzeug-Blaster auf einem Hochsitz am Rand, schiebt ein Fadenkreuz über die Menge und hat 3 Schüsse; ein Treffer auf einen Parkbesucher ist ein Fehlschuss | Alle beobachten dieselbe Szene; Waffe statt Netz auf Leonardos Wunsch | L |
| D134 | 2026-11-25 | P2 Kronenjagd: startet automatisch, sobald jemand die Krone vom Turm holt und mindestens 2 Menschen im Park sind; 60 s, gezählt wird die Tragezeit, keine Turnierpunkte | Kein Extra-Schritt, reine Wartespielerei | L (Empfehlung angenommen) |
| D135 | 2026-11-25 | P3 Handicap: Stufe (Profi, Normal, Entspannt) wird nur im Beitrittsbildschirm angezeigt und wirkt im Spiel still | Niemand wird im Spiel als „Entspannt“ markiert | L (Empfehlung angenommen) |
| D136 | 2026-11-25 | P1 Doppelgänger-Gewusel: Versteckte finden ihre Figur, indem sie sie per Knopfdruck kurz in ihrer Farbe aufblinken lassen; der Wächter sieht das Blinken auch | Risiko als Spielelement statt Ehrenregel | L |
| D137 | 2026-11-25 | P1 Doppelgänger-Gewusel: 4 gemeinsam erledigte Aufgaben (eine aktive Bude, 2 s Aktion halten) in 90 s; der Wächter gewinnt bei Zeitablauf oder 3 Treffern. Versteckte laufen gleich schnell wie die Besucher (kein Sprint) | Druck, sich zu bewegen; nur Verhalten verrät | L (Empfehlung angenommen) |
| D138 | 2026-11-25 | Randlicht (5.4, D85): Stufe „dezent“ (SOFT, Fresnel-Rand 0,12/0,15/0,25 für Plastik/Glossy/Figur) als Standard, `Look.RIM_DEFAULT`; ca. 30 Draw Calls mehr, auf Handhelds unter 5.9 messen | Figuren heben sich besonders abends ab, ohne zu leuchten | L (Empfehlung angenommen) |
| D139 | 2026-11-25 | Leuchtflächen zentral über `Look.set_glow`/`Look.glow_surface`; Glow und SSAO je Grafikstufe in `Settings.QUALITY_GLOW`/`QUALITY_SSAO`, Stufenwechsel wirkt sofort (`Look.apply_quality`) | Einheitliche Emission, Grafikstufen D69 vollständig | KI (Claude) |
| D140 | 2026-11-25 | Asset-Pipeline (5.3): Kenney-Farbatlanten VRAM-komprimiert mit Mipmaps; Budget je Arena und Hub in `docs/ART_GUIDE.md` Abschnitt 13; kein Git LFS (Repo 8,3 MB, größte Datei 1,5 MB), neu prüfen ab 10 MB je Datei oder 500 MB Pack (schließt Q27) | Repo bleibt klein, LFS brächte nur Einrichtungsaufwand | KI (Claude) |

## Offene Fragen

Beim Klären in die Tabelle oben übernehmen und hier als erledigt markieren.

| ID | Frage | Wann klären | Status |
|---|---|---|---|
| Q01 | Herzstück langfristig: Freizeitpark-Hub oder Brettspiel? | vor Phase 4 | erledigt (D98) |
| Q02 | Welche Spielfigur (Tier, Kartoffel, Roboter, Männchen …) und wie wackelig/physikalisch? | Beginn Prototyp | erledigt (D15, D16) |
| Q03 | Thema und Grafikstil (Low-Poly mit Kenney/Quaternius vorgeschlagen) | Beginn Prototyp | erledigt (D17) |
| Q04 | Tastenbelegung der abstrakten Aktionen | Beginn Prototyp | erledigt (D18) |
| Q05 | Welche 4 Minispiele im Vertical Slice? (Vorschlag: Eisscholle, Ruderboot, Geisterhaus, Staubsauger-Boss) | Beginn Prototyp | erledigt (D30) |
| Q06 | Punktesystem und Turnierlänge | Meilenstein Turnier | erledigt (D31) |
| Q07 | Gewichtung der Teamformate und Aufholmechanik | Meilenstein Turnier | erledigt (D32) |
| Q08 | Fehlende Spieler mit Computergegnern auffüllen? | Meilenstein Kern | erledigt (D19) |
| Q09 | Privates Git-Repository (z. B. GitHub) als Austauschweg zwischen Arbeitsrechner, Spiele-PC/Bazzite und Antigravity? | vor erstem Test auf Bazzite | erledigt (D74) |
| Q10 | Spielerfarben bestätigen (Platzhalter: Blau, Zinnoberrot, Gelb, Blaugrün aus der farbsehschwächen-sicheren Okabe-Ito-Palette) | nach Test M1 | offen |
| Q11 | Platzhalter im Beitrittsbildschirm bestätigen: Titel „PARTYPARK“, Y schaltet Computergegner um, Texte der Hinweiszeile | nach Test M1 | offen |
| Q12 | Bewegungswerte nach dem ersten Controllertest feinjustieren (Tempo 7 m/s, Sprunghöhe ca. 1,7 m, Schubsstärke 12 m/s, Kamera) | nach Test M1 | offen |
| Q13 | Punkte in Teamformaten (Platzhalter): Siegerteam je 3, Verlierer 0, Unentschieden je 1. Passt das, oder sollen z. B. Solo-Sieger im 1 gegen 3 mehr bekommen? | nach erstem Turnier | erledigt (D54) |
| Q14 | Teamfarben der Ringe unter den Figuren (Platzhalter Orange und Lila) und Teamnamen „Team Orange“, „Team Lila“ | nach erstem Turnier | erledigt (D57) |
| Q15 | Balance der vier Minispiele nach dem ersten Spieleabend: Zeitlimits, Seilzahl, Stampfradius, Zugkraft im Tauziehen, Schafverhalten, Wolf. Stand 2026-10-20: Tauziehen und Riese angepasst (D53, D58); Computer gegen Computer endet Riese gegen Zwerge nach 10 bis 35 s, Tauziehen hat 7 bis 14 Kraftakte pro Runde | nach Test M3 | teilweise (D53, D58) |
| Q16 | Versionsplan v0.4 bis v1.0 (ROADMAP) bestätigen oder umsortieren | vor Patch v0.4 | erledigt (D47) |
| Q17 | Welche zwei Spiele aus der Schnellbau-Liste (GAME_DESIGN 9.5) kommen in v0.4? | Beginn Patch v0.4 | erledigt (D48, D49) |
| Q18 | Rache-Modus für Ausgeschiedene grundsätzlich gewünscht? | vor v0.5 | erledigt (D92) |
| Q19 | Joker-Karten (Regel-Modifikatoren) grundsätzlich gewünscht, und wer wählt (Letztplatzierter, Zufall, Abstimmung)? | vor v0.7 | offen |
| Q20 | Veröffentlichungsziel: nur privat, itch.io oder Steam? | vor v1.0 | offen |
| Q21 | Ansager: Brabbelstimme mit Sprechblasen, nur Text oder später echte Sprachaufnahmen? | Beginn Patch v0.4 | erledigt (D50) |
| Q22 | Spieleabend-Feedback 2026-10-20 (kurz angespielt): Autoscooter mit Tastatur schwer steuerbar, Grafik dürftig (beim Riesen keine Seile zu sehen), Tauziehen etwas langweilig. Controller noch nicht getestet | WP 1 v0.4 | teilweise (D52, D53; Autoscooter wartet auf Controllertest D51, Grafik in v0.9) |
| Q23 | Ansager-Optik bestätigen (Platzhalter: graues Gesicht mit Brille, D68) | nach Test v0.4 | offen |
| Q24 | Zerfetzung: Arena (Platzhalter Kisten und Säulen), Waffenname „Krawumm-Blaster“, Überhitzung und Zielhilfe nach dem ersten Test bestätigen | nach Test v0.4 | offen |
| Q25 | (erledigt: D85, D86) Stilrichtung für v0.5: Licht und Tageszeit, Farbpalette, Materialien (matt, Spielzeug-Plastik, Toon), Umrisslinien ja/nein; Entscheidung anhand gerenderter Stilproben. Stand 2026-10-21: Auch die Stimmung (sonniger Nachmittag, goldene Stunde, Abendrummel) wählt Leonardo anhand von Bildern | WP 2 v0.5 | erledigt (D85, D86) |
| Q26 | Welche Asset-Pakete aus `docs/ASSET_QUELLEN.md` werden genutzt, welche Themen bekommen die sieben Arenen? | Beginn v0.5 | teilweise (Pakete D83; Themen in WP 6) |
| Q27 | Git LFS für große Binärdateien, falls das Asset-Budget überschritten wird | v0.5, bei Bedarf | erledigt (D140: kein LFS) |

