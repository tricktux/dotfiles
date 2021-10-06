#!/usr/bin/env bash

machine=$(hostname)

# Be nice initially
killall -q polybar
killall -q polybar
killall -q polybar

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do
  # Not so nice signals now
  killall -q -s SIGKILL polybar
  sleep 0.5
done

sleep 1

# Sun Mar 17 2019 15:06
# Do not enable --reload. Consumes power
echo "---" | tee -a /tmp/polybar_top.log /tmp/polybar_bottom.log
polybar "top-$machine" >>/tmp/polybar_top.log 2>&1 & disown
polybar "bottom-$machine" >>/tmp/polybar_bottom.log 2>&1 & disown
