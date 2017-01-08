#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# For more aliases use bash_aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

export EDITOR=nvim

function _update_ps1() {
	PS1="$(~/.powerline/powerline-shell/powerline-shell.py $? 2> /dev/null)"
}

liquid=~/Downloads/packages/liquidprompt/liquidprompt
# If its not linux or android shell and file $liquid exists source it
if [[ "$TERM" != "linux" && `uname -o` != "Android" && -f $liquid ]]; then
	source $liquid
else
	# Default PS1
	PS1='[\u@\h \W]\$ '
fi

# This is for fzf to use ripgrep
# --files: List files that would be searched but do not search
# --no-ignore: Do not respect .gitignore, etc...
# --hidden: Search hidden files and folders
# --follow: Follow symlinks
# --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'

if [[ -z "$TMUX" ]]; then
	ID="`tmux ls | grep -vm1 attached | cut -d: -f1`"
	if [[ -z "$ID" ]]; then
		tmux new-session
	else
		tmux attach-session -t "$ID"
	fi
fi

# Creating local bin folder
export PATH=$PATH:$HOME/.local/bin

export EMAIL="rmolin88@gmail.com"

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=8888
HISTFILESIZE=8888
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# Adb, fastboot
# Fixes vim-javacomplete2 issues
# Remember to launch nvim at the code base
if [ `uname -o` != "Android" ]; then
	export ANDROID_HOME=$HOME/Downloads/packages/android-sdk-linux
	export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
fi

export XTERM=screen-256

# Man settings
export MANPATH=/usr/local/man:/usr/local/share/man:/usr/share/man:/usr/man
export MANPAGER="nvim -c 'set ft=neoman' -"
