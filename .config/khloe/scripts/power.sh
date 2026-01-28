#!/usr/bin/env bash
set -euo pipefail

have() { command -v "$1" >/dev/null 2>&1; }

is_hyprland() {
  [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && have hyprctl
}

do_lock() {
  if is_hyprland && have hyprlock; then
    exec hyprlock
  fi
  # Use your existing niri swaylock wrapper (Catppuccin + images)
  if [[ -x "$HOME/.config/niri/scripts/lock.sh" ]]; then
    exec "$HOME/.config/niri/scripts/lock.sh"
  fi
  # Fallback
  exec loginctl lock-session
}

do_logout() {
  if is_hyprland; then
    exec hyprctl dispatch exit 0
  fi
  # Niri quit (preferred)
  if have niri; then
    exec niri msg action quit
  fi
  if have niri-msg; then
    exec niri-msg action quit
  fi
  # Last resort
  exec loginctl terminate-user "$USER"
}

case "${1:-}" in
lock) do_lock ;;
exit | logout) do_logout ;;
suspend) exec systemctl suspend ;;
reboot) exec systemctl reboot ;;
shutdown | poweroff) exec systemctl poweroff ;;
*)
  echo "usage: $0 {lock|logout|suspend|reboot|shutdown}" >&2
  exit 2
  ;;
esac
