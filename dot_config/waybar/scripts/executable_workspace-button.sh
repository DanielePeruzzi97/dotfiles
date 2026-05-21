#!/bin/bash
# Waybar workspace button - outputs JSON for custom/workspace-N module
# Filters socat events to only react to workspace changes

DESKTOP=$1
STATE_FILE="/tmp/hypr-virtual-desktop"

output() {
    local current=1
    [[ -f "$STATE_FILE" ]] && current=$(cat "$STATE_FILE")
    
    if [[ $DESKTOP -eq $current ]]; then
        echo "{\"text\": \"$DESKTOP\", \"class\": \"active\"}"
    else
        echo "{\"text\": \"$DESKTOP\", \"class\": \"inactive\"}"
    fi
}

# Initial output
output

# Listen for Hyprland events, but only react to workspace-related ones
socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" 2>/dev/null | \
while IFS= read -r event; do
    # Only update on workspace events (workspace, focusedmon, monitoradded, monitorremoved)
    case "$event" in
        workspace*|focusedmon*|monitor*)
            output
            ;;
    esac
done
