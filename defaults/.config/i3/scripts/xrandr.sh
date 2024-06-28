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

if [[ "$hostname" = "surbook" ]]; then
    echo "found surbook"
    case "$1" in
        "main")
            echo "setting up main configuration"
            xrandr \
                --dpi 192 \
                --output eDP1 --mode 2736x1824 --rate 60 --pos 0x0 --primary \
                --output DP1 --off \
                --output HDMI1 --off \
                --output HDMI2 --off \
                --output VIRTUAL1 --off

            echo "Xft.dpi: 192" | xrdb -merge
            ;;
        "tv")
            echo "setting up tv configuration"
            xrandr \
                --dpi 96 \
                --output eDP1 --off \
                --output DP1 --mode "1920x1080tv" --rate 60 --pos 0x0 --primary \
                --output HDMI1 --off \
                --output HDMI2 --off \
                --output VIRTUAL1 --off
            echo "Xft.dpi: 96" | xrdb -merge
            ;;
        *)
            notify-send "xrandr" \
                "Configuration '$1' not valid" \
                -u critical -a 'Arandr'
            exit 2
            ;;
    esac
elif [[ "$hostname" = "aero" ]]; then
    echo "found aero"
    case "$1" in
        "main")
            echo "setting up main configuration"
            # "$HOME"/.config/xprofile_aero
            # for socket in /tmp/kittysocket*; do
            #     kitty @ --to unix:$socket set-font-size --all 9
            # done
            xset_on
            ;;
        "tv")
            echo "setting up tv configuration"
            xrandr \
                --dpi 96 \
                --output eDP --off \
                --output HDMI-A-0 --off \
                --output DisplayPort-0 --mode 3840x2160 --rate 30 --pos 0x0 --primary

            echo "Xft.dpi: 96" | xrdb -merge
            ;;
        "home")
            echo "setting up home_dock configuration"
            "$HOME"/.screenlayout/home.sh
            xrandr --dpi 156
            echo "Xft.dpi: 156" | xrdb -merge
            # for socket in /tmp/kittysocket*; do
                # kitty @ --to unix:$socket set-font-size --all 10
            # done
            xset_off
            ;;
        *)
            notify-send "xrandr" \
                "Configuration '$1' not valid" \
                -u critical -a 'Arandr'
            exit 2
            ;;
    esac
elif [[ "$hostname" = "predator" ]]; then
    echo "found predator"
    case "$1" in
        "main")
            echo "setting up main configuration"
            # "$HOME"/.screenlayout/main.sh
            echo "Xft.dpi: 156" | xrdb -merge
            ;;
        *)
            notify-send "xrandr" \
                "Configuration '$1' not valid" \
                -u critical -a 'Arandr'
            exit 2
            ;;
    esac
elif [[ "$hostname" = "helios" ]]; then
    echo "found helios"
    case "$1" in
        "main")
            echo "setting up main configuration"
            xrandr \
                --dpi 144 \
                --output eDP1 --mode 1920x1080 --rate 144 --pos 0x0 --primary \
                --output VIRTUAL1 --off
            echo "Xft.dpi: 144" | xrdb -merge
            ;;
        *)
            notify-send "xrandr" \
                "Configuration '$1' not valid" \
                -u critical -a 'Arandr'
            exit 2
            ;;
    esac
elif [[ "$hostname" = "xps" ]]; then
    echo "found xps"
    case "$1" in
        "main")
            echo "  setting up main configuration"
            # "$HOME"/.screenlayout/main.sh
            xrandr --dpi 156
            echo "Xft.dpi: 192" | xrdb -merge
            xset_on
            ;;
        "home")
            echo "  setting up home_dock configuration"
            # "$HOME"/.screenlayout/home-dock.sh
            xrandr --dpi 156
            echo "Xft.dpi: 156" | xrdb -merge
            xset_off
            ;;
        "work")
            echo "  setting up work_dock configuration"
            # "$HOME"/.screenlayout/work-dock.sh
            xrandr --dpi 156
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
fi

# Restart i3/polybar
i3-msg restart
"$HOME/.config/i3/scripts/i3-workspace-output"
"$HOME/.config/i3/scripts/xset.sh"
polybar-msg cmd restart
notify-send "xrandr" "Configuration '$1' set!" -a 'arandr'
exit 0
