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
    
    local focused=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
    local batch=""
    local i=0
    
    for mon in $(get_monitors); do
        local ws=$(ws_for_monitor $i $current)
        batch="$batch dispatch focusmonitor $mon ; dispatch workspace $ws ;"
        ((i++))
    done
    
    hyprctl --batch "$batch dispatch focusmonitor $focused" 2>/dev/null
}

restart_waybar() {
    pkill -9 waybar 2>/dev/null
    pkill -f "workspace-button.sh" 2>/dev/null
    sleep 0.3
    waybar &
}

rescue_windows
reinit_desktop
restart_waybar
