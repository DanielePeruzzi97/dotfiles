#!/bin/bash
# Virtual desktop switching - all monitors change together (GNOME/KDE style)
#
# Layout (5 virtual desktops, up to 3 monitors):
#   Desktop 1: Monitor 0 shows WS 1,  Monitor 1 shows WS 6,  Monitor 2 shows WS 11
#   Desktop 2: Monitor 0 shows WS 2,  Monitor 1 shows WS 7,  Monitor 2 shows WS 12
#   ...
#
# Monitors are sorted by X position (left to right) for consistency
# regardless of Hyprland monitor IDs which can change between dock setups

DESKTOP_NUM=$1
ACTION=${2:-switch}
STATE_FILE="/tmp/hypr-virtual-desktop"
LOCK_FILE="/tmp/hypr-vd.lock"
DEBOUNCE_MS=30

# Debounce rapid calls
debounce() {
    local now=$(date +%s%3N)
    local last=0
    [[ -f "${LOCK_FILE}.time" ]] && last=$(cat "${LOCK_FILE}.time" 2>/dev/null)
    
    if (( now - last < DEBOUNCE_MS )); then
        exit 0
    fi
    echo "$now" > "${LOCK_FILE}.time"
}

# Get monitors sorted by X position (left to right)
# This ensures consistent ordering regardless of monitor IDs
get_monitors() {
    hyprctl monitors -j | jq -r 'sort_by(.x) | .[].name'
}

# Get monitor count
get_monitor_count() {
    hyprctl monitors -j | jq 'length'
}

# Get currently focused monitor
get_focused() {
    hyprctl monitors -j | jq -r '.[] | select(.focused) | .name'
}

# Calculate workspace ID for a given monitor index and desktop
# monitor_idx: 0, 1, 2, ... (based on X position, not Hyprland ID)
# desktop: 1-5
# Result: desktop + monitor_idx * 5
ws_for_monitor() {
    local monitor_idx=$1
    local desktop=$2
    echo $((desktop + monitor_idx * 5))
}

# Rescue orphaned windows (on workspaces > max valid workspace)
rescue_orphans() {
    local mon_count=$(get_monitor_count)
    local max_ws=$((mon_count * 5))
    
    # Find windows on invalid workspaces and move to workspace 1
    local orphans=$(hyprctl clients -j | jq -r ".[] | select(.workspace.id > $max_ws) | .address")
    if [[ -n "$orphans" ]]; then
        while IFS= read -r addr; do
            [[ -n "$addr" ]] && hyprctl dispatch movetoworkspacesilent "1,address:$addr" 2>/dev/null
        done <<< "$orphans"
        notify-send -t 2000 "Hyprland" "Rescued orphaned windows to Desktop 1"
    fi
}

case "$ACTION" in
    "switch")
        debounce
        
        # Save cursor position
        CURSOR_POS=$(hyprctl cursorpos)
        CURSOR_X=$(echo "$CURSOR_POS" | cut -d',' -f1 | tr -d ' ')
        CURSOR_Y=$(echo "$CURSOR_POS" | cut -d',' -f2 | tr -d ' ')
        
        FOCUSED=$(get_focused)
        mapfile -t MONITORS < <(get_monitors)
        
        # Find focused monitor index
        FOCUSED_IDX=0
        for i in "${!MONITORS[@]}"; do
            [[ "${MONITORS[$i]}" == "$FOCUSED" ]] && FOCUSED_IDX=$i
        done
        
        # Build single batch command for speed
        BATCH=""
        
        # 1. Bind workspaces to correct monitors
        for i in "${!MONITORS[@]}"; do
            WS=$(ws_for_monitor $i $DESKTOP_NUM)
            BATCH+="dispatch moveworkspacetomonitor $WS ${MONITORS[$i]} ; "
        done
        
        # 2. Focus each monitor and switch its workspace
        for i in "${!MONITORS[@]}"; do
            WS=$(ws_for_monitor $i $DESKTOP_NUM)
            BATCH+="dispatch focusmonitor ${MONITORS[$i]} ; dispatch workspace $WS ; "
        done
        
        # 3. Return focus to original monitor and restore cursor
        BATCH+="dispatch focusmonitor $FOCUSED ; dispatch movecursor $CURSOR_X $CURSOR_Y"
        
        # Execute all at once (faster, less flicker)
        hyprctl --batch "$BATCH" 2>/dev/null
        
        # Update state and signal waybar
        echo "$DESKTOP_NUM" > "$STATE_FILE"
        pkill -RTMIN+1 waybar 2>/dev/null
        ;;
        
    "movesilent")
        FOCUSED=$(get_focused)
        mapfile -t MONITORS < <(get_monitors)
        
        for i in "${!MONITORS[@]}"; do
            if [[ "${MONITORS[$i]}" == "$FOCUSED" ]]; then
                WS=$(ws_for_monitor $i $DESKTOP_NUM)
                hyprctl dispatch movetoworkspacesilent "$WS"
                break
            fi
        done
        ;;
        
    "move")
        FOCUSED=$(get_focused)
        mapfile -t MONITORS < <(get_monitors)
        
        for i in "${!MONITORS[@]}"; do
            if [[ "${MONITORS[$i]}" == "$FOCUSED" ]]; then
                WS=$(ws_for_monitor $i $DESKTOP_NUM)
                hyprctl dispatch movetoworkspace "$WS"
                break
            fi
        done
        
        # Switch all monitors to that desktop
        exec "$0" "$DESKTOP_NUM" switch
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
        
        mapfile -t MONITORS < <(get_monitors)
        BATCH=""
        
        for i in "${!MONITORS[@]}"; do
            SOURCE_WS=$(ws_for_monitor $i $CURRENT_DESKTOP)
            TARGET_WS=$(ws_for_monitor $i $DESKTOP_NUM)
            
            while IFS= read -r addr; do
                [[ -n "$addr" ]] && BATCH+="dispatch movetoworkspacesilent $TARGET_WS,address:$addr ; "
            done < <(hyprctl clients -j | jq -r ".[] | select(.workspace.id == $SOURCE_WS) | .address")
        done
        
        [[ -n "$BATCH" ]] && hyprctl --batch "$BATCH" 2>/dev/null
        ;;
        
    "rescue")
        # Rescue orphaned windows from invalid workspaces
        rescue_orphans
        ;;
        
    "init")
        # Initialize to desktop 1 and rescue orphans
        rescue_orphans
        exec "$0" 1 switch
        ;;
esac
