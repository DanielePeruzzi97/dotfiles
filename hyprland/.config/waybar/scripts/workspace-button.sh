#!/bin/bash
DESKTOP=$1
STATE_FILE="/tmp/hypr-virtual-desktop"

output() {
    local current=1
    [[ -f "$STATE_FILE" ]] && current=$(cat "$STATE_FILE")
    
    if [[ $DESKTOP -eq $current ]]; then
        echo "{\"text\": \"$DESKTOP\", \"class\": \"active\", \"tooltip\": \"Desktop $DESKTOP (active)\"}"
    else
        echo "{\"text\": \"$DESKTOP\", \"class\": \"inactive\", \"tooltip\": \"Desktop $DESKTOP\"}"
    fi
}

output

socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" 2>/dev/null | while read -r _; do
    output
done
