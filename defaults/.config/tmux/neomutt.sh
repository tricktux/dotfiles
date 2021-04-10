#! /bin/sh

session="neomutt"

# Fail as soon as a command fails
set -Eeuo pipefail

# Execute cleanup() if any of these sig events happen
trap cleanup SIGINT SIGTERM ERR #EXIT

cleanup() {
  trap - SIGINT SIGTERM ERR #EXIT
  notify-send 'Email' "Something went wrong..." -u critical
  read -n1 -r key
  exit $?
}

# -t is the target, see man tmux, COMMANDS section
#   You can also refer to a windows in a session. I.e: -t $session:0
#   That is windows 0 in $session
# [this](https://gist.github.com/todgru/6224848) is a great sample script

# Start the tmux server, if not already running, without creating any sessions.
/usr/bin/tmux start-server

# Synchronizing email
# Do it in the background. It can take up to 5 minutes
/usr/bin/mbsync -D -ac ~/.config/isync/mbsyncrc >/tmp/isync.log 2>&1 &
# /usr/bin/goimapnotify -conf ~/.config/imapnotify/gmail.conf \
# >! /tmp/imapnotify_gmail.log 2>&1 &
/usr/bin/goimapnotify -conf ~/.config/imapnotify/molinamail.conf \
  >/tmp/imapnotify_molinamail.log 2>&1 &

/usr/bin/tmux new-session -d -s $session -n 'mailserver' \
  'neomutt -F ~/.config/neomutt/user.molinamail'
/usr/bin/tmux new-window -d -t $session -n 'gmail' \
  'neomutt -F ~/.config/neomutt/user.gmail'
/usr/bin/tmux new-window -d -t $session -n 'ufl' \
  'neomutt -F ~/.config/neomutt/user.ufl'
# Wed Feb 19 2020 20:11: Account has been disabled
# /usr/bin/tmux  new-window  -d -t $session -n 'psu' 'neomutt -F ~/.config/neomutt/user.psu'
# Tue May 19 2020 04:51: Free account doesn't allow this stuff
# /usr/bin/tmux new-window -d -t $session -n 'pmserver' 'protonmail-bridge --cli'
# /usr/bin/tmux new-window -d -t $session -n 'pm' \
# 'sleep 5; neomutt -F ~/.config/neomutt/user.pm'
/usr/bin/tmux -2 attach-session -t $session
