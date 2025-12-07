#!/bin/bash

# 1. Check if Bluetooth is powered on
if ! bluetoothctl show | grep -q "Powered: yes"; then
    if echo "  Enable Bluetooth" | wofi --dmenu --prompt "Bluetooth" | grep -q "Enable"; then
        bluetoothctl power on
    fi
    exit
fi

# 2. Get list of paired devices
menu_options=""
while read -r line; do
    mac=$(echo "$line" | cut -d ' ' -f 2)
    name=$(echo "$line" | cut -d ' ' -f 3-)
    
    if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
        icon=""
    else
        icon=""
    fi
    
    menu_options+="$icon   $name ($mac)\n"
done < <(bluetoothctl devices Paired)

final_menu="󰂭   Disable Bluetooth\n󰂱   Open Blueman\n$menu_options"

# 3. Show Wofi Menu
selected=$(echo -e "$final_menu" | wofi --dmenu --insensitive --lines 10)

# 4. Handle Selection
case "$selected" in
    "󰂭   Disable Bluetooth")
        if bluetoothctl power off; then
            notify-send -u low -i bluetooth-disabled "Bluetooth" "Powered off"
        fi
        ;;
    *"Open Blueman"*)
        nohup blueman-manager >/dev/null 2>&1 &
        ;;
    "")
        exit
        ;;
    *)
        mac=$(echo "$selected" | sed 's/.*(\(.*\))/\1/')
        
        dev_name=$(echo "$selected" | sed 's/^[][[:space:]]*//;s/ ([^)]*)$//')
        
        NOTIF_ID=2593
        
        if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
            notify-send -r $NOTIF_ID -i network-bluetooth "Bluetooth" "Disconnecting from <b>$dev_name</b>..."
            
            if bluetoothctl disconnect "$mac"; then
                notify-send -r $NOTIF_ID -i network-bluetooth "Bluetooth" "Disconnected from <b>$dev_name</b>"
            else
                notify-send -r $NOTIF_ID -u critical -i dialog-error "Bluetooth" "Failed to disconnect <b>$dev_name</b>"
            fi
        else
            notify-send -r $NOTIF_ID -i network-bluetooth "Bluetooth" "Connecting to <b>$dev_name</b>..."
            
            if bluetoothctl connect "$mac"; then
                notify-send -r $NOTIF_ID -i network-bluetooth "Bluetooth" "Connected to <b>$dev_name</b>"
            else
                notify-send -r $NOTIF_ID -u critical -i dialog-error "Bluetooth" "Failed to connect to <b>$dev_name</b>"
            fi
        fi
        ;;
esac