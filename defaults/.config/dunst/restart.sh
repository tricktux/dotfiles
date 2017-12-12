#!/usr/bin/env sh
killall -q dunst

# Wait until the processes have been shut down
while pgrep -x dunst >/dev/null; do sleep 1; done
dunst&
notify-send "Working...."


