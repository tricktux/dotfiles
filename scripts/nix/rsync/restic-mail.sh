#!/usr/bin/env bash

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
    # Skip pretty characters
    notify-send 'restic backlaze skywafer backup' "${2}"
}
msg_error() {
    echo >&2 -e "${RED}${BOLD}${1-}${NOFORMAT}"
    notify-send 'restic backlaze skywafer backup' "${1:4:-3}" -u critical
}

setup_colors
echo >&2 -e "${CYAN}${BOLD}==>Backing up mailserver<==${NOFORMAT}"
SRC="$HOME/.local/share/mail $HOME/.local/share/vdirsyncer"
SNAP="$HOME/.mnt/skywafer/home/bkps/mail/repo"
mbsync -D -ac "$HOME"/.config/isync/mbsyncrc ||
    echo "mbsync never retuns code 0..."
vdirsyncer --verbosity debug sync
restic --verbose \
    --password-command "pass linux/mailserver/restic" \
    --repo "$SNAP" \
    backup $SRC

msg "${BLUE}${BOLD}" "[RIMP]==> Thanks for backing up!"
read -n1 -r key
exit 0
