#!/bin/bash
# Simple DPMS status check
if hyprctl monitors | grep -q "dpmsStatus: true"; then
  echo "📺"
else
  echo "💤"
fi
