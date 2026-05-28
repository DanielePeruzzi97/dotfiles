#!/bin/bash
# virtual-desktop-sync.sh - Daemon to sync virtual desktops on external window activation
#
# Problem: When focus_on_activate is enabled and a notification is clicked,
# Hyprland focuses the window and switches only that monitor's workspace,
# breaking the virtual desktop sync (where all monitors should switch together).
#
# Solution: Listen to Hyprland IPC events. When a window is activated WITHOUT
# a preceding workspace event (meaning it was an external activation, not a user
# keybind), and the monitors are out of sync, trigger a full virtual desktop switch.
#
# Key insight from Hyprland docs: "workspace" IPC event is ONLY emitted on
# USER-INITIATED workspace changes (keybinds), NOT on focus_on_activate.

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
STATE_FILE="/tmp/hypr-virtual-desktop"
LOCK_FILE="/tmp/hypr-vd-sync.lock"
PID_FILE="/tmp/hypr-vd-sync.pid"
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

# Time window (ms) to consider events as related
EVENT_WINDOW_MS=100

# Track the last workspace event timestamp
LAST_WS_EVENT_TIME=0

# Cleanup on exit
cleanup() {
    # Kill any child processes (socat)
    pkill -P $$ 2>/dev/null
    rm -f "$PID_FILE" 2>/dev/null
    exec 200>&-
}
trap cleanup EXIT INT TERM

# Prevent multiple instances
exec 200>"$LOCK_FILE"
if ! flock -n 200; then
    echo "virtual-desktop-sync: Already running (PID $(cat "$PID_FILE" 2>/dev/null))"
    exit 1
fi
echo $$ > "$PID_FILE"

# Logging (only if DEBUG is set)
log() {
    [[ -n "$DEBUG" ]] && echo "[$(date +%H:%M:%S.%3N)] $*" >&2
}

# Get current timestamp in milliseconds
now_ms() {
    echo $(($(date +%s%N) / 1000000))
}

# Calculate desktop from workspace ID
# WS 1-5   = Desktop 1-5 (monitor index 0)
# WS 6-10  = Desktop 1-5 (monitor index 1)
# WS 11-15 = Desktop 1-5 (monitor index 2)
ws_to_desktop() {
    local ws=$1
    echo $(( ((ws - 1) % 5) + 1 ))
}

# Get expected desktop from state file
get_expected_desktop() {
    [[ -f "$STATE_FILE" ]] && cat "$STATE_FILE" || echo "1"
}

# Check if monitors are out of sync and need correction
# Returns the desktop we should switch to, or empty if in sync
check_desync() {
    local expected=$(get_expected_desktop)
    local out_of_sync=""
    
    # Get all monitor workspaces
    while IFS= read -r ws; do
        local desktop=$(ws_to_desktop "$ws")
        if [[ "$desktop" != "$expected" ]]; then
            out_of_sync="$desktop"
            break
        fi
    done < <(hyprctl monitors -j | jq -r '.[].activeWorkspace.id')
    
    echo "$out_of_sync"
}

# Sync all monitors to the given desktop
sync_to_desktop() {
    local desktop=$1
    log "Syncing all monitors to desktop $desktop"
    "$SCRIPT_DIR/virtual-desktop.sh" "$desktop" switch
}

# Handle incoming events
handle_event() {
    local event="$1"
    local current_time=$(now_ms)
    
    case "$event" in
        workspace\>\>*|workspacev2\>\>*)
            # User-initiated workspace change via keybind
            # Record this so we know NOT to sync on the following activewindow event
            LAST_WS_EVENT_TIME=$current_time
            log "User workspace event at $current_time: $event"
            ;;
            
        activewindow\>\>*|activewindowv2\>\>*)
            # Window activation occurred
            # Check if this was preceded by a workspace event (user action)
            local time_since_ws=$((current_time - LAST_WS_EVENT_TIME))
            
            if [[ $time_since_ws -lt $EVENT_WINDOW_MS ]]; then
                # Recent workspace event - this is a user-initiated switch, don't interfere
                log "Ignoring activewindow (user action, ${time_since_ws}ms after workspace event)"
                return
            fi
            
            # No recent workspace event - this might be an external activation
            # Small delay to let Hyprland finish any workspace transitions
            sleep 0.03
            
            local target_desktop
            target_desktop=$(check_desync)
            
            if [[ -n "$target_desktop" ]]; then
                log "External activation detected! Desync found, syncing to desktop $target_desktop"
                sync_to_desktop "$target_desktop"
            fi
            ;;
    esac
}

# Verify socket exists
if [[ ! -S "$SOCKET" ]]; then
    echo "Error: Hyprland socket not found at $SOCKET" >&2
    exit 1
fi

log "Starting virtual-desktop-sync daemon (PID $$)"
log "Listening on $SOCKET"

# Main event loop
socat -U - "UNIX-CONNECT:$SOCKET" 2>/dev/null | while IFS= read -r line; do
    handle_event "$line"
done

log "Event loop ended, exiting"
