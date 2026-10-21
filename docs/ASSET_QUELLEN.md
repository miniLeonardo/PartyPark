# Partypark: Freie Asset-Quellen

Stand: 2026-10-21 (zweite Recherche). Alle Links und Lizenzen wurden an diesem Tag auf den Herstellerseiten geprüft. Erlaubt sind nach `AGENTS.md` CC0, CC-BY (mit Namensnennung), MIT, OFL (Schriften) und vergleichbar freie Lizenzen. Jede übernommene Datei kommt in `assets/CREDITS.md`. Vor der Übernahme die Lizenzdatei im heruntergeladenen Paket noch einmal prüfen.

## So kommen die Pakete in den Ordner

1. **Automatisch (empfohlen):** Im Projektstamm in PowerShell ausführen:
   ```
   powershell -ExecutionPolicy Bypass -File tools\download_assets.ps1
   ```
   Das lädt alle Pakete mit Direktlink aus der Gruppe „Basis“ nach `assets\_incoming\<name>\` und entpackt sie. Mit `-Alles` zusätzlich die Gruppen „Erweitert“ und „Audio“. Bereits vorhandene Ordner werden übersprungen. Je nach Gruppe einige hundert MB, nur lokal; `assets/_incoming/` ist von Git ausgeschlossen.
2. **Von Hand** (Spalte „Bezug“ = itch.io oder Webseite): Seite öffnen, „Download“ bzw. „Download Now“, bei „Name your own price“ 0 eingeben und „No thanks, just take me to the downloads“ wählen, Zip nach `assets\_incoming\<name>\` entpacken. Ordnernamen wie in der Spalte „Ordner“.
3. Claude (Cowork) kann diese Seiten aus der Cloud nicht erreichen; Antigravity lokal schon, nach Zustimmung.
4. Nur wirklich genutzte Dateien wandern später nach `assets/third_party/<name>/` (mit Lizenzdatei) und ins Repository.

## A. Waffen und Schießspiele

| Paket | Lizenz | Inhalt | Nutzen | Ordner | Bezug |
|---|---|---|---|---|---|
| Kenney Blaster Kit 2.1 | CC0 | 40 Dateien: Spielzeug-Blaster, Zielscheiben, Kisten, Schalldämpfer, Wurfobjekte, Rauch; mit Animation und Varianten | **Erste Wahl** für Zerfetzung und alle weiteren Schießspiele: bunt, comichaft, passt zum Partystil | kenney_blaster-kit | [Direkt-Zip](https://kenney.nl/media/pages/assets/blaster-kit/261d80a716-1753959510/kenney_blaster-kit_2.1.zip) · [Seite](https://kenney.nl/assets/blaster-kit) |
| Quaternius Ultimate Gun Pack | CC0 | 40 bis 50 Low-Poly-Schusswaffen (Pistolen, Gewehre, Schrotflinten, Scharfschützengewehre, Visiere, Schalldämpfer); FBX, OBJ, Blend | Nur falls ein Spiel bewusst „echtere“ Waffen braucht; realistische Vorbilder (AK, M4) vorher mit Leonardo abstimmen, ggf. bunt umfärben | quaternius_guns | [Direkt-Zip (OpenGameArt)](https://opengameart.org/sites/default/files/ultimate_gun_pack_by_quaternius.zip) · [itch.io](https://quaternius.itch.io/50-lowpoly-guns) |
| KayKit Mini-Game Variety Pack | CC0 | über 50 Modelle: Waffen, Ball, Tore, Ringe, Pickups (Herz, Bombe, Stern, Diamant) in 3 Teamfarben | Wurfwaffen, Bombe für Heiße Kartoffel, Pickups | kaykit_minigame | [itch.io](https://kaylousberg.itch.io/kay-kit-mini-game-variety-pack) |
| Peu Game Assets Blasters (Free) | CC0 | Gratisstufe: eine stilisierte Sci-Fi-Pistole mit Skins; volle Version (200+ Blaster) kostet ab 4,95 $ | Optional für eine Sci-Fi-Arena; Kauf nur nach Rücksprache | peu_blasters | [itch.io](https://pedrovilasboas.itch.io/peu-game-assets-blasters) |
| Kenney Impact Sounds | CC0 | 130 Aufprall- und Geräuscheffekte | Optional als Ergänzung zu den selbst erzeugten Schuss- und Trefferklängen | kenney_impact-sounds | [Direkt-Zip](https://kenney.nl/media/pages/assets/impact-sounds/87b4ddecda-1677589768/kenney_impact-sounds.zip) |

Nicht verwenden: „Scifi Weapons Pack“ von bibbers (keine Standardlizenz), kostenpflichtige Hut- oder Waffenpakete ohne klare Lizenz.

## B. Freizeitpark, Kulisse, Arenen (Basis)

| Paket | Lizenz | Inhalt | Nutzen | Ordner | Bezug |
|---|---|---|---|---|---|
| Kenney Coaster Kit | CC0 | 180 Modelle: Achterbahnen, Strecken, Fahrgeschäftsteile | Park-Kulisse, Brett „Parkrundfahrt“ (v0.7), Achterbahn-Spiele | kenney_coaster-kit | [Direkt-Zip](https://kenney.nl/media/pages/assets/coaster-kit/546fdc554f-1731487890/kenney_coaster-kit.zip) |
| Kenney Platformer Kit | CC0 | 150 Modelle inkl. animierter Figuren | Hindernisse, Plattformen, Wackelwaben, Bau-Chaos | kenney_platformer-kit | [Direkt-Zip](https://kenney.nl/media/pages/assets/platformer-kit/1585cf62b4-1775122253/kenney_platformer-kit.zip) |
| Kenney Nature Kit | CC0 | 330 Modelle: Bäume, Felsen, Pflanzen | Parkränder, Schafwiese, Wege | kenney_nature-kit | [Direkt-Zip](https://kenney.nl/media/pages/assets/nature-kit/37ac38a37b-1677698939/kenney_nature-kit.zip) |
| Kenney Mini Characters | CC0 | 25 Dateien, animierte Mini-Figuren | Parkbesucher und Zuschauer am Arenarand (nicht als Spielfigur, D15 bleibt) | kenney_mini-characters | [Direkt-Zip](https://kenney.nl/media/pages/assets/mini-characters/bfc7e272b4-1774770718/kenney_mini-characters.zip) |
| KayKit Platformer Pack (Free) | CC0 | über 120 Modelle in 4 Farben: Böden, Rampen, Absperrungen, Geländer, Fahnen, Tore, Ziellinie, Knöpfe, Pickups | Arenen mit Teamfarben, Ziellinien, Absperrungen | kaykit_platformer | [itch.io](https://kaylousberg.itch.io/kaykit-platformer) |
| KayKit Prototype Bits (Free) | CC0 | über 64 Prototyp-Modelle, Farbverlaufs-Atlas | schnelle Rohbauten neuer Arenen | kaykit_prototype | [itch.io](https://kaylousberg.itch.io/prototype-bits) |
| Quaternius Ultimate Platformer Pack | CC0 | über 100 Modelle: Wolken, Bäume, 3D-Ziffern, Power-ups, Fallen, animierte Figur | Wolken am Himmel, 3D-Countdown-Ziffern | quaternius_platformer | [itch.io](https://quaternius.itch.io/ultimate-platformer-pack) |

## C. Passend zu einzelnen Minispielen

| Paket | Lizenz | Inhalt | Für welches Spiel | Ordner | Bezug |
|---|---|---|---|---|---|
| Kenney Toy Car Kit | CC0 | 100 Spielzeugautos und Streckenteile | Autoscooter, spätere Rennspiele | kenney_toy-car-kit | [Direkt-Zip](https://kenney.nl/media/pages/assets/toy-car-kit/42e19cc426-1736346027/kenney_toy-car-kit.zip) |
| Kenney Food Kit | CC0 | 200 Lebensmittel und Küchenteile | Heiße Kartoffel, Imbissbude, Zuckerwatte-Spiele, Deko an Buden | kenney_food-kit | [Direkt-Zip](https://kenney.nl/media/pages/assets/food-kit/83086fa91c-1719418518/kenney_food-kit.zip) |
| KayKit Restaurant Bits (Free) | CC0 | über 140 Küchen- und Essensmodelle, Zutaten roh, gekocht, geschnitten | Imbissbude (Overcooked-Prinzip) | kaykit_restaurant | [itch.io](https://kaylousberg.itch.io/restaurant-bits) |
| Kenney Graveyard Kit 5.0 | CC0 | 90 Modelle, Halloween-Thema, mit Animation | Geisterhaus, Geisterbahn-Gedächtnis | kenney_graveyard-kit | [Direkt-Zip](https://kenney.nl/media/pages/assets/graveyard-kit/ba8d4b4517-1760691807/kenney_graveyard-kit_5.0.zip) |
| Kenney Castle Kit | CC0 | 75 Burg- und Mittelalterteile | Riese gegen Zwerge, Burgverteidigung | kenney_castle-kit | [Direkt-Zip](https://kenney.nl/media/pages/assets/castle-kit/a395102d20-1711543616/kenney_castle-kit.zip) |
| Kenney Furniture Kit | CC0 | 140 Möbel | Staubsauger-Boss (Wohnzimmer), Umzugschaos | kenney_furniture-kit | [Direkt-Zip](https://kenney.nl/media/pages/assets/furniture-kit/440e0608a4-1677580847/kenney_furniture-kit.zip) |
| Quaternius Farm Animals | CC0 | animierte Tiere: Schaf, Kuh, Schwein, Pferd, Lama, Hund, Mops | Schafe hüten (Schafe, Hund als Vorbild für den Wolf umfärben) | quaternius_farm | [Direkt-Zip (OpenGameArt)](https://opengameart.org/sites/default/files/Farm%20Animals%20by%20%40Quaternius.zip) |
| Kenney Train Kit | CC0 | 100 Züge, Bahnen, Schienen | Gleisbau (Unrailed-Prinzip) | kenney_train-kit | [Direkt-Zip](https://kenney.nl/media/pages/assets/train-kit/cf8521d625-1727040883/kenney_train-kit.zip) |
| Kenney Watercraft Kit | CC0 | 45 Boote und Schiffe | Wildwasserbahn, Ruderboot | kenney_watercraft-kit | [Direkt-Zip](https://kenney.nl/media/pages/assets/watercraft-kit/a335cfed49-1713519620/kenney_watercraft-pack.zip) |
| Kenney Pirate Kit | CC0 | 70 Modelle: Piraten, Schiff, Insel, mit Animation | Wellenbad-Krake, Piraten-Fahrgeschäft | kenney_pirate-kit | [Direkt-Zip](https://kenney.nl/media/pages/assets/pirate-kit/e6d4bb1525-1771333093/kenney_pirate-kit.zip) |
| Kenney Space Kit | CC0 | 150 Modelle: Planeten, Schiffe, Raumteile | Sci-Fi-Arena für Schießspiele, Achterbahn-Reparatur im Weltraum-Stil | kenney_space-kit | [Direkt-Zip](https://kenney.nl/media/pages/assets/space-kit/20874c75ac-1677698978/kenney_space-kit.zip) |
| Kenney Minigolf Kit | CC0 | 125 Minigolf-Teile mit Farbvarianten | neues Minispiel „Minigolf-Chaos“ (Idee), Hindernisse | kenney_minigolf-kit | [Direkt-Zip](https://kenney.nl/media/pages/assets/minigolf-kit/3ae60d8b01-1741163874/kenney_minigolf-kit.zip) |
| Kenney Mini Arena | CC0 | 20 Arena-Teile im römischen Stil, mit Animation | Duell 1 gegen 1, Finale | kenney_mini-arena | [Direkt-Zip](https://kenney.nl/media/pages/assets/mini-arena/88f977a0cb-1709220730/kenney_mini-arena.zip) |
| Kenney Survival Kit | CC0 | 80 Modelle: Kisten, Zelte, Lagerfeuer, mit Animation | Deckung in Schießspielen, Zeltlager-Arena | kenney_survival-kit | [Direkt-Zip](https://kenney.nl/media/pages/assets/survival-kit/4065a8185b-1712149243/kenney_survival-kit.zip) |
| Kenney Fantasy Town Kit 2.0 | CC0 | 160 Häuser, Wände, Marktteile | Buden und Fassaden im Park, Brett-Hintergrund | kenney_fantasy-town-kit | [Direkt-Zip](https://kenney.nl/media/pages/assets/fantasy-town-kit/efe948d309-1754222374/kenney_fantasy-town-kit_2.0.zip) |
| Kenney Holiday Kit | CC0 | 100 Modelle mit Winter-/Weihnachtsthema, mit Animation | Winter-Variante des Parks, Geschenke als Pickups | kenney_holiday-kit | [Direkt-Zip](https://kenney.nl/media/pages/assets/holiday-kit/3976a6496a-1733923970/kenney_holiday-kit.zip) |

## D. Menü, Oberfläche, Ansager

| Paket | Lizenz | Inhalt | Nutzen | Ordner | Bezug |
|---|---|---|---|---|---|
| Kenney Input Prompts 1.5 | CC0 | über 1.500 Tastensymbole: Xbox, PlayStation, Switch, Steam Deck, Tastatur, generisch | Tastensymbole in `InputHints`, Regelbildschirm, Beitritt | kenney_input-prompts | [Direkt-Zip](https://kenney.nl/media/pages/assets/input-prompts/8de120163f-1783763952/kenney_input-prompts_1.5.zip) |
| Kenney UI Pack | CC0 | 430 Knöpfe, Panels, Schieberegler | Menü-Theme, Optionen | kenney_ui-pack | [Direkt-Zip](https://kenney.nl/media/pages/assets/ui-pack/f651646eab-1718203990/kenney_ui-pack.zip) |
| Kenney Game Icons | CC0 | 105 Symbole (Gamepad, Joystick, Oberfläche) | Menüsymbole, Optionen | kenney_game-icons | [Direkt-Zip](https://kenney.nl/media/pages/assets/game-icons/1ebf9c14af-1677661579/kenney_game-icons.zip) |
| Kenney Emotes Pack | CC0 | 480 Emotes, Sprechblasen, Symbole | Ansager-Sprechblase, Ausdrücke über den Figuren („!“, „?“, Herzen) | kenney_emotes-pack | [Direkt-Zip](https://kenney.nl/media/pages/assets/emotes-pack/d00a3dcb06-1677578798/kenney_emotes-pack.zip) |
| Kenney Pattern Pack | CC0 | 80 nahtlose Muster 256×256 | Menühintergründe, Bodenmuster, Banner | kenney_pattern-pack | [Direkt-Zip](https://kenney.nl/media/pages/assets/pattern-pack/e787377a73-1721940715/kenney_pattern-pack.zip) |
| Kenney Particle Pack | CC0 | 80 Partikel- und Effektbilder 512×512 | Partikeltexturen für Staub, Funken, Rauch, Sterne | kenney_particle-pack | [Direkt-Zip](https://kenney.nl/media/pages/assets/particle-pack/f8fe0f8cb8-1677578741/kenney_particle-pack.zip) |
| Fredoka | SIL OFL 1.1 | runde, freundliche Schrift, mehrere Stärken | Haupt-Spielschrift (Vorschlag) | font_fredoka | [Google Fonts](https://fonts.google.com/specimen/Fredoka) („Get font“ → „Download all“) |
| Lilita One | SIL OFL 1.1 | kräftige Titelschrift | Titel, große Ansagen (Vorschlag) | font_lilita-one | [Google Fonts](https://fonts.google.com/specimen/Lilita+One) |
| Kenney Fonts | CC0 | 11 Pixelschriften | nur falls Retro-Akzente gewünscht, passt sonst nicht zum Stil | kenney_fonts | [Direkt-Zip](https://kenney.nl/media/pages/assets/kenney-fonts/8d5435c213-1677661710/kenney_kenney-fonts.zip) |

Bei OFL-Schriften die Datei `OFL.txt` immer mit ins Projekt legen.

## E. Texturen und Himmel

| Paket | Lizenz | Inhalt | Nutzen | Ordner | Bezug |
|---|---|---|---|---|---|
| Kenney Prototype Textures | CC0 | 75 Raster-Texturen | Rohbau und Maßstab beim Arenenbau | kenney_prototype-textures | [Direkt-Zip](https://kenney.nl/media/pages/assets/prototype-textures/a88c69fa18-1677578307/kenney_prototype-textures.zip) |
| Poly Haven „Kloofendal 48d Partly Cloudy (Pure Sky)“ | CC0 | Himmels-HDRI ohne Boden | Himmel und Umgebungslicht für sonnigen Nachmittag | hdri_kloofendal | [Seite](https://polyhaven.com/a/kloofendal_48d_partly_cloudy_puresky) (Auflösung 2K, Format HDR wählen) |
| ambientCG Grass004 | CC0 | Gras-Material 1K | Wiesen, Ränder (stilisiert nachfärben) | ambientcg_grass004 | [Direkt-Zip 1K](https://ambientcg.com/get?file=Grass004_1K-JPG.zip) |
| ambientCG weitere | CC0 | über 2.000 Materialien | Holzplanken, Pflaster, Stoff, Metall; Direktlink-Schema `https://ambientcg.com/get?file=<ID>_1K-JPG.zip` | ambientcg_<id> | [Suche Planken](https://ambientcg.com/list?q=planks) · [Pflaster](https://ambientcg.com/list?q=paving) · [Stoff](https://ambientcg.com/list?q=fabric) · [Metall](https://ambientcg.com/list?q=metal) |

