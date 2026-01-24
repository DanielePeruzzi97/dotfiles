#!/bin/bash
# Screenshot menu using rofi and grimblast

SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOTS_DIR"

# Generate filename with timestamp
FILENAME="$SCREENSHOTS_DIR/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

options="󰍹 Full Screen\n󰩭 Select Area\n󰖯 Active Window"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Screenshot" -theme-str 'window {width: 300px;}')

case "$chosen" in
    "󰍹 Full Screen")
        grimblast --notify copysave screen "$FILENAME"
        ;;
    "󰩭 Select Area")
        grimblast --notify copysave area "$FILENAME"
        ;;
    "󰖯 Active Window")
        grimblast --notify copysave active "$FILENAME"
        ;;
esac
