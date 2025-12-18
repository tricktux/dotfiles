#!/bin/bash
if systemctl is-active --quiet wg-quick@home.service; then
  echo "🔒 WG"
else
  echo ""
fi
