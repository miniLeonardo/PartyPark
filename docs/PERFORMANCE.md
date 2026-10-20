# Partypark: Leistungsmessungen

Ziel (ROADMAP Leitplanke 3): 60 fps mit 4 Spielern auf einer integrierten Radeon 780M, in jedem Minispiel. Gemessen wird mit dem Messmodus aus WP 4.5.

## So wird gemessen

1. Spiel im Editor oder exportiert starten mit den Zusatzargumenten `-- --bench`. Im Editor: „Projekt → Projekteinstellungen“ („Erweiterte Einstellungen“ an) → Editor → Ausführen → „Hauptlauf-Argumente“ auf `-- --bench` setzen und F5, danach wieder leeren. Exportiert: `Partypark.exe -- --bench` (Windows) bzw. `./Partypark.x86_64 -- --bench` (Linux).
2. Optional: `--quality=0` (Niedrig), `--quality=1` (Mittel), `--quality=2` (Hoch), `--bench-seconds=20`.
3. Jedes Minispiel läuft 20 s mit vier Computergegnern (plus 2 s Einschwingzeit), VSync ist aus. Danach beendet sich das Spiel.
4. Ergebnis steht in `bench.txt` im Benutzerordner des Spiels: Windows `%APPDATA%\Godot\app_userdata\Partypark\bench.txt`, Linux `~/.local/share/godot/app_userdata/Partypark/bench.txt`. Die Tabelle daraus unten einfügen.
5. Während des Spiels zeigt F3 (oder Optionen → Leistungsanzeige) fps, Frametime, 1-%-Tiefstwert, Draw Calls, Objekte und lebende Partikel.

## Grafikstufen (D69)

| Stufe | 3D-Auflösung | Hochskalierung | Schatten | MSAA |
|---|---|---|---|---|
| Niedrig | 70 % | FSR | aus | aus |
| Mittel (Standard) | 85 % | FSR | hart, Atlas 2048 | aus |
| Hoch | 100 % | keine | weich, Atlas 4096 | 2x |

## Ergebnisse

Noch keine Messung auf dem Zielrechner. Die Cloud-Umgebung hat keine echte Grafikkarte; dort wird nur geprüft, dass der Messmodus durchläuft.

| Datum | Rechner / Grafik | Stufe | Minispiel | Durchschnitt fps | 1 % tief fps | Draw Calls max | Notiz |
|---|---|---|---|---|---|---|---|
| | | | | | | | |
