#! /bin/bash

# htop
/usr/bin/kitty @launch --type overlay --window-title 'htop' /usr/bin/htop
# tab title
/usr/bin/kitty @set-tab-title 'htop'
# cmus
/usr/bin/kitty @launch --type tab \
  --location after --tab-title 'cmus' --window-title 'cmus' /usr/bin/cmus
# cava
if [[ -f /usr/bin/cava ]]; then
  /usr/bin/kitty @launch --type window --dont-take-focus \
    --location hsplit --window-title 'cava' /usr/bin/cava
fi
# calc
/usr/bin/kitty @launch --type tab --dont-take-focus \
  --location after --tab-title 'calc' --window-title 'calc' /usr/bin/bc --mathlib
/usr/bin/kitty @focus-tab --match title:'htop'
