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

# fzf use ripgrep
if [ -f /usr/bin/rg ]; then
	export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git" --glob "!.svn"'
fi

# context for resume making
# install context-minimals-git
# mtxrun --generate
if [ -f /opt/context-minimals/setuptex ]; then
	source /opt/context-minimals/setuptex
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
if [[ `uname -o` != "Android" && -d "$HOME/Downloads/packages/android-sdk-linux" ]]; then
	export ANDROID_HOME=$HOME/Downloads/packages/android-sdk-linux
	export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
fi

# Exports
export TERM=tmux-256color
# Man settings
export MANPATH=/usr/local/man:/usr/local/share/man:/usr/share/man:/usr/man
export MANPAGER="nvim -c 'set ft=man' -"
# Creating local bin folder
# Keep in mind you bin preceeds /usr/bin
export PATH=$HOME/.local/bin:$PATH
export EMAIL="rmolin88@gmail.com"
# export EDITOR=vim
# export VISUAL=vim
export BROWSER=opera

# Pacaur environment variables. See man pacaur
# Dangerous options
# export BUILDIR=/tmp
# export PKGDEST=$HOME/.local/

# Ranger load only ~/.config/ranger/rc.conf
export RANGER_LOAD_DEFAULT_RC=FALSE

# Fixes git weird issue
export GIT_TERMINAL_PROMPT=1

# This should always be the last thing so that all export are done properly
# Sat Jun 10 2017 13:38 
# No need for tmux any more with nvim
if [ -f /usr/bin/tmux ]; then
	if [[ -z "$TMUX" ]]; then
		# Do not attach to the 
		ID="`tmux ls | grep -vm1 attached | cut -d: -f1`"
		# Do not attach to the cmus session. Let it run in the background
		if [[ -z "$ID" || "$ID" = "cmus" ]]; then
			tmux -2 new-session
		else
			tmux attach-session -t "$ID"
		fi
	fi
fi

