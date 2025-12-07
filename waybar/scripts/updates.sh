#!/bin/bash

# Check for updates using checkupdates (from pacman-contrib)
# Redirect errors to /dev/null to avoid garbage output
updates=$(checkupdates 2>/dev/null | wc -l)

# If checkupdates fails or returns nothing, assume 0 or handle error
if [ -z "$updates" ]; then
    updates=0
fi

# Output JSON for Waybar
if [ "$updates" -gt 0 ]; then
    # Show icon and count if updates exist
    echo "{\"text\":\" $updates\",\"tooltip\":\"$updates updates available\\nClick to upgrade\",\"class\":\"updates\"}"
else
    # Return empty text to hide the module when up to date
    echo "{\"text\":\"\",\"tooltip\":\"System is up to date\",\"class\":\"\"}"
fi