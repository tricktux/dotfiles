#!/usr/bin/env bash

## my own rsync-based snapshot-style backup procedure
## (cc) marcio rps AT gmail.com

# NOTE: Please run script with sudo

# config vars

# Fail as soon as a command fails
set -Eeuo pipefail

# Execute cleanup() if any of these sig events happen
trap cleanup SIGINT SIGTERM ERR #EXIT

cleanup() {
  trap - SIGINT SIGTERM ERR #EXIT
  msg "${RED}${BOLD}==> Something went wrong..."
  read -n1 -r key
  exit $?
}

# Colors are only meant to be used with msg()
# Sample usage:
# msg "This is a ${RED}very important${NOFORMAT} message
setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' \
      BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' \
      YELLOW='\033[1;33m' BOLD='\033[1m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW='' \
      BOLD=''
  fi
}

msg() {
  echo >&2 -e "${1-}${NOFORMAT}"
}

setup_colors

# Backup pacman's local database
# More info here:
# https://wiki.archlinux.org/index.php/Pacman/Restore_local_database
[[ -f /tmp/pacman_database.tar.bz2 ]] && rm /tmp/pacman_database.tar.bz2
tar -cjf /tmp/pacman_database.tar.bz2 /var/lib/pacman/local
SRC="/home/reinaldo/.gnupg /home/reinaldo/.ssh /home/reinaldo/.password-store /tmp/pacman_database.tar.bz2"
# SNAP="/snapshots/username"
SNAP="/home/reinaldo/.mnt/skynfs/$HOSTNAME"
OPTS="-rltgoi --delay-updates --delete --chmod=a-w --copy-links --mkpath"
MINCHANGES=20
CIFS_OPTIONS=credentials=/etc/samba/credentials/share,workgroup=WORKGROUP,uid=1000,gid=985,nofail,noauto,_netdev,nolock
SKYWAFER="//192.168.1.138/homes"

# Mount homes if not mounted before
if ! [ "$(ls -A $DIR)" ]; then
  # Ensure folder exists
  mkdir -p "$DIR"
  msg "${CYAN}${BOLD}" "==> Mounting homes..."
  sudo mount -t cifs "$SKYWAFER" "$DIR" -o "$CIFS_OPTIONS"
fi

rsync $OPTS $SRC $SNAP/latest >>$SNAP/rsync.log

# check if enough has changed and if so
# make a hardlinked copy named as the date

COUNT=$(wc -l $SNAP/rsync.log | cut -d" " -f1)
if [ "$COUNT" -gt "$MINCHANGES" ]; then
  msg "${CYAN}[rsync_backup]: Creating new snapshot..."
  DATETAG=$(date +%Y-%m-%d)
  if [ ! -e $SNAP/$DATETAG ]; then
    cp -al $SNAP/latest $SNAP/$DATETAG
    chmod u+w $SNAP/$DATETAG
    mv $SNAP/rsync.log $SNAP/$DATETAG
    chmod u-w $SNAP/$DATETAG
  fi
fi
