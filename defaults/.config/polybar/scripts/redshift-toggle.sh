#!/usr/bin/env bash

if [ "$(systemctl --user is-active "redshift")" = "active" ]; then
  systemctl --user stop redshift
else
  systemctl --user start redshift
fi
