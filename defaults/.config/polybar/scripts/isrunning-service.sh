#!/usr/bin/env bash

if [ "$(systemctl is-active "$1")" = "active" ]; then
    echo "   $1  "
else
    echo ""
fi
