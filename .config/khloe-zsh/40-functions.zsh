# -----------------------------------------------------
# Functions
# -----------------------------------------------------

# Install a WoW addon zip into the Forever beta client
wowaddon() {
  local dest="/media/2TBDrive/Games/Blizzard/World of Warcraft/_classic_beta_/Interface/AddOns"
  [[ -z "$1" ]] && { echo "usage: wowaddon <zipfile...>"; return 1 }
  for zip in "$@"; do
    [[ -f "$zip" ]] || { echo "not found: $zip"; continue }
    unzip -o "$zip" -d "$dest" >/dev/null && echo "installed: ${zip:t}"
  done
}
