#! /bin/sh

session="neomutt"

# -t is the target, see man tmux, COMMANDS section
#   You can also refer to a windows in a session. I.e: -t $session:0
#   That is windows 0 in $session
# [this](https://gist.github.com/todgru/6224848) is a great sample script

# Start the tmux server, if not already running, without creating any sessions.
/usr/bin/tmux start-server

/usr/bin/tmux new-session -d -s $session -n 'mailserver' \
  'neomutt -F ~/.config/neomutt/user.molinamail'
/usr/bin/tmux new-window -d -t $session -n 'gmail' \
  'neomutt -F ~/.config/neomutt/user.gmail'
/usr/bin/tmux new-window -d -t $session -n 'ufl' \
  'neomutt -F ~/.config/neomutt/user.ufl'
# Wed Feb 19 2020 20:11: Account has been disabled 
# /usr/bin/tmux  new-window  -d -t $session -n 'psu' 'neomutt -F ~/.config/neomutt/user.psu'
/usr/bin/tmux new-window -d -t $session -n 'pmserver' 'protonmail-bridge --cli'
/usr/bin/tmux new-window -d -t $session -n 'pm' \
  'sleep 5; neomutt -F ~/.config/neomutt/user.pm'
/usr/bin/tmux -2 attach-session -t $session
