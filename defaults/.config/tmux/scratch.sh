#! /bin/bash

session="scratch"

# -t is the target, see man tmux, COMMANDS section
#   You can also refer to a windows in a session. I.e: -t $session:0
#   That is windows 0 in $session
# [this](https://gist.github.com/todgru/6224848) is a great sample script

# Start the tmux server, if not already running, without creating any sessions.
/usr/bin/tmux start-server

if [[ -f /usr/bin/ranger ]]; then
  /usr/bin/tmux new-session -d -s $session -n 'ranger' '/usr/bin/ranger'
fi

if [[ -f /usr/bin/htop ]]; then
  /usr/bin/tmux new-window -d -t $session -n 'htop' '/usr/bin/htop'
elif [[ -f /usr/bin/btm ]]; then
  /usr/bin/tmux new-window -d -t $session -n 'bottom' '/usr/bin/btm'
fi

# if [[ -f /usr/bin/nvtop ]]; then
#   /usr/bin/tmux new-window -d -t $session -n 'nvtop' '/usr/bin/nvtop'
# fi
# if [[ -f /usr/bin/radeontop ]]; then
#   /usr/bin/tmux new-window -d -t $session -n 'radeontop' '/usr/bin/radeontop'
# fi

if [[ -f /usr/bin/cmus ]]; then
  /usr/bin/tmux new-window -d -t $session -n 'cmus' '/usr/bin/cmus'
fi
if [[ -f /usr/bin/bc ]]; then
  /usr/bin/tmux new-window -d -t $session -n 'calc' '/usr/bin/bc -q'
fi
if [[ -f /usr/bin/cava ]]; then
  /usr/bin/tmux new-window -d -t $session -n 'cava' '/usr/bin/cava'
fi
if [[ -f /usr/bin/tty-clock ]]; then
  /usr/bin/tmux new-window -d -t $session -n 'clock' '/usr/bin/tty-clock -c -x -b -n'
fi

/usr/bin/tmux attach-session -t $session
