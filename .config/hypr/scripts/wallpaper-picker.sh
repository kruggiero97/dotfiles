#!/usr/bin/env bash
set -euo pipefail

DIR="$HOME/Pictures/Wallpapers"
SETWALL="$HOME/bin/set-wallpaper"
ROFI_CONF="$HOME/.config/rofi/config-wallpaper.rasi"

find "$DIR" -maxdepth 1 -type f -iname "*.png" -print0 |
  sort -z |
  while IFS= read -r -d '' path; do
    file="$(basename "$path")"
    name="${file%.png}"
    printf '%s\0icon\x1f%s\n' "$name" "$path"
  done |
  rofi -config "$ROFI_CONF" -dmenu -i -p "Wallpaper" -show-icons |
  while IFS= read -r choice; do
    [[ -n "$choice" ]] || exit 0
    "$SETWALL" "$choice"
  done
