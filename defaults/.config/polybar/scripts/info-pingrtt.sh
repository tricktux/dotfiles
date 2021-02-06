#!/bin/sh

HOST=1.1.1.1

if ! ping=$(speedtest --simple); then
    rtt="--"
    icon="%{F#d60606}%{F-}"
else
    rtt=$(echo "$ping" | sed -rn 's/.*Ping: ([0-9]{1,})\.?[0-9]{0,} ms.*/\1/p')
    down=$(echo "$ping" | sed -rn 's/.*Download: ([0-9]{1,})\.?[0-9]{0,} Mbit\/s.*/\1/p')
    up=$(echo "$ping" | sed -rn 's/.*Upload: ([0-9]{1,})\.?[0-9]{0,} Mbit\/s.*/\1/p')
    out="$rtt ms $down Mbit/s $up Mbit/s"

    if [ "$rtt" -lt 50 ]; then
        icon="%{F#3cb703}%{F-}"
    elif [ "$rtt" -lt 150 ]; then
        icon="%{F#f9dd04}%{F-}"
    else
        icon="%{F#d60606}%{F-}"
    fi
fi
echo "$icon $out"
