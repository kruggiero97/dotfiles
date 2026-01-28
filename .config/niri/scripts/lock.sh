#!/usr/bin/env bash
set -euo pipefail

WALL="$HOME/.config/wallpaper/blurred.png"
AVATAR="$HOME/.config/wallpaper/square.png"

# Catppuccin Mocha – exact palette (rrggbbaa)
TEXT="cdd6f4ff"    # text
SUBTEXT="bac2deff" # subtext1

RING_IDLE="cba6f7ff"  # mauve (border_active)
RING_VER="89b4faff"   # blue
RING_WRONG="f38ba8ff" # red

INSIDE="1e1e2eaa" # mantle @ ~67% opacity

GREEN="a6e3a1ff" # green
RED="f38ba8ff"   # red

args=(
  --daemonize
  --indicator
  --clock
  --timestr "%I:%M %p"
  --datestr "%a %m/%d/%Y"
  --font "Fira Sans Semibold"

  # Text
  --text-color "$TEXT"
  --text-ver-color "$TEXT"
  --text-wrong-color "$TEXT"

  # Ring states
  --ring-color "$RING_IDLE"
  --ring-ver-color "$RING_VER"
  --ring-wrong-color "$RING_WRONG"

  # Inside fill
  --inside-color "$INSIDE"
  --inside-ver-color "$INSIDE"
  --inside-wrong-color "$INSIDE"

  # Key / backspace highlights
  --key-hl-color "$GREEN"
  --bs-hl-color "$RED"

  # Clean indicator (no separators/lines)
  --separator-color "00000000"
  --line-color "00000000"

  --indicator-radius 90
  --indicator-thickness 8
  --fade-in 0.2
)

# Background: prefer canonical blurred wallpaper
if [[ -f "$WALL" ]]; then
  args+=(--image "$WALL" --scaling fill)
else
  # Fallback: blurred screenshot
  args+=(--screenshots --effect-blur 10x5)
fi

# Optional centered image (hyprlock-like)
if [[ -f "$AVATAR" ]]; then
  args+=(--indicator-image "$AVATAR")
fi

exec swaylock "${args[@]}"
