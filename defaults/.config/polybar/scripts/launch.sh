#!/usr/bin/env sh

machine=`hostname`
# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# Sun Mar 17 2019 15:06
# Do not enable --reload. Consumes power
polybar top-$machine&
polybar bottom-$machine&
