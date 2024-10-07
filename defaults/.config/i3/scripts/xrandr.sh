#!/usr/bin/env bash

hostname=$HOSTNAME

function xset_off() {
    xset s off
    xset -dpms
}

function xset_on() {
    xset s on
    xset +dpms
}

if [[ ! -x $(command -v xrandr) ]]; then
    notify-send "xrandr" \
        "xrandr program not available" \
        -u critical -a 'Arandr'
    exit 1
fi

if [[ ! -x "$HOME"/.screenlayout/$1 ]]; then
    notify-send "xrandr" \
        ".screenlayout script for $1 invalid" \
        -u critical -a 'Arandr'
    exit 3
fi

"$HOME"/.screenlayout/$1

case "$1" in
    "tv-living-room")
        echo "  setting up $1 configuration"
        echo "Xft.dpi: 288" | xrdb -merge
        xset_on
        ;;
    "main")
        echo "  setting up $1 configuration"
        xrdb ~/.Xresources
        xset_on
        ;;
    "home")
        echo "  setting up $1 configuration"
        echo "Xft.dpi: 156" | xrdb -merge
        xset_off
        ;;
    "work")
        echo "  setting up $1 configuration"
        echo "Xft.dpi: 156" | xrdb -merge
        xset_off
        ;;
    *)
        notify-send "xrandr" \
            "Configuration '$1' not valid" \
            -u critical -a 'Arandr'
        exit 2
        ;;
esac

# Restart i3/polybar
i3-msg restart
"$HOME/.config/i3/scripts/i3-workspace-output"
"$HOME/.config/i3/scripts/xset.sh"
polybar-msg cmd restart
notify-send "xrandr" "Configuration '$1' set!" -a 'arandr'
exit 0
