#!/bin/sh

UNIT="wg-quick@wg0"

journalctl --follow -o cat --unit $UNIT | while read -r; do
  if [ "$(systemctl is-active "$UNIT")" = "active" ]; then
    echo "   wg0  "
  else
    echo ""
  fi
done
