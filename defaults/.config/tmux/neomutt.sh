#! /bin/bash

session="neomutt"

# Fail as soon as a command fails
set -Eeuo pipefail

# Execute cleanup() if any of these sig events happen
trap cleanup SIGINT SIGTERM ERR #EXIT

cleanup() {
  trap - SIGINT SIGTERM ERR #EXIT
  notify-send 'Neomutt' "Something went wrong..." -u critical
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
mkdir -p ~/.local/share/mail/molinamail
mkdir -p ~/.local/share/mail/molinamail_meli
/usr/bin/mbsync -ac ~/.config/isync/mbsyncrc >/tmp/mbsync.log 2>&1 &
/usr/bin/goimapnotify -conf ~/.config/imapnotify/molinamail.conf \
  >/tmp/imapnotify_molinamail.log 2>&1 &

if [[ $(systemctl --user is-active vdirsyncer.timer) = "inactive" ]]; then
  echo "Synchronizing vdirsyncer. Please wait..."
  /usr/bin/vdirsyncer -vdebug sync \
    >/tmp/vdirsyncer.log 2>&1

  systemctl --user start vdirsyncer.timer
fi

/usr/bin/tmux kill-session -t $session || echo "session did not exist"

/usr/bin/tmux new-session -d -s $session -n 'mailserver' \
  'neomutt -F ~/.config/neomutt/user.molinamail 2>/tmp/nmutt-molinamail.log'
/usr/bin/tmux new-window -d -t $session -n 'gmail' \
  'neomutt -F ~/.config/neomutt/user.gmail 2>/tmp/nmutt-gmail.log'
/usr/bin/tmux new-window -d -t $session -n 'ufl' \
  'neomutt -F ~/.config/neomutt/user.ufl 2>/tmp/nmutt-ufl.log'
/usr/bin/tmux new-window -d -t $session -n 'calendars' \
  'khal interactive 2>/tmp/khal.log'
/usr/bin/tmux new-window -d -t $session -n 'todo'
/usr/bin/tmux -2 attach-session -t $session
