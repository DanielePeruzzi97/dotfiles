#!/usr/bin/env bash
# Change default shell to zsh

set -euo pipefail

echo "Checking default shell..."

# Get current shell
CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)
ZSH_PATH=$(which zsh 2>/dev/null || echo "/usr/bin/zsh")

if [ "$CURRENT_SHELL" = "$ZSH_PATH" ]; then
    echo "zsh is already the default shell"
    exit 0
fi

if [ ! -x "$ZSH_PATH" ]; then
    echo "Warning: zsh not found, skipping shell change"
    exit 0
fi

echo "Changing default shell to zsh..."
echo "You may be prompted for your password"

# Try chsh without sudo first (works on some systems)
if chsh -s "$ZSH_PATH" 2>/dev/null; then
    echo "Default shell changed to zsh"
else
    # Fall back to sudo chsh
    sudo chsh -s "$ZSH_PATH" "$USER"
    echo "Default shell changed to zsh"
fi

echo "Note: Log out and back in for the change to take effect"
