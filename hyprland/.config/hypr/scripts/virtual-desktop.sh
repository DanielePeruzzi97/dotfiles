#!/bin/bash
# Virtual desktop switching - all monitors change together (GNOME/KDE style)
#
# Layout (5 virtual desktops, 2 monitors):
#   Desktop 1: Monitor 0 shows WS 1,  Monitor 1 shows WS 6
#   Desktop 2: Monitor 0 shows WS 2,  Monitor 1 shows WS 7
#   Desktop 3: Monitor 0 shows WS 3,  Monitor 1 shows WS 8
#   Desktop 4: Monitor 0 shows WS 4,  Monitor 1 shows WS 9
#   Desktop 5: Monitor 0 shows WS 5,  Monitor 1 shows WS 10
#
# Each monitor gets its own workspace range (mon0: 1-5, mon1: 6-10)
# When switching "desktop", all monitors switch to their corresponding workspace

DESKTOP_NUM=$1
ACTION=${2:-switch}
STATE_FILE="/tmp/hypr-virtual-desktop"

# Get monitors sorted by ID
get_monitors() {
    hyprctl monitors -j | jq -r 'sort_by(.id) | .[].name'
}

# Get currently focused monitor
get_focused() {
    hyprctl monitors -j | jq -r '.[] | select(.focused) | .name'
}

# Calculate workspace ID for a given monitor index and desktop
# monitor_idx: 0, 1, 2, ...
# desktop: 1-5
ws_for_monitor() {
    local monitor_idx=$1
    local desktop=$2
    echo $((desktop + monitor_idx * 5))
}

case "$ACTION" in
    "switch")
        FOCUSED=$(get_focused)
        
        # Switch all monitors to their respective workspaces atomically
        # Using dispatch batch for smoother transition
        BATCH=""
        i=0
        for mon in $(get_monitors); do
            WS=$(ws_for_monitor $i $DESKTOP_NUM)
            BATCH="$BATCH dispatch focusmonitor $mon ; dispatch workspace $WS ;"
            ((i++))
        done
        
        # Execute all switches, then return focus to original monitor
        hyprctl --batch "$BATCH dispatch focusmonitor $FOCUSED"
        
        echo "$DESKTOP_NUM" > "$STATE_FILE"
        pkill -RTMIN+1 waybar
        ;;
        
    "movesilent")
        # Move current window to the corresponding workspace on current monitor
        FOCUSED=$(get_focused)
        
        # Find which monitor index we're on
        i=0
        for mon in $(get_monitors); do
            if [[ "$mon" == "$FOCUSED" ]]; then
                WS=$(ws_for_monitor $i $DESKTOP_NUM)
                hyprctl dispatch movetoworkspacesilent "$WS"
                break
            fi
            ((i++))
        done
        ;;
        
    "move")
        # Move current window to desktop and follow it
        FOCUSED=$(get_focused)
        
        i=0
        for mon in $(get_monitors); do
            if [[ "$mon" == "$FOCUSED" ]]; then
                WS=$(ws_for_monitor $i $DESKTOP_NUM)
                hyprctl dispatch movetoworkspace "$WS"
                break
            fi
            ((i++))
        done
        
        # Now switch all monitors to that desktop
        "$0" "$DESKTOP_NUM" switch
        ;;
        
    "get")
        if [[ -f "$STATE_FILE" ]]; then
            cat "$STATE_FILE"
        else
            echo "1"
        fi
        ;;
        
    "moveall")
        CURRENT_DESKTOP=1
        [[ -f "$STATE_FILE" ]] && CURRENT_DESKTOP=$(cat "$STATE_FILE")
        
        i=0
        for mon in $(get_monitors); do
            SOURCE_WS=$(ws_for_monitor $i $CURRENT_DESKTOP)
            TARGET_WS=$(ws_for_monitor $i $DESKTOP_NUM)
            
            hyprctl clients -j | jq -r ".[] | select(.workspace.id == $SOURCE_WS) | .address" | while read -r addr; do
                [[ -n "$addr" ]] && hyprctl dispatch movetoworkspacesilent "$TARGET_WS,address:$addr"
            done
            ((i++))
        done
        ;;
esac
