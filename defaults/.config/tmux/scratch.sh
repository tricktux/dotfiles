#! /bin/sh

session="scratch"

# -t is the target, see man tmux, COMMANDS section
#   You can also refer to a windows in a session. I.e: -t $session:0
#   That is windows 0 in $session
# [this](https://gist.github.com/todgru/6224848) is a great sample script

# Start the tmux server, if not already running, without creating any sessions.
/usr/bin/tmux start-server

/usr/bin/tmux new-session -d -s $session -n 'ranger' '/usr/bin/ranger'
# /usr/bin/tmux new-window -d -t $session -n \
  # 'journal' '~/.config/i3/scripts/journal.sh'
# Vim satisfies most of needs
/usr/bin/tmux new-window -d -t $session -n 'bottom' '/usr/bin/btm'
/usr/bin/tmux new-window -d -t $session -n 'cmus' '/usr/bin/cmus'
/usr/bin/tmux new-window -d -t $session -n 'stonks' '/usr/bin/tickrs'
/usr/bin/tmux new-window -d -t $session -n 'calc' '/usr/bin/bc -q'
/usr/bin/tmux attach-session -t $session
