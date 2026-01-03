#!/bin/bash
if command -v nvidia-smi &>/dev/null; then
  temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)
  mem_used=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits)
  mem_total=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits)
  mem_percent_scaled=$((mem_used * 1000 / mem_total))
  mem_percent="$((mem_percent_scaled / 10)).$((mem_percent_scaled % 10))"
  echo "🎮 ${temp}°C ${mem_used}MB (${mem_percent}%)"
else
  echo ""
fi
