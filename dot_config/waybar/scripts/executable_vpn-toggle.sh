#!/bin/bash
# ~/.config/waybar/scripts/vpn-toggle.sh
# Toggle VPN connection via rofi menu, reordered and clearer

# Build menu options
options=""

# Get all VPN connections and their types
vpn_pairs=$(nmcli -t -f NAME,TYPE con show | grep ":vpn\|:wireguard")

# Separate lists for WireGuard, OpenVPN, other
wireguard_vpns=()
openvpn_vpns=()
other_vpns=()

while IFS= read -r line; do
    name="${line%%:*}"
    type="${line##*:}"
    if [[ "$type" == "wireguard" ]]; then
        wireguard_vpns+=("$name")
    elif [[ "$type" == "vpn" ]]; then # OpenVPN and generic VPN
        openvpn_vpns+=("$name")
    else
        other_vpns+=("$name")
    fi
done <<< "$vpn_pairs"

# Get active connections set
active_vpn_set=()
while IFS= read -r line; do
    active_vpn_set+=("${line%%:*}")
done < <(nmcli -t -f NAME,TYPE con show --active | grep ":vpn\|:wireguard")

# Helper to check if a VPN is active
is_active() {
    local c="$1"
    for avpn in "${active_vpn_set[@]}"; do
        [[ "$avpn" == "$c" ]] && return 0
    done
    return 1
}

# Build Disconnect (active) buttons first (WireGuard, OpenVPN, then Other)
for conn in "${wireguard_vpns[@]}"; do
    if is_active "$conn"; then
        options+="󰿇 Disconnect $conn\n"
    fi
done
for conn in "${openvpn_vpns[@]}"; do
    if is_active "$conn"; then
        options+="󰿇 Disconnect $conn\n"
    fi
done
for conn in "${other_vpns[@]}"; do
    if is_active "$conn"; then
        options+="󰿇 Disconnect $conn\n"
    fi
done

# Then Connect (inactive) WireGuard first, then OpenVPN, then Other
for conn in "${wireguard_vpns[@]}"; do
    if ! is_active "$conn"; then
        options+="󰖂 Connect $conn\n"
    fi
done
for conn in "${openvpn_vpns[@]}"; do
    if ! is_active "$conn"; then
        options+="󰖂 Connect $conn\n"
    fi
done
for conn in "${other_vpns[@]}"; do
    if ! is_active "$conn"; then
        options+="󰖂 Connect $conn\n"
    fi
done

# NordVPN options (if installed)
if command -v nordvpn &> /dev/null; then
    nordvpn_status=$(nordvpn status 2>/dev/null)
    if echo "$nordvpn_status" | grep -q "Connected"; then
        options+="󰿇 Disconnect NordVPN\n"
    else
        options+="󰌾 NordVPN Quick Connect\n"
        options+="󰌾 NordVPN (US)\n"
        options+="󰌾 NordVPN (UK)\n"
        options+="󰌾 NordVPN (DE)\n"
        options+="󰌾 NordVPN (NL)\n"
    fi
fi

# Add option to open nm-connection-editor, always at the bottom
options+="󰒓 Manage VPN Connections\n"
options+="󰈔 Import VPN from file (.ovpn)"

# Show rofi menu
choice=$(echo -e "$options" | rofi -dmenu -p "VPN" -i)

case "$choice" in
    "󰿇 Disconnect NordVPN")
        nordvpn disconnect
        notify-send "NordVPN" "Disconnected"
        ;;
    "󰌾 NordVPN Quick Connect")
        nordvpn connect && notify-send "NordVPN" "Connected"
        ;;
    "󰌾 NordVPN (US)")
        nordvpn connect United_States && notify-send "NordVPN" "Connected to US"
        ;;
    "󰌾 NordVPN (UK)")
        nordvpn connect United_Kingdom && notify-send "NordVPN" "Connected to UK"
        ;;
    "󰌾 NordVPN (DE)")
        nordvpn connect Germany && notify-send "NordVPN" "Connected to Germany"
        ;;
    "󰌾 NordVPN (NL)")
        nordvpn connect Netherlands && notify-send "NordVPN" "Connected to Netherlands"
        ;;
    "󰿇 Disconnect "*)
        conn_name="${choice#󰿇 Disconnect }"
        nmcli con down "$conn_name" && notify-send "VPN" "Disconnected from $conn_name"
        ;;
    "󰖂 Connect "*)
        conn_name="${choice#󰖂 Connect }"
        nmcli con up "$conn_name" && notify-send "VPN" "Connected to $conn_name"
        ;;
    "󰒓 Manage VPN Connections")
        nm-connection-editor &
        ;;
    "󰈔 Import VPN from file (.ovpn)")
        # Open file picker to select .ovpn file and import
        file=$(zenity --file-selection --title="Select .ovpn file" --file-filter="OpenVPN files (*.ovpn)|*.ovpn" 2>/dev/null)
        if [ -n "$file" ] && [ -f "$file" ]; then
            nmcli connection import type openvpn file "$file" && \
                notify-send "VPN Import" "Successfully imported $(basename "$file")" || \
                notify-send -u critical "VPN Import" "Failed to import VPN"
        fi
        ;;
esac
