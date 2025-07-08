#!/bin/bash
# This is a simple placeholder - you'll need to adapt your existing pomodoro script
if [[ -f /tmp/pomodoro_status ]]; then
  status=$(cat /tmp/pomodoro_status)
  case $status in
  "active") echo "🖥️: [25m]" ;;
  "break") echo "🏖️: [5m]" ;;
  *) echo "⏳: [--]" ;;
  esac
else
  echo "⏳: [--]"
fi
