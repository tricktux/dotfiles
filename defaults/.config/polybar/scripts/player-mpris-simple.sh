#!/usr/bin/env bash

player_status=$(playerctl status 2> /dev/null)

if [ "$player_status" = "Playing" ]; then
    echo " $(playerctl --no-messages metadata artist) - $(playerctl --no-messages metadata title)"
elif [ "$player_status" = "Paused" ]; then
    echo " $(playerctl --no-messages metadata artist) - $(playerctl --no-messages metadata title)"
# else
    # echo "#3"
fi
