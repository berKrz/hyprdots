#!/bin/bash

layout=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap' | head -1)

if [ -z "$layout" ]; then
    layout=$(hyprctl devices -j | jq -r '.keyboards[0].active_keymap')
fi

case "$layout" in
    *"English (US)"* | *"English"* | *"US"*)
        short="US"
        full="English (US)"
        ;;
    *"Portuguese (Brazil)"* | *"Portuguese"* | *"Brazil"* | *"br"*)
        short="BR"
        full="Portuguese (Brazil) - ABNT2"
        ;;
    *)
        short="??"
        full="$layout"
        ;;
esac

tooltip="$full"

echo "{\"text\":\"  $short\",\"tooltip\":\"$tooltip\",\"class\":\"keyboard\"}"