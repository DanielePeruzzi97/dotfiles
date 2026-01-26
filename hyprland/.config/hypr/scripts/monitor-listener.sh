#!/bin/bash
STATE_FILE="/tmp/hypr-virtual-desktop"

get_monitor_count() {
    hyprctl monitors -j | jq 'length'
}

get_monitors() {
    hyprctl monitors -j | jq -r 'sort_by(.id) | .[].name'
}

ws_for_monitor() {
    local monitor_idx=$1
    local desktop=$2
    echo $((desktop + monitor_idx * 5))
}

rescue_windows() {
    local mon_count=$(get_monitor_count)
    local max_ws=$((mon_count * 5))
    
    hyprctl clients -j | jq -r ".[] | select(.workspace.id > $max_ws) | .address" | while read -r addr; do
        [[ -n "$addr" ]] && hyprctl dispatch movetoworkspacesilent "1,address:$addr"
    done
}

reinit_desktop() {
    local current=1
    [[ -f "$STATE_FILE" ]] && current=$(cat "$STATE_FILE")
    
    ~/.config/hypr/scripts/virtual-desktop.sh "$current" switch
}

restart_waybar() {
    pkill -9 waybar 2>/dev/null
    pkill -f "workspace-button.sh" 2>/dev/null
    sleep 0.5
    waybar &
}

handle_event() {
    rescue_windows
    sleep 0.3
    reinit_desktop
    restart_waybar
}

echo "Monitor event listener started"
socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" 2>/dev/null | while read -r line; do
    case "$line" in
        monitoradded*|monitorremoved*)
            echo "Monitor change detected: $line"
            sleep 1
            handle_event
            ;;
    esac
done
