#!/usr/bin/env bash
set -euo pipefail

WAYBAR_SIGNAL="8"

# What you want swayidle to do when idle triggers
LOCK_CMD='loginctl lock-session'
SUSPEND_CMD='systemctl suspend'

# Timeouts (edit to match your hypridle behavior)
LOCK_AFTER_SECONDS=300
SUSPEND_AFTER_SECONDS=900

# Start swayidle in the background with your policy
start_swayidle() {
  # -w: wait in foreground (we'll background it ourselves)
  nohup swayidle -w \
    timeout "${LOCK_AFTER_SECONDS}" "${LOCK_CMD}" \
    timeout "${SUSPEND_AFTER_SECONDS}" "${SUSPEND_CMD}" \
    before-sleep "${LOCK_CMD}" \
    >/dev/null 2>&1 &
}

stop_swayidle() {
  pkill -x swayidle || true
}

is_running() {
  pgrep -x swayidle >/dev/null 2>&1
}

refresh_waybar() {
  # Tell waybar to refresh custom modules with signal 8
  pkill -RTMIN+"${WAYBAR_SIGNAL}" waybar 2>/dev/null || true
}

status() {
  if is_running; then
    printf '{"text":"RUNNING","class":"active","tooltip":"Screen locking active\\nLeft: Deactivate"}\n'
  else
    printf '{"text":"NOT RUNNING","class":"notactive","tooltip":"Screen locking deactivated\\nLeft: Activate"}\n'
  fi
}

toggle() {
  if is_running; then
    stop_swayidle
  else
    start_swayidle
  fi
  refresh_waybar
}

case "${1:-}" in
status) status ;;
toggle) toggle ;;
start)
  start_swayidle
  refresh_waybar
  ;;
stop)
  stop_swayidle
  refresh_waybar
  ;;
*)
  echo "usage: $0 {status|toggle|start|stop}" >&2
  exit 2
  ;;
esac
