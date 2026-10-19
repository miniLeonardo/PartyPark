#!/usr/bin/env bash
# Packt das komplette Repo (inkl. .git) als Sicherungs-ZIP nach builds/
# und listet Dateien, die seit dem Tag sync/folder (letzter Abgleich mit dem Projektordner) geändert wurden.
# Nutzung: bash tools/pack_snapshot.sh   (aus dem Projektstamm)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NAME="$(basename "$ROOT")"
OUT="$ROOT/builds"
mkdir -p "$OUT"
rm -f "$OUT/$NAME.zip"

cd "$ROOT/.."
zip -qr "$OUT/$NAME.zip" "$NAME" \
  -x "$NAME/.godot/*" "$NAME/builds/*.zip"

cd "$ROOT"
echo "ZIP: $OUT/$NAME.zip ($(du -h "$OUT/$NAME.zip" | cut -f1))"
echo

if git rev-parse -q --verify refs/tags/sync/folder >/dev/null; then
  BASE="sync/folder"
  echo "Geänderte Dateien seit $BASE:"
  git diff --name-status "$BASE" HEAD
else
  echo "Noch kein Abgleich-Tag vorhanden. Alle versionierten Dateien:"
  git ls-files
fi
echo
echo "Binärdateien im Repo:"
git ls-files | while read -r f; do
  if [ -f "$f" ] && grep -qP '\x00' "$f" 2>/dev/null; then echo "  $f"; fi
done
