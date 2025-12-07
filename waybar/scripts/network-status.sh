#!/bin/bash

# Get network status
wifi_status=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)
ethernet_status=$(nmcli -t -f device,state dev | grep ethernet | grep connected)

if [ -n "$wifi_status" ]; then
    # Get WiFi signal strength
    signal=$(nmcli -t -f active,signal dev wifi | grep '^yes' | cut -d':' -f2)
    
    # Choose icon based on signal strength
    if [ "$signal" -ge 80 ]; then
        icon="󰣺"  # nf-md-network_strength_4
    elif [ "$signal" -ge 60 ]; then
        icon="󰣸"  # nf-md-network_strength_3
    elif [ "$signal" -ge 40 ]; then
        icon="󰣶"  # nf-md-network_strength_2
    elif [ "$signal" -ge 20 ]; then
        icon="󰣴"  # nf-md-network_strength_1
    else
        icon="󰣼"  # nf-md-network_strength_1 (weak but connected)
    fi
    
    echo "{\"text\":\"$icon $signal%\",\"tooltip\":\"Connected to: $wifi_status\",\"class\":\"connected\"}"
    
elif [ -n "$ethernet_status" ]; then
    # Ethernet is connected, show full strength
    icon="󰣺"  # nf-md-network_strength_4
    echo "{\"text\":\"$icon\",\"tooltip\":\"Ethernet Connected\",\"class\":\"connected\"}"
    
else
    # Disconnected
    icon="󰣾"  # nf-md-network_strength_off
    echo "{\"text\":\"$icon\",\"tooltip\":\"Disconnected\",\"class\":\"disconnected\"}"
fi