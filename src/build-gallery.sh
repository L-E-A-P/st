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
#   docs/assets/img/eventi/<YYYY-MM-DD-slug>/
#     ├── full/   immagini 1600px lato lungo, q85
#     └── thumb/  immagini 400px lato lungo, q80
#   docs/_posts/<YYYY-MM-DD>-<slug>.md  (non sovrascrive se esiste)
#
# Idempotente: rilanciato, non ricomprime ciò che già esiste in full/.
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
FULL="$DST/full"
THUMB="$DST/thumb"
POST="$REPO_ROOT/docs/_posts/$DATE-$SLUG.md"

if [ ! -d "$SRC" ]; then
  echo "ERRORE: cartella non trovata: $SRC" >&2
  exit 1
fi

mkdir -p "$FULL" "$THUMB"

shopt -s nullglob nocaseglob 2>/dev/null || true

# 1. Popola full/ da _grezzo: HEIC→JPG con sips, JPG/JPEG/PNG copiati con nome lowercase.
#    Salta se già presente in full/ (idempotenza).
for f in "$SRC"/*.heic; do
  base=$(basename "$f"); base="${base%.*}"
  out="$FULL/$(echo "$base" | tr '[:upper:]' '[:lower:]').jpg"
  [ -e "$out" ] || sips -s format jpeg "$f" --out "$out" >/dev/null
done
for f in "$SRC"/*.jpg "$SRC"/*.jpeg "$SRC"/*.png; do
  [ -e "$f" ] || continue
  base=$(basename "$f")
  lname=$(echo "$base" | tr '[:upper:]' '[:lower:]' | sed 's/\.jpeg$/.jpg/')
  out="$FULL/$lname"
  [ -e "$out" ] || cp "$f" "$out"
done

# 2. Resize full/ a max 1600px, q85 (mogrify in-place).
for f in "$FULL"/*.jpg "$FULL"/*.png; do
  [ -e "$f" ] || continue
  magick mogrify -resize "1600x1600>" -quality 85 "$f"
done

# 3. Genera thumb/ a max 400px, q80, da full/. Solo file mancanti.
for f in "$FULL"/*.jpg "$FULL"/*.png; do
  [ -e "$f" ] || continue
  name=$(basename "$f")
  out="$THUMB/$name"
  [ -e "$out" ] || magick "$f" -resize "400x400>" -quality 80 "$out"
done

# 4. Post markdown (non sovrascrive).
if [ -e "$POST" ]; then
  echo "Post esistente, non sovrascrivo: $(basename "$POST")"
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
  echo "Scritto: $(basename "$POST")"
fi

echo "OK $EVENT_KEY → full:$(ls "$FULL" | wc -l | tr -d ' ') thumb:$(ls "$THUMB" | wc -l | tr -d ' ')"
