#!/bin/bash

# Kill any existing swaylock instances to prevent conflicts
pkill -f swaylock 2>/dev/null

# Wait a moment for cleanup
sleep 0.1

# Launch swaylock with consistent settings
exec swaylock \
    --screenshots \
    --clock \
    --indicator \
    --indicator-radius 100 \
    --indicator-thickness 7 \
    --effect-blur 7x5 \
    --effect-vignette 0.5:0.5 \
    --ring-color bb00cc \
    --key-hl-color 880033 \
    --line-color 00000000 \
    --inside-color 00000088 \
    --separator-color 00000000 \
    --grace 2 \
    --fade-in 0.2
