#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'

# Default PS1
# PS1='[\u@\h \W]\$ '

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# For more aliases use bash_aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

export EDITOR=nvim

function _update_ps1() {
	PS1="$(~/.powerline/powerline-shell/powerline-shell.py $? 2> /dev/null)"
}

if [ "$TERM" != "linux" ]; then
	PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi

# This is for fzf to use ripgrep
# --files: List files that would be searched but do not search
# --no-ignore: Do not respect .gitignore, etc...
# --hidden: Search hidden files and folders
# --follow: Follow symlinks
# --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'

# if [[ -z "$TMUX" ]]; then
	# ID="`tmux ls | grep -vm1 attached | cut -d: -f1`"
	# if [[ -z "$ID" ]]; then
		# tmux new-session
	# else
		# tmux attach-session -t "$ID"
	# fi
# fi

# Creating local bin folder
export PATH=/home/reinaldo/.local/bin:$PATH

# To use Nvim as a manpager:
export MANPAGER="nvim -"

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=8888
HISTFILESIZE=8888
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# Adb, fastboot
# Fixes vim-javacomplete2 issues
export ANDROID_HOME=$HOME/Downloads/packages/android-sdk-linux
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

# Neovim Intellij Plugin
export NVIM_LISTEN_ADDRESS=127.0.0.1:7650
