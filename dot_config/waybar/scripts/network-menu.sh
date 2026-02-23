#!/bin/bash
# Network menu using rofi and nmcli

# Get current connection
current=$(nmcli -t -f NAME connection show --active | head -1)

# Options
options="󰤨 WiFi Networks\n󰈀 Ethernet\n󰖟 Connection Editor\n󰤭 Disconnect"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Network" -theme-str 'window {width: 300px;}')

case "$chosen" in
    "󰤨 WiFi Networks")
        # Scan and show WiFi networks
        nmcli device wifi rescan 2>/dev/null
        wifi_list=$(nmcli -t -f SSID,SIGNAL,SECURITY device wifi list | grep -v "^--" | sort -t: -k2 -nr | head -15)
        
        if [ -z "$wifi_list" ]; then
            notify-send "WiFi" "No networks found"
            exit 0
        fi
        
        # Format for rofi
        formatted=""
        while IFS=: read -r ssid signal security; do
            [ -z "$ssid" ] && continue
            if [ -n "$security" ]; then
                formatted+="󰤨 $ssid ($signal%) 󰌾\n"
            else
                formatted+="󰤨 $ssid ($signal%)\n"
            fi
        done <<< "$wifi_list"
        
        selected=$(echo -e "$formatted" | rofi -dmenu -i -p "WiFi" -theme-str 'window {width: 400px;}')
        
        if [ -n "$selected" ]; then
            # Extract SSID
            ssid=$(echo "$selected" | sed 's/󰤨 //' | sed 's/ ([0-9]*%).*//')
            
            # Check if already saved
            if nmcli -t -f NAME connection show | grep -q "^$ssid$"; then
                nmcli connection up "$ssid" && notify-send "WiFi" "Connected to $ssid"
            else
                # Need password
                password=$(rofi -dmenu -p "Password for $ssid" -password -theme-str 'window {width: 400px;}')
                if [ -n "$password" ]; then
                    nmcli device wifi connect "$ssid" password "$password" && notify-send "WiFi" "Connected to $ssid"
                fi
            fi
        fi
        ;;
    "󰈀 Ethernet")
        # Show ethernet connections
        eth_list=$(nmcli -t -f NAME,TYPE connection show | grep ethernet | cut -d: -f1)
        if [ -z "$eth_list" ]; then
            notify-send "Ethernet" "No ethernet connections configured"
            exit 0
        fi
        selected=$(echo "$eth_list" | rofi -dmenu -i -p "Ethernet")
        if [ -n "$selected" ]; then
            nmcli connection up "$selected" && notify-send "Network" "Connected to $selected"
        fi
        ;;
    "󰖟 Connection Editor")
        nm-connection-editor &
        ;;
    "󰤭 Disconnect")
        nmcli device disconnect wlan0 2>/dev/null
        nmcli device disconnect eth0 2>/dev/null
        notify-send "Network" "Disconnected"
        ;;
esac
