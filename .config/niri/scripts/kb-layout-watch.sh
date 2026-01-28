#!/usr/bin/env bash
set -euo pipefail

ICON="$HOME/.local/share/icons/custom/keyboard.svg"
ARGS=(-h int:transient:1 -t 1500)

get_layout() {
  niri msg keyboard-layouts 2>/dev/null |
    awk '$1=="*" { $1=""; $2=""; sub(/^  */, "", $0); print; exit }'
}

last="$(get_layout || true)"

while true; do
  cur="$(get_layout || true)"
  if [[ -n "$cur" && "$cur" != "$last" ]]; then
    last="$cur"
    # tiny debounce so the layout is fully applied before the toast
    sleep 0.05
    if [[ -f "$ICON" ]]; then
      notify-send "${ARGS[@]}" -i "$ICON" "Keyboard layout" "$cur"
    else
      notify-send "${ARGS[@]}" "   Keyboard layout" "$cur"
    fi
  fi
  sleep 0.15
done
