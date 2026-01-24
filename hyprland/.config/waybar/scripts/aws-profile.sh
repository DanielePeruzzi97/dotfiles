#!/bin/bash
# AWS Profile indicator for waybar

# Get current AWS profile
current_profile=$(aws configure list-profiles 2>/dev/null | head -1)
if [ -n "$AWS_PROFILE" ]; then
    current_profile="$AWS_PROFILE"
elif [ -n "$current_profile" ]; then
    current_profile="default"
else
    current_profile="none"
fi

# Get profile region if available
if [ "$current_profile" != "none" ]; then
    region=$(aws configure get region --profile "$current_profile" 2>/dev/null || echo "unknown")
    
    # Create output
    echo "{\"text\": \"󰸅 $current_profile\", \"tooltip\": \"AWS Profile: $current_profile\\nRegion: $region\", \"class\": \"aws-profile\"}"
else
    echo "{\"text\": \"󰸅 none\", \"tooltip\": \"No AWS profile configured\", \"class\": \"aws-profile-none\"}"
fi