Texturen höchstens 1K verwenden (Leistungsbudget Radeon 780M). Fotorealistische Texturen nur dezent und nachgefärbt einsetzen, der Stil bleibt Low-Poly.

## F. Audio (optional, eigene Klänge haben Vorrang, D59)

| Paket | Lizenz | Inhalt | Nutzen | Ordner | Bezug |
|---|---|---|---|---|---|
| Kenney Music Jingles | CC0 | 85 kurze Musik-Jingles | Sieg, Niederlage, Rundenstart, Turnierende | kenney_music-jingles | [Direkt-Zip](https://kenney.nl/media/pages/assets/music-jingles/f37e530b9e-1677590399/kenney_music-jingles.zip) |
| Kenney Interface Sounds | CC0 | 100 Oberflächenklänge | Vergleich oder Ergänzung zu den eigenen Menüklängen | kenney_interface-sounds | [Direkt-Zip](https://kenney.nl/media/pages/assets/interface-sounds/fa43c1dd4d-1677589452/kenney_interface-sounds.zip) |
| Kenney Impact Sounds | CC0 | 130 Aufprallklänge | siehe Abschnitt A | kenney_impact-sounds | siehe A |

## G. Selbst bauen

Für Hüte und Zubehör wurde kein freies Paket mit klarer CC0-Lizenz gefunden. Vorschlag: einfache Hüte selbst bauen (Partyhütchen, Zylinder, Krone, Propellermütze, Schirmmütze, Kochmütze) als prozedurale Meshes aus Grundformen, passend zur Knubbelfigur.

Weiter gilt:

1. Modelle prozedural in Godot (`SurfaceTool`, `ArrayMesh`, CSG, danach als Mesh-Ressource gespeichert) in `assets/models/own/`.
2. Texturen prozedural (`NoiseTexture2D`, `GradientTexture2D`) oder per Skript erzeugte PNGs in `assets/textures/own/`.
3. Shader für Wasser, Toon-Licht, Umrisse, Lichterketten in `core/look/shaders/`.

## Nicht verwenden

Quellen mit „nur nicht kommerziell“ (z. B. FreePBR ohne Kauf), Assets ohne klare Lizenz, Pakete mit Weitergabeverbot ohne Standardlizenz, KI-generierte Assets unklarer Herkunft, alles mit fremden Figuren, Marken oder Logos.

## Budget

Repository-Assets insgesamt möglichst unter 150 MB, einzelne Dateien unter 50 MB. Wird es mehr, Git LFS einrichten (Q27). In `assets/_incoming/` darf beliebig viel liegen, das wird nicht versioniert.
