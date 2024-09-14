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
	paru -Syu --needed luajit stylua lua-language-server luacheck
}

neovim() {
	"${XDG_CONFIG_HOME:=$HOME/.config}/dotfiles/scripts/nix/installs/arch/coding/neovim.sh"
}

environment() {
	paru -Syu --needed bat fzf direnv ripgrep-all stow \
        tldr xclip htop-vim eza wget rsync nodejs z kitty \
        {ttf,otf}-cascadia-code {ttf,otf}-fira-{code,mono} \
        lazygit termite man-db less man-pages meld hyperfine
    sudo mandb
}

atuin() {
    paru -Syu --needed --noconfirm atuin
    # Either restore the local/share/atuin folder from the backups
    # or
    # Giving it the path to zhist file
    # HISTFILE=/path/to/history/file atuin import zsh
}

compression() {
	paru -Syu --needed 7-zip atool unrar unzip zip
}

lazygit() {
	paru -Syu --needed lazygit
}

ranger() {
	paru -Syu --needed ranger w3m ffmpeg highlight libcaca python-pillow
	git clone https://github.com/cdump/ranger-devicons2 ~/.config/ranger/plugins/devicons2
}

cpp() {
	paru -Syu --needed --noconfirm cppcheck cpplint lldb clang gdb gdb-dashboard-git \
		ninja cmake cmake{,-lint,-format,-language-server} ccache mold perf \
		valgrind
}

rust() {
	paru -Syu --needed --noconfirm rustup sccache rust-analyzer
	rustup toolchain install stable
	rustup component add rust-src rustfmt clippy
}

java() {
	paru -Syu --needed --noconfirm j{re,re8,dk,dk8}-openjdk jdtls astyle
}

zsh() {
	# Install plugins
	paru -Syu --needed --noconfirm zsh z-git \
		zsh-theme-powerlevel10k zsh-autosuggestions \
		zsh-history-substring-search zsh-syntax-highlighting \
		zsh-completions zsh-vi-mode
	chsh -s /usr/bin/zsh
	export ZDOTDIR=$HOME/.config/zsh
}

markdown() {
	paru -Syu --needed --noconfirm pandoc-bin vale plantuml markdownlint-cli write-good proselint marksman
}

tex() {
	paru -Syu --needed --noconfirm texlive-bibtexextra texlive-binextra texlive-context texlive-fontsextra texlive-fontsrecommended texlive-fontutils texlive-formatsextra texlive-games texlive-humanities texlive-latex texlive-latexextra texlive-latexrecommended texlive-luatex texlive-mathscience texlive-metapost texlive-music texlive-plaingeneric texlive-pstricks texlive-publishers texlive-xetex
}

python() {
	paru -Syu --needed --noconfirm python{,-pipx} ruff-lsp pyright python-pylint
}

# TODO: zig

help() {
	# Display Help
	echo "Install coding applications for Arch"
	echo
	echo "All options are optional"
	echo "If no options are provided all coding environments will be installed"
	echo
	echo "Syntax: update-arch [-h|l|n|e|x|r|c|u|j|z|m|t|p]"
	echo "options:"
	echo "l     lua"
	echo "n     neovim"
	echo "e     generic environment"
	echo "x     compression"
	echo "r     ranger"
	echo "c     c/c++"
	echo "u     rust"
	echo "j     java"
	echo "z     zsh"
	echo "m     markdown"
	echo "t     tex"
	echo "p     python"
	echo "h     Print this Help."
	echo
}

# Get the options
while getopts "h:lnexrcujzthp" option; do
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
	x)
		compression
		exit 0
		;;
	r)
		ranger
		compression
		exit 0
		;;
	c)
		cpp
		exit 0
		;;
	u)
		rust
		exit 0
		;;
	j)
		java
		exit 0
		;;
	z)
		zsh
		exit 0
		;;
	m)
		markdown
		exit 0
		;;
	t)
		tex
		exit 0
		;;
	p)
		python
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
