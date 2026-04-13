#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EWW_CONFIG_DIR="$HOME/.config/eww"
BIN_DIR="$HOME/.local/bin"

echo "==> Installing TickTick Today widget for Omarchy"
echo

# ── 1. Install eww ────────────────────────────────────────────────────────────
if ! command -v eww &>/dev/null; then
  echo "--> Installing eww from AUR..."
  yay -S --noconfirm eww
else
  echo "--> eww already installed: $(eww --version)"
fi

# ── 2. Install Python dependencies ───────────────────────────────────────────
echo "--> Checking Python dependencies..."
if ! python3 -c "import requests" 2>/dev/null; then
  echo "--> Installing python-requests..."
  sudo pacman -S --noconfirm python-requests 2>/dev/null || pip install --user requests
fi

# ── 3. Install fetch scripts ──────────────────────────────────────────────────
echo "--> Installing scripts to $BIN_DIR ..."
mkdir -p "$BIN_DIR"
install -m 755 "$SCRIPT_DIR/scripts/ticktick-auth"  "$BIN_DIR/ticktick-auth"
install -m 755 "$SCRIPT_DIR/scripts/ticktick-today" "$BIN_DIR/ticktick-today"

# Make sure ~/.local/bin is on PATH
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
  echo "  NOTE: Add $HOME/.local/bin to your PATH if it isn't already"
fi

# ── 4. Copy eww config ────────────────────────────────────────────────────────
echo "--> Setting up eww config in $EWW_CONFIG_DIR ..."
mkdir -p "$EWW_CONFIG_DIR"

if [ -f "$EWW_CONFIG_DIR/eww.yuck" ]; then
  cp "$EWW_CONFIG_DIR/eww.yuck" "$EWW_CONFIG_DIR/eww.yuck.bak.$(date +%s)"
  echo "  Backed up existing eww.yuck"
fi
if [ -f "$EWW_CONFIG_DIR/eww.scss" ]; then
  cp "$EWW_CONFIG_DIR/eww.scss" "$EWW_CONFIG_DIR/eww.scss.bak.$(date +%s)"
  echo "  Backed up existing eww.scss"
fi

cp "$SCRIPT_DIR/eww/eww.yuck" "$EWW_CONFIG_DIR/eww.yuck"
cp "$SCRIPT_DIR/eww/eww.scss" "$EWW_CONFIG_DIR/eww.scss"

# ── 5. Save TickTick API token ────────────────────────────────────────────────
echo
echo "==> Next: save your TickTick API token"
echo
read -rp "Run ticktick-auth now? [Y/n] " yn
if [[ "${yn,,}" != "n" ]]; then
  ticktick-auth
fi

# ── 6. Add to Hyprland autostart (optional) ───────────────────────────────────
echo
read -rp "Add widget to Hyprland autostart? [y/N] " yn
if [[ "${yn,,}" == "y" ]]; then
  AUTOSTART="$HOME/.config/hypr/autostart.conf"
  if ! grep -q "eww open ticktick" "$AUTOSTART" 2>/dev/null; then
    echo "" >> "$AUTOSTART"
    echo "# TickTick Today widget" >> "$AUTOSTART"
    echo "exec-once = eww daemon && eww open ticktick" >> "$AUTOSTART"
    echo "--> Added to $AUTOSTART"
  else
    echo "--> Already in autostart"
  fi
fi

echo
echo "==> Done! Start the widget with:"
echo
echo "    eww daemon && eww open ticktick"
echo
echo "    To refresh tasks manually: eww reload"
echo "    To close: eww close ticktick"
echo "    To kill daemon: eww kill"
