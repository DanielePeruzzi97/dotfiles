#!/bin/bash
# AWS Profile selector for waybar

# Get available profiles
profiles=$(aws configure list-profiles 2>/dev/null)

if [ -z "$profiles" ]; then
    notify-send "AWS Config" "No AWS profiles found. Run 'aws configure' first."
    exit 0
fi

# Create rofi menu
selected_profile=$(echo -e "$profiles" | rofi -dmenu -p "Select AWS Profile:" -theme-str 'window {width: 300px;}')

if [ -n "$selected_profile" ]; then
    # Export profile for current session
    export AWS_PROFILE="$selected_profile"
    
    # Update shell configs to persist
    echo "export AWS_PROFILE=\"$selected_profile\"" > ~/.aws_profile
    
    # Source in current shells
    echo "export AWS_PROFILE=\"$selected_profile\"" | tee -a ~/.bashrc ~/.zshrc > /dev/null
    
    # Get region for notification
    region=$(aws configure get region --profile "$selected_profile" 2>/dev/null || echo "default region")
    
    notify-send "AWS Profile" "Switched to: $selected_profile ($region)"
    
    # Trigger waybar refresh
    pkill -RTMIN+8 waybar
fi