# Anleitung: privates GitHub-Repository für Partypark (Q09, D74)

Ziel: Ein privates Repository auf GitHub ist der Austauschweg zwischen Arbeitsrechner (`ulb-pc10039`), Spiele-PC/Bazzite und Antigravity. Bei jedem Hochladen prüft GitHub automatisch alle Tests (`.github/workflows/tests.yml`, Vorlage in `tools/ci/tests.yml`).

Vorab: Klär bitte kurz, ob privater Quellcode vom Arbeitsrechner auf GitHub hochgeladen werden darf (Richtlinien der ULB/ZIM). Das Projekt ist privat und enthält keine Dienstdaten, trotzdem ist es ein Arbeitsrechner.

## 1. Einmalig: Repository anlegen

1. Auf https://github.com anmelden (oder kostenlos registrieren), am besten mit Zwei-Faktor-Anmeldung.
2. Oben rechts „+“ → „New repository“. Name `partypark`, Sichtbarkeit **Private**, **kein** README, keine .gitignore, keine Lizenz (das Projekt hat schon alles). „Create repository“.
3. GitHub zeigt eine Adresse wie `https://github.com/<dein-name>/partypark.git`. Kopieren.

## 2. Einmalig: Arbeitsrechner verbinden

Im Ordner `C:\Users\wad32muj\Agentenraum\partypark` (Git Bash, PowerShell oder Antigravity-Terminal). Zuerst die Test-Vorlage an ihren Platz kopieren (Claude darf den Ordner `.github` nicht beschreiben, D79):

```
mkdir .github\workflows
copy tools\ci\tests.yml .github\workflows\tests.yml
```

In Git Bash stattdessen `mkdir -p .github/workflows && cp tools/ci/tests.yml .github/workflows/`. Ändert sich die Vorlage später, denselben Kopierbefehl wiederholen.

```
git status
git add -A
git commit -m "v0.4: Stand vor dem ersten Hochladen"
git branch -M main
git remote add origin https://github.com/<dein-name>/partypark.git
git push -u origin main
```

Beim ersten `git push` öffnet sich das Anmeldefenster des „Git Credential Manager“ (bei Git für Windows dabei). Im Browser anmelden, fertig. Ohne dieses Fenster: auf GitHub unter Settings → Developer settings → Personal access tokens → „Fine-grained token“ mit Zugriff nur auf `partypark` (Contents: Read and write) erstellen und als Passwort eingeben.

## 3. Automatische Tests ansehen

1. Auf GitHub im Repository den Reiter **Actions** öffnen. Nach jedem Push läuft „Tests“ (ca. 3 bis 6 Minuten).
2. Grüner Haken = alle Tests bestanden. Rotes Kreuz = Lauf anklicken, der fehlgeschlagene Schritt zeigt die Meldung. Diese Meldung kannst du direkt an Claude oder Antigravity geben.
3. Unter Settings → Notifications lässt sich einstellen, dass GitHub bei Fehlschlägen eine E-Mail schickt.

## 4. Spiele-PC mit Bazzite

```
git clone https://github.com/<dein-name>/partypark.git ~/partypark
```

Später aktualisieren mit `cd ~/partypark && git pull`. Godot 4.7.x für Linux holen (Flatpak „Godot Engine“ oder die Datei von godotengine.org) und `~/partypark/project.godot` öffnen. Testanleitung für Bazzite: `docs/EXPORT_UND_BAZZITE.md`.

## 5. Antigravity oder andere IDE

Ordner öffnen bzw. „Clone Repository“ mit der Adresse oben. `AGENTS.md` wird automatisch gelesen. Vor der Arbeit `git pull`, danach `git add -A`, `git commit -m "…"`, `git push`.

## 6. Arbeitsweise mit Claude (Cowork)

Claude arbeitet weiter über den verbundenen Ordner auf dem Arbeitsrechner und schlägt dir Commit-Nachrichten vor. Du committest und pushst; GitHub prüft automatisch. Arbeitest du zwischendurch auf einem anderen PC, vorher auf dem Arbeitsrechner `git pull`, damit Claude den aktuellen Stand sieht.

## 7. Was nicht ins Repository gehört

Regelt `.gitignore`: der Cache `.godot/`, Exporte in `builds/`, Godot-Programmdateien (`Godot_v*.exe`) und der Ordner `Claude outputs/`.
