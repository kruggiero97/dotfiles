#!/usr/bin/env bash
set -euo pipefail

DIR="$HOME/Pictures/Wallpapers"
SETWALL="$HOME/bin/set-wallpaper"
ROFI_CONF="$HOME/.config/rofi/config-wallpaper.rasi"

FAV_DIR="$HOME/.config/wallpaper"
FAV_FILE="$FAV_DIR/favorites.txt"
mkdir -p "$FAV_DIR"
touch "$FAV_FILE"

have() { command -v "$1" >/dev/null 2>&1; }

notify() {
  local title="$1"
  shift
  local body="${1:-}"

  if have notify-send; then
    notify-send \
      -a "wallpaper-picker" \
      -u low \
      -t 1200 \
      -h int:transient:1 \
      "$title" "$body" >/dev/null 2>&1 || true
  fi
}

is_fav() { grep -Fxq -- "$1" "$FAV_FILE"; }

add_fav() {
  local name="$1"
  is_fav "$name" || printf '%s\n' "$name" >>"$FAV_FILE"
}

del_fav() {
  local name="$1"
  grep -Fxv -- "$name" "$FAV_FILE" >"$FAV_FILE.tmp" || true
  mv -f "$FAV_FILE.tmp" "$FAV_FILE"
}

toggle_fav() {
  local name="$1"
  if is_fav "$name"; then
    del_fav "$name"
    notify "☆ Unfavorited" "$name"
  else
    add_fav "$name"
    notify "★ Favorited" "$name"
  fi
}

# Map name -> path
declare -A PATH_BY_NAME=()
while IFS= read -r -d '' path; do
  file="$(basename "$path")"
  name="${file%.*}"
  PATH_BY_NAME["$name"]="$path"
done < <(find "$DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) -print0)

print_row() {
  local name="$1"
  local path="${PATH_BY_NAME[$name]:-}"
  [[ -n "$path" ]] || return 0

  local star="☆"
  is_fav "$name" && star="★"
  printf '%s %s\0icon\x1f%s\n' "$star" "$name" "$path"
}

# Rebuild list each time (so favorites refresh)
build_menu() {
  # favorites first (alphabetical)
  sort "$FAV_FILE" | while IFS= read -r fav; do
    [[ -n "${fav:-}" ]] || continue
    [[ -n "${PATH_BY_NAME[$fav]:-}" ]] || continue
    print_row "$fav"
  done

  # then non-favorites (alphabetical)
  for name in "${!PATH_BY_NAME[@]}"; do
    is_fav "$name" && continue
    printf '%s\n' "$name"
  done | sort | while IFS= read -r name; do
    print_row "$name"
  done
}

while true; do
  # IMPORTANT: allow rofi to exit with code 10 without killing the script
  set +e
  selection="$(
    build_menu |
      rofi -config "$ROFI_CONF" -dmenu -i -p "Wallpaper" -show-icons \
        -kb-custom-1 "Alt+f" \
        -mesg "Alt+F: toggle favorite • Enter: set wallpaper"
  )"
  rc=$?
  set -e

  # Esc / cancel
  [[ -n "${selection:-}" ]] || exit 0

  # Strip leading star + space
  selection="${selection#★ }"
  selection="${selection#☆ }"

  if [[ "$rc" -eq 10 ]]; then
    toggle_fav "$selection"
    continue
  fi

  "$SETWALL" "$selection"
  exit 0
done
