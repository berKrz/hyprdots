#!/bin/bash

# Check if power-profiles-daemon is available
if ! command -v powerprofilesctl &> /dev/null; then
    notify-send "Power Profiles" "power-profiles-daemon not installed"
    exit 1
fi

# Get current profile
current_profile=$(powerprofilesctl get)

# Build menu with all profiles
menu=""

# Check available profiles
available_profiles=$(powerprofilesctl list | grep -oP '^\w+(?=:)')

while IFS= read -r profile; do
    case "$profile" in
        "performance")
            icon="⚡"
            desc="Performance - Maximum performance"
            ;;
        "balanced")
            icon="⚖️"
            desc="Balanced - Default performance"
            ;;
        "power-saver")
            icon="🔋"
            desc="Power Saver - Maximum battery life"
            ;;
        *)
            icon="❓"
            desc="$profile"
            ;;
    esac
    
    if [ "$profile" = "$current_profile" ]; then
        menu="$menu$icon ✓ $desc\n"
    else
        menu="$menu$icon   $desc\n"
    fi
done <<< "$available_profiles"

# Show menu with wofi
# Changed: rofi -> wofi, removed prompt to be cleaner
selected=$(echo -e "$menu" | wofi --dmenu --insensitive --lines 5)

if [ -z "$selected" ]; then
    exit 0
fi

# Extract profile name from selection
if echo "$selected" | grep -q "Performance"; then
    new_profile="performance"
elif echo "$selected" | grep -q "Balanced"; then
    new_profile="balanced"
elif echo "$selected" | grep -q "Power Saver"; then
    new_profile="power-saver"
else
    exit 0
fi

# Set new profile
powerprofilesctl set "$new_profile"

# Send notification
case "$new_profile" in
    "performance")
        notify-send "Power Profile" "Switched to Performance mode ⚡"
        ;;
    "balanced")
        notify-send "Power Profile" "Switched to Balanced mode ⚖️"
        ;;
    "power-saver")
        notify-send "Power Profile" "Switched to Power Saver mode 🔋"
        ;;
esac

# Force waybar update
pkill -RTMIN+8 waybar