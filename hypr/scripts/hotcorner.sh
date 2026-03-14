#!/bin/bash
WIDTH=1599
CLOSE_THRESHOLD=1100

is_fullscreen() {
    hyprctl activewindow -j 2>/dev/null | grep -qE '"fullscreen":\s*(true|[1-9])'
}

while true; do
    POS=$(hyprctl cursorpos)
    X=${POS%,*}
    Y=${POS#*, }

    SWAYNC_STATUS=$(timeout 0.1s swaync-client -s 2>/dev/null)

    # 1. OPEN logic: right edge, within Y range, not fullscreen
    if (( X == WIDTH )) && (( Y > 65 )) && (( Y < 780 )); then
        if echo "$SWAYNC_STATUS" | grep -q '"visible": false' && ! is_fullscreen; then
            swaync-client -op -sw
        fi
        sleep 0.5

    # 2. CLOSE logic: moved left
    elif (( X < CLOSE_THRESHOLD )); then
        if echo "$SWAYNC_STATUS" | grep -q '"visible": true'; then
            swaync-client -cp
        fi
    fi

    sleep 0.15
done