#!/bin/bash
# Screenshot menu using rofi, grim, slurp, satty

# Source user environment for keybind execution
source ~/.zshrc 2>/dev/null || source ~/.bashrc 2>/dev/null

SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOTS_DIR"

# Generate filename with timestamp
FILENAME="$SCREENSHOTS_DIR/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

options="󰍹 Full Screen\n󰩭 Select Area (Edit)\n󰖯 Active Window"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Screenshot" -theme-str 'window {width: 300px;}')

case "$chosen" in
    "󰍹 Full Screen")
        grim "$FILENAME" && notify-send "Screenshot saved" "$FILENAME"
        ;;
    "󰩭 Select Area (Edit)")
        slurp | grim -g - - | satty -f - -o "$FILENAME"
        ;;
    "󰖯 Active Window")
        grimblast --notify copysave active "$FILENAME"
        ;;
esac
