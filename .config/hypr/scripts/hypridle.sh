#!/bin/bash
#  _   _                  _     _ _
# | | | |_   _ _ __  _ __(_) __| | | ___
# | |_| | | | | '_ \| '__| |/ _` | |/ _ \
# |  _  | |_| | |_) | |  | | (_| | |  __/
# |_| |_|\__, | .__/|_|  |_|\__,_|_|\___|
#        |___/|_|
#

SERVICE="hypridle"
WAYBAR_SIGNAL=8 # must match "signal": 8 in your waybar module

if [[ "$1" == "status" ]]; then
  # (optional) remove the sleep; it can make the UI feel laggy
  # sleep 1
  if pgrep -x "$SERVICE" >/dev/null; then
    echo '{"text": "RUNNING", "class": "active", "tooltip": "Screen locking active\nLeft: Deactivate"}'
  else
    echo '{"text": "NOT RUNNING", "class": "notactive", "tooltip": "Screen locking deactivated\nLeft: Activate"}'
  fi
  exit 0
fi

if [[ "$1" == "toggle" ]]; then
  if pgrep -x "$SERVICE" >/dev/null; then
    killall hypridle
  else
    hypridle &
    disown
  fi

  # force waybar to re-run the status command immediately
  pkill -RTMIN+"$WAYBAR_SIGNAL" waybar 2>/dev/null || true
  exit 0
fi
