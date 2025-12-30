#!/usr/bin/env bash
set -euo pipefail

MID="$(cat /etc/machine-id)"
MONDIR="$HOME/.config/hypr/conf/monitors"

case "$MID" in
# Macbook Pro machine-id
"01c9ee621cd348b3b67ccf5be5427a2b")
  ln -sf "$MONDIR/mbp_monitor_variation.conf" "$MONDIR/current.conf"
  ;;
# Desktop machine-id
"697769973ba3408c861c7e5a48aece59")
  ln -sf "$MONDIR/my_monitor_variation.conf" "$MONDIR/current.conf"
  ;;
*)
  echo "Unknown machine-id: $MID" >&2
  ln -sf "$MONDIR/my_monitor_variation.conf" "$MONDIR/current.conf"
  ;;
esac

hyprctl reload >/dev/null 2>&1 || true
