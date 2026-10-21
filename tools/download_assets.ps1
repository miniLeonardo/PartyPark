# Lädt freie CC0-Asset-Pakete mit Direktlink nach assets\_incoming\<name>\ und entpackt sie.
# Quellen, Lizenzen und Zweck: docs\ASSET_QUELLEN.md
#
# Nutzung (im Projektstamm):
#   powershell -ExecutionPolicy Bypass -File tools\download_assets.ps1          # Gruppe "Basis"
#   powershell -ExecutionPolicy Bypass -File tools\download_assets.ps1 -Alles   # Basis, Erweitert und Audio
#   powershell -ExecutionPolicy Bypass -File tools\download_assets.ps1 -Nur kenney_blaster-kit,kenney_toy-car-kit
#
# Vorhandene Zielordner werden übersprungen. assets\_incoming\ ist per .gitignore ausgeschlossen.
# Pakete von itch.io und Google Fonts haben keinen Direktlink und müssen von Hand geladen werden (siehe docs\ASSET_QUELLEN.md).

param(
    [switch]$Alles,
    [string[]]$Nur
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$root = Split-Path -Parent $PSScriptRoot
$incoming = Join-Path $root 'assets\_incoming'
New-Item -ItemType Directory -Force -Path $incoming | Out-Null

$pakete = @(
    # Gruppe Basis: wird für v0.5 gebraucht
    @{ Name = 'kenney_coaster-kit';        Gruppe = 'Basis';     Url = 'https://kenney.nl/media/pages/assets/coaster-kit/546fdc554f-1731487890/kenney_coaster-kit.zip' }
    @{ Name = 'kenney_blaster-kit';        Gruppe = 'Basis';     Url = 'https://kenney.nl/media/pages/assets/blaster-kit/261d80a716-1753959510/kenney_blaster-kit_2.1.zip' }
    @{ Name = 'kenney_platformer-kit';     Gruppe = 'Basis';     Url = 'https://kenney.nl/media/pages/assets/platformer-kit/1585cf62b4-1775122253/kenney_platformer-kit.zip' }
    @{ Name = 'kenney_nature-kit';         Gruppe = 'Basis';     Url = 'https://kenney.nl/media/pages/assets/nature-kit/37ac38a37b-1677698939/kenney_nature-kit.zip' }
    @{ Name = 'kenney_mini-characters';    Gruppe = 'Basis';     Url = 'https://kenney.nl/media/pages/assets/mini-characters/bfc7e272b4-1774770718/kenney_mini-characters.zip' }
    @{ Name = 'kenney_toy-car-kit';        Gruppe = 'Basis';     Url = 'https://kenney.nl/media/pages/assets/toy-car-kit/42e19cc426-1736346027/kenney_toy-car-kit.zip' }
    @{ Name = 'kenney_food-kit';           Gruppe = 'Basis';     Url = 'https://kenney.nl/media/pages/assets/food-kit/83086fa91c-1719418518/kenney_food-kit.zip' }
    @{ Name = 'kenney_castle-kit';         Gruppe = 'Basis';     Url = 'https://kenney.nl/media/pages/assets/castle-kit/a395102d20-1711543616/kenney_castle-kit.zip' }
    @{ Name = 'kenney_survival-kit';       Gruppe = 'Basis';     Url = 'https://kenney.nl/media/pages/assets/survival-kit/4065a8185b-1712149243/kenney_survival-kit.zip' }
    @{ Name = 'quaternius_farm';           Gruppe = 'Basis';     Url = 'https://opengameart.org/sites/default/files/Farm%20Animals%20by%20%40Quaternius.zip' }
    @{ Name = 'kenney_input-prompts';      Gruppe = 'Basis';     Url = 'https://kenney.nl/media/pages/assets/input-prompts/8de120163f-1783763952/kenney_input-prompts_1.5.zip' }
    @{ Name = 'kenney_ui-pack';            Gruppe = 'Basis';     Url = 'https://kenney.nl/media/pages/assets/ui-pack/f651646eab-1718203990/kenney_ui-pack.zip' }
    @{ Name = 'kenney_game-icons';         Gruppe = 'Basis';     Url = 'https://kenney.nl/media/pages/assets/game-icons/1ebf9c14af-1677661579/kenney_game-icons.zip' }
    @{ Name = 'kenney_emotes-pack';        Gruppe = 'Basis';     Url = 'https://kenney.nl/media/pages/assets/emotes-pack/d00a3dcb06-1677578798/kenney_emotes-pack.zip' }
    @{ Name = 'kenney_pattern-pack';       Gruppe = 'Basis';     Url = 'https://kenney.nl/media/pages/assets/pattern-pack/e787377a73-1721940715/kenney_pattern-pack.zip' }
    @{ Name = 'kenney_particle-pack';      Gruppe = 'Basis';     Url = 'https://kenney.nl/media/pages/assets/particle-pack/f8fe0f8cb8-1677578741/kenney_particle-pack.zip' }
    @{ Name = 'kenney_prototype-textures'; Gruppe = 'Basis';     Url = 'https://kenney.nl/media/pages/assets/prototype-textures/a88c69fa18-1677578307/kenney_prototype-textures.zip' }
    @{ Name = 'ambientcg_grass004';        Gruppe = 'Basis';     Url = 'https://ambientcg.com/get?file=Grass004_1K-JPG.zip' }

    # Gruppe Erweitert: für spätere Minispiele und Modi
    @{ Name = 'kenney_graveyard-kit';      Gruppe = 'Erweitert'; Url = 'https://kenney.nl/media/pages/assets/graveyard-kit/ba8d4b4517-1760691807/kenney_graveyard-kit_5.0.zip' }
    @{ Name = 'kenney_furniture-kit';      Gruppe = 'Erweitert'; Url = 'https://kenney.nl/media/pages/assets/furniture-kit/440e0608a4-1677580847/kenney_furniture-kit.zip' }
    @{ Name = 'kenney_train-kit';          Gruppe = 'Erweitert'; Url = 'https://kenney.nl/media/pages/assets/train-kit/cf8521d625-1727040883/kenney_train-kit.zip' }
    @{ Name = 'kenney_watercraft-kit';     Gruppe = 'Erweitert'; Url = 'https://kenney.nl/media/pages/assets/watercraft-kit/a335cfed49-1713519620/kenney_watercraft-pack.zip' }
    @{ Name = 'kenney_pirate-kit';         Gruppe = 'Erweitert'; Url = 'https://kenney.nl/media/pages/assets/pirate-kit/e6d4bb1525-1771333093/kenney_pirate-kit.zip' }
    @{ Name = 'kenney_space-kit';          Gruppe = 'Erweitert'; Url = 'https://kenney.nl/media/pages/assets/space-kit/20874c75ac-1677698978/kenney_space-kit.zip' }
    @{ Name = 'kenney_minigolf-kit';       Gruppe = 'Erweitert'; Url = 'https://kenney.nl/media/pages/assets/minigolf-kit/3ae60d8b01-1741163874/kenney_minigolf-kit.zip' }
    @{ Name = 'kenney_mini-arena';         Gruppe = 'Erweitert'; Url = 'https://kenney.nl/media/pages/assets/mini-arena/88f977a0cb-1709220730/kenney_mini-arena.zip' }
    @{ Name = 'kenney_fantasy-town-kit';   Gruppe = 'Erweitert'; Url = 'https://kenney.nl/media/pages/assets/fantasy-town-kit/efe948d309-1754222374/kenney_fantasy-town-kit_2.0.zip' }
    @{ Name = 'kenney_holiday-kit';        Gruppe = 'Erweitert'; Url = 'https://kenney.nl/media/pages/assets/holiday-kit/3976a6496a-1733923970/kenney_holiday-kit.zip' }
    @{ Name = 'quaternius_guns';           Gruppe = 'Erweitert'; Url = 'https://opengameart.org/sites/default/files/ultimate_gun_pack_by_quaternius.zip' }
    @{ Name = 'kenney_fonts';              Gruppe = 'Erweitert'; Url = 'https://kenney.nl/media/pages/assets/kenney-fonts/8d5435c213-1677661710/kenney_kenney-fonts.zip' }

    # Gruppe Audio: optional, eigene Klänge haben Vorrang (D59)
    @{ Name = 'kenney_music-jingles';      Gruppe = 'Audio';     Url = 'https://kenney.nl/media/pages/assets/music-jingles/f37e530b9e-1677590399/kenney_music-jingles.zip' }
    @{ Name = 'kenney_interface-sounds';   Gruppe = 'Audio';     Url = 'https://kenney.nl/media/pages/assets/interface-sounds/fa43c1dd4d-1677589452/kenney_interface-sounds.zip' }
    @{ Name = 'kenney_impact-sounds';      Gruppe = 'Audio';     Url = 'https://kenney.nl/media/pages/assets/impact-sounds/87b4ddecda-1677589768/kenney_impact-sounds.zip' }
)

if ($Nur) {
    $auswahl = $pakete | Where-Object { $Nur -contains $_.Name }
} elseif ($Alles) {
    $auswahl = $pakete
} else {
    $auswahl = $pakete | Where-Object { $_.Gruppe -eq 'Basis' }
}

$ok = 0; $uebersprungen = 0; $fehler = @()
foreach ($p in $auswahl) {
    $ziel = Join-Path $incoming $p.Name
    if (Test-Path $ziel) {
        Write-Host ("[--] {0} ist schon da, übersprungen" -f $p.Name)
        $uebersprungen++
        continue
    }
    $zip = Join-Path $env:TEMP ($p.Name + '.zip')
    try {
        Write-Host ("[..] {0} wird geladen" -f $p.Name)
        Invoke-WebRequest -Uri $p.Url -OutFile $zip -UseBasicParsing -UserAgent 'Mozilla/5.0 (Partypark asset download)'
        Expand-Archive -Path $zip -DestinationPath $ziel -Force
        Remove-Item $zip -Force
        $groesse = (Get-ChildItem $ziel -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1MB
        Write-Host ("[ok] {0} ({1:N1} MB)" -f $p.Name, $groesse)
        $ok++
    } catch {
        Write-Warning ("{0} fehlgeschlagen: {1}" -f $p.Name, $_.Exception.Message)
        $fehler += $p.Name
        if (Test-Path $zip) { Remove-Item $zip -Force }
        if (Test-Path $ziel) { Remove-Item $ziel -Recurse -Force }
    }
}

Write-Host ''
Write-Host ("Fertig: {0} geladen, {1} übersprungen, {2} fehlgeschlagen." -f $ok, $uebersprungen, $fehler.Count)
if ($fehler.Count -gt 0) {
    Write-Host ('Fehlgeschlagen: ' + ($fehler -join ', '))
    Write-Host 'Hinweis: Kenney ändert gelegentlich die Download-Adressen. Dann die Seite aus docs\ASSET_QUELLEN.md öffnen und von Hand laden.'
}
Write-Host 'Von Hand noch laden (itch.io, Google Fonts, Poly Haven): siehe docs\ASSET_QUELLEN.md, Spalte "Bezug".'
