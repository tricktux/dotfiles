#!/usr/bin/env bash

[ ! -f "$HOME/.local/bin/fast" ] && echo "install fast" && exit 1
[ ! -f "/usr/bin/jq" ] && echo "install jq" && exit 2

HOST=1.1.1.1
json_file="/tmp/fast.json"

if ! [ -f "$json_file" ]; then
  fast --json > "$json_file"
fi

if ! json=$(cat "$json_file" 2> /dev/null); then
  rtt="--"
  icon="%{F#d60606}%{F-}"
else
    rtt=$(echo "$json" | jq -r '.latency')
    down=$(echo "$json" | jq -r '.downloadSpeed')
    out="$rtt ms  $down Mbit/s"

  if [ "$rtt" -lt 50 ]; then
    icon="%{F#3cb703}%{F-}"
  elif [ "$rtt" -lt 150 ]; then
    icon="%{F#f9dd04}%{F-}"
  else
    icon="%{F#d60606}%{F-}"
  fi
fi

echo "$icon $out"
