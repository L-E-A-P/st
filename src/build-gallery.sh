#!/usr/bin/env bash
# build-gallery.sh — converte una cartella di _grezzo/img in una galleria pubblicata.
#
# Uso:
#   src/build-gallery.sh <folder_name> <YYYY-MM-DD> <slug> "<Titolo>"
#
# Esempio:
#   src/build-gallery.sh 2015-04-09-capolona 2015-04-09 capolona "Capolona"
#
# Effetti:
#   - converte HEIC→JPG, copia JPG, normalizza in lowercase
#   - resize a max 1600px, quality 85
#   - scrive docs/assets/img/eventi/<YYYY-MM-DD-slug>/
#   - scrive docs/_posts/<YYYY-MM-DD>-<slug>.md
#
# Da lanciare dalla root del repo.

set -euo pipefail

FOLDER="${1:?folder name in _grezzo/img/}"
DATE="${2:?date YYYY-MM-DD}"
SLUG="${3:?slug kebab-case}"
TITLE="${4:?title in quotes}"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$REPO_ROOT/_grezzo/img/$FOLDER"
EVENT_KEY="$DATE-$SLUG"
DST="$REPO_ROOT/docs/assets/img/eventi/$EVENT_KEY"
POST="$REPO_ROOT/docs/_posts/$DATE-$SLUG.md"

if [ ! -d "$SRC" ]; then
  echo "ERRORE: cartella non trovata: $SRC" >&2
  exit 1
fi

mkdir -p "$DST"

shopt -s nullglob nocaseglob 2>/dev/null || true

# HEIC → JPG
for f in "$SRC"/*.heic; do
  base=$(basename "$f"); base="${base%.*}"
  out="$DST/$(echo "$base" | tr '[:upper:]' '[:lower:]').jpg"
  sips -s format jpeg "$f" --out "$out" >/dev/null
done

# JPG/JPEG/PNG → copia con nome lowercase, normalizza .jpeg → .jpg
for f in "$SRC"/*.jpg "$SRC"/*.jpeg "$SRC"/*.png; do
  [ -e "$f" ] || continue
  base=$(basename "$f")
  lname=$(echo "$base" | tr '[:upper:]' '[:lower:]' | sed 's/\.jpeg$/.jpg/')
  cp "$f" "$DST/$lname"
done

# Resize tutto a max 1600px lato lungo, quality 85
if compgen -G "$DST"/*.jpg >/dev/null || compgen -G "$DST"/*.png >/dev/null; then
  magick mogrify -resize "1600x1600>" -quality 85 "$DST"/*.{jpg,png} 2>/dev/null || true
fi

# Post markdown (non sovrascrive se esiste)
if [ -e "$POST" ]; then
  echo "Post già esistente, non sovrascrivo: $POST"
else
  cat > "$POST" <<EOF
---
title: "$TITLE"
date: $DATE
categories: [gallery]
gallery_path: /assets/img/eventi/$EVENT_KEY/
---

{% include gallery.html path=page.gallery_path %}
EOF
  echo "Scritto: $POST"
fi

echo "OK: $EVENT_KEY → $(ls "$DST" | wc -l | tr -d ' ') file"
