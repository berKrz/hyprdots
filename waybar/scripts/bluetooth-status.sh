#!/bin/bash

# Check if Bluetooth is powered on
powered=$(bluetoothctl show | grep "Powered: yes")

if [ -z "$powered" ]; then
    echo "{\"text\":\"󰂲\",\"tooltip\":\"Bluetooth Off\",\"class\":\"off\"}"
    exit 0
fi

# Get connected devices
connected_devices=$(bluetoothctl devices | cut -d' ' -f2- | while read -r line; do
    mac=$(echo "$line" | awk '{print $1}')
    name=$(echo "$line" | cut -d' ' -f2-)
    
    if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
        # Try to get battery level
        battery=$(bluetoothctl info "$mac" | grep "Battery Percentage" | awk '{print $4}' | tr -d '()')
        
        if [ -n "$battery" ]; then
            echo "$name: $battery%"
        else
            echo "$name"
        fi
    fi
done)

if [ -z "$connected_devices" ]; then
    echo "{\"text\":\"󰂯\",\"tooltip\":\"Bluetooth On - No devices connected\",\"class\":\"on\"}"
else
    # Count connected devices
    device_count=$(echo "$connected_devices" | wc -l)
    
    # Build tooltip
    tooltip="Connected Devices:\\n$connected_devices"
    
    echo "{\"text\":\"󰂱 $device_count\",\"tooltip\":\"$tooltip\",\"class\":\"connected\"}"
fi