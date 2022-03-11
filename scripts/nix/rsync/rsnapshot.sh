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
  msg_error "==> Something went wrong..."
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
  echo >&2 -e "${1-}${2-}${NOFORMAT}"
}

msg_not() {
  echo >&2 -e "${1-}${2-}${NOFORMAT}"
  # Skip pretty characters
  notify-send 'Rsync Home' "${2}"
}
msg_error() {
  echo >&2 -e "${RED}${BOLD}${1-}${NOFORMAT}"
  notify-send 'Rsync Home' "${1:4:-3}" -u critical
}

setup_colors

# Source: https://www.redhat.com/sysadmin/arguments-options-bash-scripts
help() {
  # Display Help
  echo "Maintain a tree of snapshots of your files"
  echo
  echo "Creates a  directory with date-ordered copies of the files. "
  echo "The copies are made using hardlinks"
  echo "Which means that only files that did change will occupy space"
  echo
  echo "Syntax: rsnapshot -s SRC -d DST [-m|o]"
  echo "options:"
  echo "s     Space separated list of directories to back up"
  echo "d     Destination path"
  echo "o     Options to pass to rsync"
  echo "      Default: -rltgoi --delay-updates --delete --copy-links --mkpath"
  echo "m     Minimum number of changes before creating a new snapshot"
  echo "      Default: 20"
  echo "h     Print this Help."
  echo
}

SRC="INVALID"
# Needs full path since its run as sudo
SNAP="INVALID"
OPTS="-rltgoi --delay-updates --delete --copy-links --mkpath"
MINCHANGES=20

# Get the options
while getopts "s:d:o:m:h" option; do
  case $option in
  h) # display Help
    help
    exit
    ;;
  s)
    SRC=$OPTARG
    # echo "SRC = $SRC"
    ;;
  d)
    SNAP=$OPTARG
    # echo "SNAP = $SNAP"
    ;;
  o)
    OPTS=$OPTARG
    # echo "OPTS = $OPT"
    ;;
  m)
    MINCHANGES=$OPTARG
    # echo "MINCHANGES = $MINCHANGES"
    ;;
  \?) # Invalid option
    echo "Error: Invalid option"
    echo
    help
    exit
    ;;
  esac
done

if [[ $SRC = "INVALID" ]]; then
  echo "Error: Please specify a source argument (-s)"
  help
  exit 1
fi

if [[ $SNAP = "INVALID" ]]; then
  echo "Error: Please specify a destination argument (-d)"
  help
  exit 1
fi

msg "${CYAN}${BOLD}" "==> Source: ${SRC}... <=="
msg "${CYAN}${BOLD}" "==> Destination: ${SNAP}... <=="
msg "${CYAN}${BOLD}" "==> Options: ${OPTS}... <=="
msg "${CYAN}${BOLD}" "==> MINCHANGES: ${MINCHANGES}... <=="
# mkdir -p "$SNAP/latest"
rsync ${OPTS} ${SRC} "$SNAP/latest" | tee "$SNAP/rsync.log"

# check if enough has changed and if so
# make a hardlinked copy named as the date

COUNT=$(wc -l "$SNAP/rsync.log" | cut -d" " -f1)
if [ "$COUNT" -gt "$MINCHANGES" ]; then
  msg_not "${CYAN}${BOLD}" "==> Creating new snapshot..."
  DATETAG=$(date +%Y-%m-%d)
  if [ ! -e "$SNAP/$DATETAG" ]; then
    cp -al "$SNAP/latest" "$SNAP/$DATETAG"
    chmod u+w "$SNAP/$DATETAG"
    mv "$SNAP/rsync.log" "$SNAP/$DATETAG"
    chmod u-w "$SNAP/$DATETAG"
  fi
fi
