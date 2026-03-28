#!/usr/bin/env bash
set -euo pipefail

script_name="$(basename "$0")"

instance_count=$(ps aux | grep -F "$script_name" | grep -v grep | grep -v $$ | wc -l)
if [ "$instance_count" -gt 1 ]; then
  sleep "$instance_count"
fi

# Thresholds for class
threshhold_green=0
threshhold_yellow=25
threshhold_red=100

_checkCommandExists() {
  command -v "$1" >/dev/null 2>&1 && echo 0 || echo 1
}

# Wait for pacman / checkup locks
check_lock_files() {
  local pacman_lock="/var/lib/pacman/db.lck"
  local checkup_lock="${TMPDIR:-/tmp}/checkup-db-${UID}/db.lck"
  while [ -f "$pacman_lock" ] || [ -f "$checkup_lock" ]; do
    sleep 1
  done
}

updates=0

# Arch
if [[ $(_checkCommandExists "pacman") == 0 ]]; then
  check_lock_files

  repo_updates=0
  aur_updates=0

  # repo updates
  if command -v checkupdates >/dev/null 2>&1; then
    repo_updates="$(checkupdates 2>/dev/null | wc -l || true)"
  fi

  # AUR updates via paru/yay if present (optional)
  if command -v paru >/dev/null 2>&1; then
    aur_updates="$(paru -Qua 2>/dev/null | wc -l || true)"
  elif command -v yay >/dev/null 2>&1; then
    aur_updates="$(yay -Qua 2>/dev/null | wc -l || true)"
  fi

  updates=$((repo_updates + aur_updates))

# Fedora
elif [[ $(_checkCommandExists "dnf") == 0 ]]; then
  updates="$(dnf check-update -q 2>/dev/null | grep -c '^[a-z0-9]' || true)"
fi

# Choose class
css_class="green"
if [ "$updates" -gt "$threshhold_yellow" ]; then css_class="yellow"; fi
if [ "$updates" -gt "$threshhold_red" ]; then css_class="red"; fi

# Only output when non-zero (matches your hide-empty-text usage)
if [ "$updates" -ne 0 ]; then
  printf '{"text":"%s","alt":"%s","tooltip":"Click to update your system","class":"%s"}' \
    "$updates" "$updates" "$css_class"
fi
