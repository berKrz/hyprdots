#!/bin/bash
WIDTH=1599
CLOSE_THRESHOLD=1100 

while true; do
    POS=$(hyprctl cursorpos)
    X=${POS%,*}
    Y=${POS#*,}

    # 1. OPEN logic: 
    # Check if X is at edge AND Y is below the top 65 pixels
    if (( X == WIDTH )) && (( Y > 65 )) && (( Y < 780 )); then
        if timeout 0.1s swaync-client -s | grep -q '"visible": false'; then
            swaync-client -op -sw
        fi
        sleep 0.5

    # 2. CLOSE logic (Moved Left)
    # We keep this simple: if you move left, it closes (regardless of height)
    elif (( X < CLOSE_THRESHOLD )); then
        if timeout 0.1s swaync-client -s | grep -q '"visible": true'; then
            swaync-client -cp
        fi
    fi

    sleep 0.15
done