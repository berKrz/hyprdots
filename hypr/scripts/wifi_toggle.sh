#!/bin/bash

# Tag ensures the notification replaces itself instantly if you toggle rapidly
TAG="airplane-mode-toggle"

wifi_status=$(nmcli radio wifi)

if [ "$wifi_status" == "enabled" ]; then
    # --- ENABLING AIRPLANE MODE ---
    nmcli radio wifi off
    bluetoothctl power off
    
    notify-send \
        -h string:x-canonical-private-synchronous:$TAG \
        -h int:transient:1 \
        -i airplane-mode \
        "Airplane Mode" "<b>Enabled</b> 󰀝\n<i>Wi-Fi & Bluetooth disabled</i>"
else
    # --- DISABLING AIRPLANE MODE ---
    nmcli radio wifi on
    bluetoothctl power on
    
    notify-send \
        -h string:x-canonical-private-synchronous:$TAG \
        -h int:transient:1 \
        -i network-wireless-acquiring \
        "Airplane Mode" "<b>Disabled</b>\n<i>Restoring connections...</i>"
fi