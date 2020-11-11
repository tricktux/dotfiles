#!/usr/bin/env sh

machine=$(hostname)

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do
  # Terminate already running bar instances
  killall -q polybar
  sleep 0.001
done

# Sun Mar 17 2019 15:06
# Do not enable --reload. Consumes power
polybar top-$machine &
polybar bottom-$machine &
