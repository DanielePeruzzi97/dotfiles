#!/usr/bin/env bash
# Install JetBrainsMono Nerd Font
# Hash: {{ include "dot_config/ghostty/config" | sha256sum }}
# This script re-runs when terminal config changes (font might change)

set -euo pipefail

FONT_DIR="$HOME/.local/share/fonts"
NERD_FONT_VERSION="v3.3.0"
FONT_NAME="JetBrainsMono"

echo "Checking Nerd Fonts installation..."

mkdir -p "$FONT_DIR"

# Check if font is already installed
if ls "$FONT_DIR"/${FONT_NAME}Nerd* 1>/dev/null 2>&1; then
    echo "JetBrainsMono Nerd Font already installed, skipping"
    exit 0
fi

echo "Installing JetBrainsMono Nerd Font..."

# Download and install
TEMP_ZIP="/tmp/${FONT_NAME}.zip"
curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONT_VERSION}/${FONT_NAME}.zip" -o "$TEMP_ZIP"
unzip -o "$TEMP_ZIP" -d "$FONT_DIR" "*.ttf"
rm -f "$TEMP_ZIP"

# Refresh font cache
fc-cache -fv

echo "JetBrainsMono Nerd Font installed successfully"
