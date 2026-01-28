#!/usr/bin/env bash
set -euo pipefail

MID="$(cat /etc/machine-id)"
MONDIR="$HOME/.config/niri/conf/monitors"

mkdir -p "$MONDIR"

case "$MID" in
# Macbook Pro machine-id
"01c9ee621cd348b3b67ccf5be5427a2b")
  ln -sf "$MONDIR/mbp.kdl" "$MONDIR/current.kdl"
  ;;
# Desktop machine-id
"697769973ba3408c861c7e5a48aece59")
  ln -sf "$MONDIR/desktop.kdl" "$MONDIR/current.kdl"
  ;;
*)
  echo "Unknown machine-id: $MID" >&2
  ln -sf "$MONDIR/desktop.kdl" "$MONDIR/current.kdl"
  ;;
esac
