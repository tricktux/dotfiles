#!/bin/bash
if command -v nvidia-smi &>/dev/null; then
  temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)
  mem_used=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits)
  mem_total=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits)
  mem_percent=$(echo "scale=1; $mem_used * 100 / $mem_total" | bc)
  echo "🎮 ${temp}°C ${mem_used}MB (${mem_percent}%)"
else
  echo ""
fi
