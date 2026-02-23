#!/bin/bash
# Monitor hotplug handler - rescues windows and reinitializes virtual desktops
# Called by hyprdynamicmonitors when monitor configuration changes

STATE_FILE="/tmp/hypr-virtual-desktop"
LOCK_FILE="/tmp/hypr-monitor-hotplug.lock"

# Prevent concurrent execution
exec 200>"$LOCK_FILE"
flock -n 200 || exit 0

cleanup() {
    flock -u 200
}
trap cleanup EXIT

get_monitor_count() {
    hyprctl monitors -j | jq 'length'
}

get_monitors() {
    hyprctl monitors -j | jq -r 'sort_by(.id) | .[].name'
}

ws_for_monitor() {
    echo $(($1 * 5 + $2))
}

rescue_windows() {
    local mon_count=$(get_monitor_count)
    local max_ws=$((mon_count * 5))
    local batch=""
    
    # Move all windows from out-of-range workspaces to workspace 1
    while IFS= read -r addr; do
        [[ -n "$addr" ]] && batch+="dispatch movetoworkspacesilent 1,address:$addr ; "
    done < <(hyprctl clients -j | jq -r ".[] | select(.workspace.id > $max_ws) | .address")
    
    [[ -n "$batch" ]] && hyprctl --batch "$batch" 2>/dev/null
}

reinit_desktop() {
    local current=1
    [[ -f "$STATE_FILE" ]] && current=$(cat "$STATE_FILE")
    
    local focused=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
    mapfile -t monitors < <(get_monitors)
    
    local batch=""
    for i in "${!monitors[@]}"; do
        local ws=$(ws_for_monitor $i $current)
        batch+="dispatch focusmonitor ${monitors[$i]} ; dispatch workspace $ws ; "
    done
    batch+="dispatch focusmonitor $focused"
    
    hyprctl --batch "$batch" 2>/dev/null
}

restart_waybar() {
    # Try graceful reload first via SIGUSR2
    if pkill -SIGUSR2 waybar 2>/dev/null; then
        sleep 0.2
        # Verify waybar is still running
        pgrep -x waybar >/dev/null && return 0
    fi
    
    # Fallback: full restart
    pkill -9 waybar 2>/dev/null
    pkill -f "workspace-button.sh" 2>/dev/null
    sleep 0.3
    nohup waybar > /tmp/waybar.log 2>&1 &
    disown
}

rescue_windows
reinit_desktop
restart_waybar
