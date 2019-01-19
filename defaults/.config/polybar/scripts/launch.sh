#!/usr/bin/env sh

machine=`hostname`
# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

polybar --reload top-$machine&
polybar --reload bottom-$machine&
