#!/bin/bash
# Check for updates on manually installed software
# Returns JSON with count and details for waybar integration

get_manual_updates() {
    local updates=()
    local count=0

    # Bitwarden
    BW_CURRENT=$(dpkg -l bitwarden 2>/dev/null | grep bitwarden | awk '{print $3}')
    BW_LATEST=$(curl -s --max-time 5 https://api.github.com/repos/bitwarden/clients/releases/latest | grep '"tag_name"' | sed -E 's/.*"desktop-v([^"]+)".*/\1/')
    if [[ -n "$BW_CURRENT" && -n "$BW_LATEST" && "$BW_CURRENT" != "$BW_LATEST" ]]; then
        updates+=("Bitwarden: $BW_CURRENT → $BW_LATEST")
        ((count++))
    fi

    # Hyprland (check if PPA is behind upstream)
    HYPR_CURRENT=$(hyprctl version 2>/dev/null | head -1 | awk '{print $2}')
    HYPR_LATEST=$(curl -s --max-time 5 https://api.github.com/repos/hyprwm/Hyprland/releases/latest | grep '"tag_name"' | sed -E 's/.*"v?([^"]+)".*/\1/')
    if [[ -n "$HYPR_CURRENT" && -n "$HYPR_LATEST" && "$HYPR_CURRENT" != "$HYPR_LATEST" ]]; then
        updates+=("Hyprland: $HYPR_CURRENT → $HYPR_LATEST")
        ((count++))
    fi

    # Output
    if [[ $count -gt 0 ]]; then
        printf '%s\n' "${updates[@]}"
    fi
    echo "$count"
}

# When called directly, output details
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    result=$(get_manual_updates)
    count=$(echo "$result" | tail -1)
    details=$(echo "$result" | head -n -1)
    
    if [[ $count -gt 0 ]]; then
        echo "Manual software updates available ($count):"
        echo "$details"
    else
        echo "All manual software is up to date"
    fi
fi
