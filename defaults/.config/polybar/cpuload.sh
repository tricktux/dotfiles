#!/usr/bin/env bash

# Note: Taken from here:
# https://github.com/jaagr/polybar/wiki/User-contributed-modules#cpu-load

uptime | grep -ohe 'load average[s:][: ].*' | sed 's/,//g' | awk '{print $3" "$4" "$5}'
