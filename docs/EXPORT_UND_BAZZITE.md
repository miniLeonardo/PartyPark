# Export und Test auf Bazzite (WP 4.9)

Die Exportprofile stehen in `export_presets.cfg`: „Windows Desktop“ → `builds/windows/Partypark.exe`, „Linux“ → `builds/linux/Partypark.x86_64`, jeweils eine einzige Datei mit eingebettetem Spielinhalt. `builds/` wird nicht versioniert. In der Cloud mit Godot 4.7.2 geprüft: Beide Exporte laufen durch, der Linux-Export startet und spielt den Messmodus mit allen sieben Minispielen durch.

## 1. Export-Vorlagen installieren (einmalig je Rechner)

1. Godot-Editor 4.7.2 öffnen, Projekt laden.
2. Menü „Editor → Export-Vorlagen verwalten…“ → „Herunterladen und installieren“ (ca. 1,3 GB, offizieller Godot-Server). Die Version muss exakt zur Editor-Version passen.
3. Ohne Internet am Rechner: die Datei `Godot_v4.7.2-stable_export_templates.tpz` von godotengine.org woanders laden und im selben Fenster „Aus Datei installieren“.

## 2. Exportieren

Im Editor: „Projekt → Exportieren…“ → Profil wählen → „Projekt exportieren…“, Haken bei „Mit Debug exportieren“ **entfernen** für den normalen Spieleabend. Debug-Exporte enthalten die Tastatur-Debugspieler und die Smoke-Tests (D22).

Kommandozeile (Projektordner):

```
godot --headless --path . --export-release "Windows Desktop" builds/windows/Partypark.exe
godot --headless --path . --export-release "Linux" builds/linux/Partypark.x86_64
```

Unter Windows heißt `godot` z. B. `Godot_v4.7.2-stable_win64_console.exe`.

## 3. Auf Bazzite bringen

Variante A (empfohlen, D74): Auf dem Bazzite-PC das Repository klonen (`docs/GITHUB_ANLEITUNG.md`), Godot 4.7.2 für Linux holen, Vorlagen installieren und dort exportieren.

Variante B: `builds/linux/Partypark.x86_64` vom Arbeitsrechner per USB-Stick kopieren, z. B. nach `~/Spiele/Partypark/`, dann im Terminal `chmod +x ~/Spiele/Partypark/Partypark.x86_64`.

## 4. In Steam als Nicht-Steam-Spiel eintragen

1. Bazzite in den Desktop-Modus schalten.
2. Steam öffnen → „Spiele → Ein Nicht-Steam-Spiel zu meiner Bibliothek hinzufügen…“ → „Durchsuchen…“ → `Partypark.x86_64` wählen → hinzufügen.
3. Rechtsklick auf Partypark → Eigenschaften → Kompatibilität: **kein** Proton erzwingen (es ist ein natives Linux-Spiel).
4. Optional Startoptionen für den Messmodus: `-- --bench` (danach wieder entfernen).
5. Zurück in den Spielmodus (Gamescope) und starten.

## 5. Testanleitung Bazzite

Rückmeldung bitte als „B-Nummer: ok/Problem“.

1. **B1 Start:** Spiel startet im Spielmodus im Vollbild, Titel erscheint, Ton ist zu hören.
2. **B2 Controller:** Alle vorhandenen Controller (bis 4) treten im Beitritt mit A bei. Jeder Controller belegt **genau einen** Platz.
3. **B3 Doppelgänger-Schutz (D23):** Steam Input meldet Controller oft doppelt (echtes und virtuelles Pad). Mit einem Controller einmal A drücken: Es darf nur ein Platz belegt werden. Danach in Steam unter Eigenschaften → Controller „Steam Input deaktivieren“ wählen und B2 und B3 wiederholen. Notieren, welche Einstellung besser funktioniert.
4. **B4 Tastenhinweise:** Die Hinweise zeigen die richtigen Tasten (Xbox A/B/X/Y oder PlayStation-Symbole je nach Controller).
5. **B5 Vibration:** Bei Schubsern, Treffern und Explosionen vibriert der Controller; „Optionen → Vibration aus“ stellt sie ab.
6. **B6 Trennen:** Einen Controller während eines Minispiels ausschalten: Spiel pausiert mit Hinweis; wieder einschalten setzt fort.
7. **B7 Bildrate:** F3 gibt es im Spielmodus nicht, deshalb „Optionen → Leistungsanzeige an“. In jedem Minispiel fps notieren, besonders Zerfetzung (Splitscreen) und Wackelwaben. Ziel 60 fps.
8. **B8 Messmodus:** Mit Startoption `-- --bench` einmal durchlaufen lassen, dann `~/.local/share/godot/app_userdata/Partypark/bench.txt` öffnen und die Tabelle in `docs/PERFORMANCE.md` eintragen (auch mit `--quality=0` und `--quality=2`).
9. **B9 Steam Deck oder Handheld (falls vorhanden):** wie B1 bis B8, dazu: Ist Text auf dem kleinen Bildschirm lesbar?

## 6. Bekannte Grenzen

1. Kein Icon und keine Versionsinfo in der Windows-Datei (`application/modify_resources` ist aus, weil dafür rcedit nötig wäre).
2. Windows warnt beim ersten Start eventuell vor einer unbekannten App (nicht signiert): „Weitere Informationen → Trotzdem ausführen“.
3. Exporte enthalten keine Tests und Werkzeuge; den Messmodus gibt es trotzdem.
