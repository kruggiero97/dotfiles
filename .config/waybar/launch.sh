#!/usr/bin/env bash
set -euo pipefail

# Prevent duplicate launches
exec 200>/tmp/waybar-launch.lock
flock -n 200 || exit 0

# Kill existing Waybar
pkill -x waybar >/dev/null 2>&1 || true
sleep 0.2

STYLE="$HOME/.config/waybar/themes/khloe/colored/style-custom.css"
CFG_HYPR="$HOME/.config/waybar/themes/khloe/config-hyprland.json"
CFG_NIRI="$HOME/.config/waybar/themes/khloe/config-niri.json"

# Detect compositor/session
if [[ -n "${NIRI_SOCKET:-}" ]] || [[ "${XDG_CURRENT_DESKTOP:-}" =~ ([Nn]iri) ]]; then
  CONFIG="$CFG_NIRI"
else
  CONFIG="$CFG_HYPR"
fi

waybar -c "$CONFIG" -s "$STYLE" &

# Release lock
flock -u 200
exec 200>&-
