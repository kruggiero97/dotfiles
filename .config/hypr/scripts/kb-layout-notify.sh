#!/usr/bin/env bash

# Declare bash variables
ICON="$HOME/.local/share/icons/custom/keyboard.svg"
ARGS="-h int:transient:1 -t 1500"

# Path to Hyprland's event socket
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

# Listen for events coming from socket2
socat - "UNIX-CONNECT:$SOCKET" | while read -r line; do
  # We care only about activelayout events
  # They look like: activelayout>>keyboard_name,layout_name
  if [[ "$line" == activelayout* ]]; then
    data="${line#activelayout>>}" # strip "activelayout>>"
    keyboard="${data%%,*}"        # part before comma
    layout="${data#*,}"           # part after comma

    # Show a notification via swaync
    if [ -f "$ICON" ]; then
      # Use SVG icon
      notify-send $ARGS -i "$ICON" \
        "Keyboard layout" "$layout"
    else
      # Fall back to a Nerd Font glyph
      notify-send $ARGS \
        "   Keyboard layout" "$layout"
    fi
  fi
done
