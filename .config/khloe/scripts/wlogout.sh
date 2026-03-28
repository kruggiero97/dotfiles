#!/usr/bin/env bash
set -euo pipefail

have() { command -v "$1" >/dev/null 2>&1; }

# Defaults (never crash)
res_h=1080
scale=1.0

# -------------------------
# Hyprland: use JSON
# -------------------------
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && have hyprctl; then
  mon_json="$(hyprctl -j monitors 2>/dev/null || true)"
  if jq -e . >/dev/null 2>&1 <<<"$mon_json"; then
    res_h="$(jq -r '.[] | select(.focused==true) | .height' <<<"$mon_json" | head -n1)"
    scale="$(jq -r '.[] | select(.focused==true) | .scale' <<<"$mon_json" | head -n1)"
  fi
fi

# -------------------------
# Niri: parse plaintext
# -------------------------
if [[ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && have niri; then
  # Example line:
  #   Logical size: 2560x1440
  # Grab the first "Logical size" height we see.
  out="$(niri msg outputs 2>/dev/null || true)"
  h="$(awk '
    /Logical size:/ {
      # field 3 should be like 2560x1440
      split($3, a, "x");
      if (a[2] ~ /^[0-9]+$/) { print a[2]; exit }
    }' <<<"$out")"

  if [[ -n "${h:-}" ]]; then
    res_h="$h"
  fi

  # Niri output doesn't include scale; assume 1.0
  scale=1.0
fi

# Normalize res_h and scale
[[ "${res_h:-}" =~ ^[0-9]+$ ]] || res_h=1080
if [[ -z "${scale:-}" ]] || ! awk "BEGIN{exit(!(${scale}>0))}" 2>/dev/null; then
  scale=1.0
fi

# Compute margin as ~27% of screen height, adjusted for scale.
# (This is the "0.27" version of your original "27 / (scale*10)" intention.)
w_margin="$(awk -v h="$res_h" -v s="$scale" 'BEGIN{ printf "%.0f", (h * 0.27) / s }')"

# Clamp margin to avoid wlogout crashes on weird values
min=80
max=600
if ((w_margin < min)); then w_margin=$min; fi
if ((w_margin > max)); then w_margin=$max; fi

exec wlogout -b 5 -T "$w_margin" -B "$w_margin"
