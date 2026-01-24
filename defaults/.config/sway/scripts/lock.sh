#!/bin/bash

# Launch swaylock with consistent settings
exec swaylock \
    --color 1a0000 \
    --indicator-radius 100 \
    --indicator-thickness 8 \
    --ring-color ff4500 \
    --key-hl-color ffff00 \
    --line-color 00000000 \
    --inside-color 33000088 \
    --separator-color 00000000 \
    --text-color ff6600 \
    --caps-lock-key-hl-color ffff00 \
    --show-failed-attempts
