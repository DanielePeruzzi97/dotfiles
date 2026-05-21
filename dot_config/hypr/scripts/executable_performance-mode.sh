#!/bin/bash
# Toggle between performance mode (zero effects) and normal mode
# Performance mode: no animations, no blur, no shadows, no rounding
# Useful for screen sharing, presentations, or low-power situations

STATE_FILE="/tmp/hypr-performance-mode"

toggle_performance() {
    if [[ -f "$STATE_FILE" ]]; then
        # Currently in performance mode - restore normal
        hyprctl --batch "\
            keyword animations:enabled true ; \
            keyword decoration:blur:enabled false ; \
            keyword decoration:shadow:enabled false ; \
            keyword decoration:rounding 8 ; \
            keyword misc:vfr true"
        rm -f "$STATE_FILE"
        notify-send -t 2000 "Hyprland" "Normal mode (minimal animations)"
    else
        # Enable performance mode - zero effects
        hyprctl --batch "\
            keyword animations:enabled false ; \
            keyword decoration:blur:enabled false ; \
            keyword decoration:shadow:enabled false ; \
            keyword decoration:rounding 0 ; \
            keyword misc:vfr true"
        touch "$STATE_FILE"
        notify-send -t 2000 "Hyprland" "Performance mode (zero effects)"
    fi
}

case "${1:-toggle}" in
    toggle)
        toggle_performance
        ;;
    on)
        hyprctl --batch "\
            keyword animations:enabled false ; \
            keyword decoration:blur:enabled false ; \
            keyword decoration:shadow:enabled false ; \
            keyword decoration:rounding 0 ; \
            keyword misc:vfr true"
        touch "$STATE_FILE"
        notify-send -t 2000 "Hyprland" "Performance mode (zero effects)"
        ;;
    off)
        hyprctl --batch "\
            keyword animations:enabled true ; \
            keyword decoration:blur:enabled false ; \
            keyword decoration:shadow:enabled false ; \
            keyword decoration:rounding 8 ; \
            keyword misc:vfr true"
        rm -f "$STATE_FILE"
        notify-send -t 2000 "Hyprland" "Normal mode (minimal animations)"
        ;;
    status)
        if [[ -f "$STATE_FILE" ]]; then
            echo "performance"
        else
            echo "normal"
        fi
        ;;
esac
