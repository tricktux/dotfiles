#! /bin/bash

session="scratch"

# -t is the target, see man tmux, COMMANDS section
#   You can also refer to a windows in a session. I.e: -t $session:0
#   That is windows 0 in $session
# [this](https://gist.github.com/todgru/6224848) is a great sample script

# Start the tmux server, if not already running, without creating any sessions.
/usr/bin/tmux start-server

/usr/bin/tmux kill-session -t $session || echo "session did not exist"

/usr/bin/kitty @launch --type overlay --window-title 'htop' /usr/bin/htop
/usr/bin/kitty @launch --type tab --dont-take-focus \
  --tab-title 'calc' --window-title 'calc' /usr/bin/bc --mathlib
/usr/bin/kitty @launch --type tab --dont-take-focus \
  --tab-title 'cmus' --window-title 'cmus' /usr/bin/cmus
/usr/bin/kitty @set-tab-title 'htop'
