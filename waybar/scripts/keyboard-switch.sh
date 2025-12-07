#!/bin/bash

# --- DEBOUNCE MECHANISM ---
# Prevent the script from running more than once every 1 second.
# This fixes the "double switch" issue caused by input bouncing or rapid execution.
LOCK_FILE="/tmp/keyboard_switch.lock"
if [ -f "$LOCK_FILE" ]; then
    last_run=$(stat -c %Y "$LOCK_FILE")
    now=$(date +%s)
    elapsed=$((now - last_run))
    
    # If less than 1 second has passed, exit
    if [ "$elapsed" -lt 1 ]; then
        exit 0
    fi
fi
touch "$LOCK_FILE"
# --------------------------

# 1. Switch layout for ALL available keyboards
# We loop through all devices to keep them in sync (Laptop + USB keyboards, etc.)
hyprctl devices -j | jq -r '.keyboards[].name' | while read -r name; do
    hyprctl switchxkblayout "$name" next
done

# 2. Get the new layout from the main keyboard for notification
# We use a clean jq query to ensure valid output
current_layout=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap' | head -1)

# Fallback if no main keyboard found
if [ -z "$current_layout" ]; then
    current_layout=$(hyprctl devices -j | jq -r '.keyboards[0].active_keymap')
fi

# 3. Format notification message
case "$current_layout" in
    *"English (US)"* | *"English"* | *"US"*)
        display="🇺🇸 English (US)"
        ;;
    *"Portuguese (Brazil)"* | *"Portuguese"* | *"Brazil"* | *"br"*)
        display="🇧🇷 Portuguese (Brazil) - ABNT2"
        ;;
    *)
        display="$current_layout"
        ;;
esac

# 4. Send notification
notify-send -u low -t 2000 \
    -i input-keyboard \
    -h string:x-canonical-private-synchronous:keyboard-layout \
    -h int:transient:1 \
    "Keyboard Layout" "Active: <b>$display</b>"

# 5. Force waybar update
pkill -RTMIN+9 waybar