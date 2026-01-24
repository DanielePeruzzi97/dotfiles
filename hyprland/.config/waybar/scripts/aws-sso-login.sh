#!/bin/bash
# AWS SSO login script for waybar

# Get current AWS profile
current_profile=$(aws configure list-profiles 2>/dev/null | head -1)
if [ -n "$AWS_PROFILE" ]; then
    current_profile="$AWS_PROFILE"
fi

if [ -z "$current_profile" ] || [ "$current_profile" = "none" ]; then
    # If no profile, show profile selector first
    profiles=$(aws configure list-profiles 2>/dev/null)
    
    if [ -z "$profiles" ]; then
        notify-send "AWS Config" "No AWS profiles found. Run 'aws configure sso' first."
        exit 0
    fi

    # Select profile for SSO login
    selected_profile=$(echo -e "$profiles" | rofi -dmenu -p "Select AWS Profile for SSO:" -theme-str 'window {width: 350px;}')
    
    if [ -n "$selected_profile" ]; then
        current_profile="$selected_profile"
        export AWS_PROFILE="$selected_profile"
        echo "export AWS_PROFILE=\"$selected_profile\"" > ~/.aws_profile
    else
        exit 0
    fi
fi

# Launch AWS SSO login in terminal
notify-send "AWS SSO" "Starting SSO login for profile: $current_profile"

# Open terminal with AWS SSO login
ghostty -e bash -c "
    echo 'Starting AWS SSO login for profile: $current_profile'
    export AWS_PROFILE='$current_profile'
    aws sso login --profile '$current_profile'
    
    if [ \$? -eq 0 ]; then
        echo ''
        echo '✅ SSO login successful!'
        echo 'Profile: $current_profile'
        echo 'Region:' \$(aws configure get region --profile '$current_profile' 2>/dev/null || echo 'default')
        echo ''
        echo 'Press Enter to close...'
    else
        echo ''
        echo '❌ SSO login failed!'
        echo 'Press Enter to close...'
    fi
    read
"

# Trigger waybar refresh after login
sleep 2
pkill -RTMIN+8 waybar