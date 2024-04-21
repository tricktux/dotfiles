#! /usr/bin/env bash

# htop
kitty @launch --type overlay --window-title 'htop' htop
# tab title
kitty @set-tab-title 'htop'
# pause htop
kitty @send-text 'Z'
# cmus
kitty @launch --type tab \
  --location after --tab-title 'cmus' --window-title 'cmus' cmus
# cava
if [[ -f cava ]]; then
  kitty @launch --type window --dont-take-focus \
    --location hsplit --window-title 'cava' cava
fi
# calc
kitty @launch --type tab --dont-take-focus \
  --location after --tab-title 'calc' --window-title 'calc' bc --mathlib
# Bring focus back to htop window
kitty @focus-tab --match title:'htop'
