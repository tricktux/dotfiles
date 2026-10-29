#!/usr/bin/env bash
set -euo pipefail

# yay -Syu --needed tesseract tesseract-data-eng wl-clipboard grim slurp

tmpdir="$(mktemp -d)"
img="$tmpdir/shot.png"
txt="$tmpdir/out.txt"

region="$(slurp)"
grim -g "$region" "$img"

tesseract "$img" "$tmpdir/out" -l eng >/dev/null 2>&1
cat "$txt" | wl-copy

notify-send "OCR" "Text copied to clipboard\n\n$txt"
