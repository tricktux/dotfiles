#!/usr/bin/env sh

machine=`hostname`
# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# Launch bar1 and bar2
if [[ $machine = "predator" || $machine = "predator" ]]; then
	polybar --reload surbar&
else
	polybar --reload archbar&
fi

polybar --reload bottom-$machine&
