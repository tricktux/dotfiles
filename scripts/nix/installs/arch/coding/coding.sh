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
        lazygit termite man-db less man-pages meld hyperfine \
        cscope ctags
    sudo mandb
}

dotnet() {
    paru -Syu --needed --noconfirm dotnet-runtime dotnet-sdk
    # Installing other versions, first try the aur, if not there do the below
    # Use the script: from https://dot.net/v1/dotnet-install.sh
    # Use the --dry-run flag if you are not sure
    # sudo ./dotnet-install.sh --version "4.5xx" --install-dir "/usr/share/dotnet" --architecture "x64" --os "linux"
}

docs() {
    paru -Syu --needed --noconfirm zeal-git
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
	paru -Syu --needed ranger w3m ffmpeg highlight libcaca python-pillow atool
	git clone https://github.com/cdump/ranger-devicons2 ~/.config/ranger/plugins/devicons2
}

cpp() {
	paru -Syu --needed --noconfirm cppcheck cpplint lldb clang gdb gdb-dashboard-git \
		ninja cmake cmake{,-lint,-format,-language-server} ccache mold perf \
		valgrind
}

emacs() {
    paru -Syu --needed --noconfirm emacs
    # Ensure ~/.emacs* does not exists
    # symlink <dotfiles>/doom to ~/.config/doom
    git clone https://github.com/hlissner/doom-emacs ~/.config/emacs
    ~/.config/emacs/bin/doom install
}

rust() {
	paru -Syu --needed --noconfirm rustup sccache rust-analyzer
	rustup toolchain install stable
	rustup component add rust-src rustfmt clippy
}

java() {
	paru -Syu --needed --noconfirm j{re,re8,dk,dk8}-openjdk jdtls astyle
}

shell() {
    paru -Syu --needed --noconfirm shellcheck-bin shfmt
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
  paru -Syu --needed --noconfirm texlive-{basic,latex,latexrecommended,latexextra,fontsrecommended,fontsextra,xetex}

  # Install templates
  # Define the destination directory
  local DEST="$HOME/.local/share/pandoc/templates"

  # Create the destination directory if it does not exist
  mkdir -p "$DEST"

  # Download the templates by cloning the repositories
  git clone https://github.com/Wandmalfarbe/pandoc-latex-template --depth 1 /tmp/eisvogel
  git clone https://github.com/ryangrose/easy-pandoc-templates --depth 1 /tmp/easy-pandoc-templates

  # Copy the template files to the destination directory
  for file in /tmp/easy-pandoc-templates/html/*.html; do
    [ -e "$file" ] || continue
    cp -n $file "$DEST"
  done
  cp -R /tmp/eisvogel/eisvogel.tex "$DEST"/eisvogel.latex
}

python() {
	paru -Syu --needed --noconfirm python{,-pipx} ruff-lsp pyright python-pylint
}

zig() {
	paru -Syu --needed --noconfirm zig zls
}

help() {
	# Display Help
	echo "Install coding applications for Arch"
	echo
	echo "All options are optional"
	echo "If no options are provided all coding environments will be installed"
	echo
	echo "Syntax: update-arch [-h|l|n|e|x|r|c|u|j|z|m|p|i]"
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
	echo "p     python"
  echo "i     zig"
	echo "h     Print this Help."
	echo
}

# Get the options
while getopts "h:lnexrcujzhpi" option; do
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
  i)
    zig
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

echo "No option was selected"
