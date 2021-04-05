#!/bin/sh

UNIT="openvpn-client@home"

journalctl --follow -o cat --unit $UNIT | while read -r; do
  if [ "$(systemctl is-active "$UNIT")" = "active" ]; then
    echo "   home.ovpn  "
  else
    echo ""
  fi
done
