#!/usr/bin/env bash


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

# Synchronizing email
# Do it in the background. It can take up to 5 minutes
mkdir -p ~/.local/share/mail/molinamail
mkdir -p ~/.local/share/mail/molinamail_meli
mkdir -p ~/.local/share/mail/molinamail_mcp
/usr/bin/mbsync -ac ~/.config/isync/mbsyncrc >/tmp/mbsync.log 2>&1 &
/usr/bin/goimapnotify -conf ~/.config/imapnotify/molinamail.conf \
  >/tmp/imapnotify_molinamail.log 2>&1 &

if [[ $(systemctl --user is-active vdirsyncer.timer) = "inactive" ]]; then
  systemctl --user start vdirsyncer.timer
fi

/usr/bin/kitty @launch --type overlay --window-title 'mailserver' \
  bash -c '/usr/bin/neomutt -F ~/.config/neomutt/user.molinamail 2>/tmp/nmutt-molinamail.log'
/usr/bin/kitty @launch --type tab --dont-take-focus \
  --tab-title 'todo' --window-title 'todo'
/usr/bin/kitty @launch --type tab --dont-take-focus \
  --tab-title 'calendars' --window-title 'calendars' \
  bash -c 'khal interactive 2>/tmp/khal.log'
/usr/bin/kitty @launch --type tab --dont-take-focus \
  --tab-title 'mcp' --window-title 'mcp' \
  bash -c 'neomutt -F ~/.config/neomutt/user.molinamail_mcp 2>/tmp/nmutt-mcp.log'
/usr/bin/kitty @launch --type tab --dont-take-focus \
  --tab-title 'ufl' --window-title 'ufl' \
  bash -c 'neomutt -F ~/.config/neomutt/user.ufl 2>/tmp/nmutt-ufl.log'
/usr/bin/kitty @launch --type tab --dont-take-focus \
  --tab-title 'gmail' --window-title 'gmail' \
  bash -c 'neomutt -F ~/.config/neomutt/user.gmail 2>/tmp/nmutt-gmail.log'
/usr/bin/kitty @set-tab-title 'mailserver'
