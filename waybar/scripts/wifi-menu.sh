#!/bin/bash

# Get a list of available wifi networks
# Fields: BARS, SSID
list=$(nmcli --fields "BARS,SSID" device wifi list | sed '/^--/d')

# Use wofi to select a network
chosen_network=$(echo -e "$list" | uniq -u | wofi --dmenu --insensitive --lines 15)

# If a network was selected
if [ -n "$chosen_network" ]; then
    # Extract the SSID
    # Remove the signal bars (first non-space sequence) and trim leading spaces
    ssid=$(echo "$chosen_network" | sed 's/^[^ ]* *//;s/ *$//')
    
    # Unique Tag so we replace the "Connecting..." notification later
    NOTIF_TAG="wifi-connection"

    # Notify user: Connecting...
    notify-send -h string:x-canonical-private-synchronous:$NOTIF_TAG \
        -i network-wireless-acquiring \
        "Wi-Fi" "Connecting to <b>$ssid</b>..."
    
    # Try to connect and capture output
    # We capture both stdout and stderr to variable 'output'
    if output=$(nmcli device wifi connect "$ssid" 2>&1); then
        # SUCCESS
        notify-send -h string:x-canonical-private-synchronous:$NOTIF_TAG \
            -i network-wireless \
            "Wi-Fi" "Connected to <b>$ssid</b>"
    else
        # FAILURE
        # Check if it was a password error or something else
        if echo "$output" | grep -q "Secrets were required"; then
            msg="Authentication failed or cancelled"
        else
            msg="Connection failed"
        fi

        notify-send -h string:x-canonical-private-synchronous:$NOTIF_TAG \
            -u critical \
            -i network-wireless-offline \
            "Wi-Fi Error" "Failed to connect to <b>$ssid</b>\n<i>$msg</i>"
    fi
fi