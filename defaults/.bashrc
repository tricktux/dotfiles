#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# For more aliases use bash_aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

function _update_ps1() {
	PS1="$(~/.powerline/powerline-shell/powerline-shell.py $? 2> /dev/null)"
}

# If its not linux or android shell and file $liquid exists source it
if [[ "$TERM" != "linux" && `uname -o` != "Android" ]]; then
	hash liquidprompt 2>/dev/null && source liquidprompt
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
# if rg command exists
# Debug this its not really working
if [ hash rg 2>/dev/null ]; then
	export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'
fi

if [[ -z "$TMUX" ]]; then
	# Do not attach to the 
	ID="`tmux ls | grep -vm1 attached | cut -d: -f1`"
	# Do not attach to the cmus session. Let it run in the background
	if [[ -z "$ID" || "$ID" = "cmus" ]]; then
		tmux new-session
	else
		tmux attach-session -t "$ID"
	fi
fi

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

# Exports
export XTERM=screen-256
# Man settings
export MANPATH=/usr/local/man:/usr/local/share/man:/usr/share/man:/usr/man
export MANPAGER="nvim -c 'set ft=neoman' -"
# Creating local bin folder
# Keep in mind you bin preceeds /usr/bin
export PATH=$HOME/.local/bin:$PATH
export EMAIL="rmolin88@gmail.com"
export EDITOR=nvim

# Pacaur environment variables. See man pacaur
# Dangerous options
# export BUILDIR=/tmp
# export PKGDEST=$HOME/.local/
