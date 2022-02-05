#! /bin/bash

session="scratch"

# -t is the target, see man tmux, COMMANDS section
#   You can also refer to a windows in a session. I.e: -t $session:0
#   That is windows 0 in $session
# [this](https://gist.github.com/todgru/6224848) is a great sample script

# Start the tmux server, if not already running, without creating any sessions.
/usr/bin/tmux start-server

/usr/bin/tmux kill-session -t $session || echo "session did not exist"

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
