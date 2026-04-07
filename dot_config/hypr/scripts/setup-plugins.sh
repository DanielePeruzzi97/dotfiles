#!/usr/bin/env bash
# Install and configure Hyprland plugins
# This script runs at Hyprland startup to ensure plugins are installed

PLUGIN_CONF="$HOME/.config/hypr/plugin.conf"
HYPRSPLIT_INSTALLED=false

# Check if hyprsplit is already installed
if hyprpm list 2>/dev/null | grep -q "hyprsplit"; then
    HYPRSPLIT_INSTALLED=true
fi

# Install hyprsplit if not present
if [ "$HYPRSPLIT_INSTALLED" = false ]; then
    notify-send "Hyprland" "Installing hyprsplit plugin..." -t 3000 2>/dev/null || true
    
    # Update hyprpm and install hyprsplit
    if hyprpm update && hyprpm add https://github.com/shezdy/hyprsplit && hyprpm enable hyprsplit; then
        HYPRSPLIT_INSTALLED=true
        notify-send "Hyprland" "hyprsplit plugin installed successfully" -t 3000 2>/dev/null || true
    else
        notify-send "Hyprland" "Failed to install hyprsplit plugin" -u critical -t 5000 2>/dev/null || true
    fi
fi

# If plugin is installed, load plugin config and switch to scrolling layout
if [ "$HYPRSPLIT_INSTALLED" = true ] && [ -f "$PLUGIN_CONF" ]; then
    # Source the plugin config
    hyprctl keyword source "$PLUGIN_CONF"
    # Switch to scrolling layout
    hyprctl keyword general:layout scrolling
fi
