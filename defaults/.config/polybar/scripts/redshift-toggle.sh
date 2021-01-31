#!/bin/sh

if pgrep -x "redshift" >/dev/null; then
  killall redshift
else
  redshift -c ~/.config/redshift.conf &
fi
