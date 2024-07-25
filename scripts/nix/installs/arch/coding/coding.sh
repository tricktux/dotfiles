#!/usr/bin/env bash

# Fail as soon as a command fails
set -Eeuo pipefail

# Execute cleanup() if any of these sig events happen
trap cleanup SIGINT SIGTERM ERR #EXIT

cleanup() {
	trap - SIGINT SIGTERM ERR #EXIT
	msg_error "==> Something went wrong...     "
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
	notify-send 'Arch Update' "${2:10:-8}"
}
msg_error() {
	echo >&2 -e "${RED}${BOLD}${1-}${NOFORMAT}"
	notify-send 'Arch Update' "${1:4:-8}" -u critical
}

quit() {
	for job in $(jobs -p); do
		msg_not "${BLUE}${BOLD}" "[RIMP]==> Waiting for job: ${job} to finish...     "
		wait "$job"
	done
	msg_not "${BLUE}${BOLD}" "[RIMP]==> Thanks for flying arch updates!"
	read -n1 -r key
	exit 0
}

setup_colors

lua() {
	paru -Syu --needed luajit stylua lua-language-server
}

neovim() {
	"$TERMINAL" \
		"$XDG_CONFIG_HOME/dotfiles/scripts/nix/installs/arch/coding/neovim.sh" &
}

environment() {
	paru -Syu --needed bat fzf direnv atuin ripgrep-all stow \
		tldr xclip htop-vim eza wget rsync nodejs z
}

compression() {
	paru -Syu --needed 7-zip atool unrar unzip zip
}

lazygit() {
	paru -Syu --needed lazygit delta
}

ranger() {
	paru -Syu --needed ranger
	compression
}

help() {
	# Display Help
	echo "Install coding applications for Arch"
	echo
	echo "All options are optional"
	echo "If no options are provided all coding environments will be installed"
	echo
	echo "Syntax: update-arch [-h|l|n|e|c|r]"
	echo "options:"
	echo "l     lua"
	echo "n     neovim"
	echo "e     generic environment"
	echo "c     compression"
	echo "r     ranger"
	echo "h     Print this Help."
	echo
}

# Get the options
while getopts "h:lnh" option; do
	case $option in
	h) # display Help
		help
		exit
		;;
	l)
		lua
		exit 0
		;;
	n)
		neovim
		exit 0
		;;
	e)
		environment
		exit 0
		;;
	c)
		compression
		exit 0
		;;
	r)
		ranger
		exit 0
		;;
	\?) # Invalid option
		echo "Error: Invalid option"
		echo
		help
		exit
		;;
	esac
done

msg "${CYAN}${BOLD}" "========== Welcome! To the Arch Maintnance Script! 💪😎  =========="
# Backups first, since most likely they'll be kernel update and that messes up
# everything
