#!/bin/bash
# Rofi clipboard manager using cliphist

if [ -z "$@" ]; then
    # Initial mode - show clipboard history
    cliphist list | head -20
else
    # Selection made - copy to clipboard
    printf '%s' "$@" | cliphist decode | wl-copy
    # Send notification
    notify-send "Clipboard" "Copied to clipboard" -t 1000
fi