#!/bin/bash
# ~/.config/waybar/scripts/vpn-status.sh
# Returns VPN status for waybar custom module

# Check NordVPN first (if installed)
if command -v nordvpn &> /dev/null; then
    status=$(nordvpn status 2>/dev/null)
    if echo "$status" | grep -q "Connected"; then
        server=$(echo "$status" | grep "Server:" | awk '{print $2}' | cut -d'.' -f1)
        city=$(echo "$status" | grep "City:" | awk '{print $2}')
        echo "{\"text\": \"�shields $city\", \"tooltip\": \"NordVPN: $server\n$city\", \"class\": \"connected\"}"
        exit 0
    fi
fi

# Check OpenVPN via NetworkManager
active_vpn=$(nmcli -t -f NAME,TYPE con show --active 2>/dev/null | grep ":vpn" | cut -d':' -f1)
if [ -n "$active_vpn" ]; then
    echo "{\"text\": \"󰖂 $active_vpn\", \"tooltip\": \"OpenVPN: $active_vpn\", \"class\": \"connected\"}"
    exit 0
fi

# Check WireGuard via NetworkManager
active_wg=$(nmcli -t -f NAME,TYPE con show --active 2>/dev/null | grep ":wireguard" | cut -d':' -f1)
if [ -n "$active_wg" ]; then
    echo "{\"text\": \"󱅎 $active_wg\", \"tooltip\": \"WireGuard: $active_wg\", \"class\": \"connected\"}"
    exit 0
fi

# No VPN connected
echo "{\"text\": \"󰦞\", \"tooltip\": \"VPN: Disconnected\", \"class\": \"disconnected\"}"
