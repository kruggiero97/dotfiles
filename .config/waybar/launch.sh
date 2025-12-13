#!/usr/bin/env bash
set -euo pipefail

# Prevent duplicate launches
exec 200>/tmp/waybar-launch.lock
flock -n 200 || exit 0

# Kill existing Waybar
pkill -x waybar || true
sleep 0.2

# Launch YOUR copied theme
CONFIG="$HOME/.config/waybar/themes/khloe/config"
STYLE="$HOME/.config/waybar/themes/khloe/colored/style-custom.css"

waybar -c "$CONFIG" -s "$STYLE" &

# Release lock
flock -u 200
exec 200>&-
