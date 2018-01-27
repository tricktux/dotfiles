#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases

# If its not linux or android shell and file $liquid exists source it
if [[ "$TERM" != "linux" && `uname -o` != "Android" ]]; then
	hash liquidprompt 2>/dev/null && source liquidprompt
else
	# Default PS1
	PS1='[\u@\h \W]\$ '
fi

# fzf setup
if [[ -f /usr/bin/fzf ]]; then
	source /usr/share/fzf/key-bindings.bash
	# if we have rg. use it!
	if [ -f /usr/bin/rg ]; then
		export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.{git,svn}" 2> /dev/null'
		# TODO-[RM]-(Wed Oct 25 2017 11:10): This is experimental. Need to test it out.
		export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
	fi

	# Depends on `install bfs`
	export FZF_ALT_C_COMMAND="cd ~/; bfs -type d -nohidden | sed s/^\./~/"  

	# TODO-[RM]-(Wed Oct 25 2017 10:10): Download it
	# https://github.com/urbainvaes/fzf-marks

	# Issue neovim/neovim#4151 for neovim that causes fzf not working properly inside of neovim
	# terminal. Once resolved you can delete this.
	[ -n "$NVIM_LISTEN_ADDRESS" ] && export FZF_DEFAULT_OPTS='--no-height'
fi

# context for resume making
# install context-minimals-git
# mtxrun --generate
[[ -f /opt/context-minimals/setuptex ]] && source /opt/context-minimals/setuptex

# History Options
#
# Don't put duplicate lines in the history.
export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
PROMPT_COMMAND="history -n; history -w; history -c; history -r; $PROMPT_COMMAND"
#
# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&' is a special pattern which suppresses duplicate entries.
export HISTIGNORE=$'[ \t]*:&:[fb]g:exit'
export HISTIGNORE=$'[ \t]*:&:[fb]g:exit:ls' # Ignore the ls command as well
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=8888
HISTFILESIZE=8888

# Adb, fastboot
# Fixes vim-javacomplete2 issues
# Remember to launch nvim at the code base
if [[ `uname -o` != "Android" && -d "$HOME/Downloads/packages/android-sdk-linux" ]]; then
	export ANDROID_HOME=$HOME/Downloads/packages/android-sdk-linux
	export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
fi

# Exports
# Man settings
export MANPATH=/usr/local/man:/usr/local/share/man:/usr/share/man:/usr/man
export MANPAGER="nvim -c 'set ft=man' -"

# Creating local bin folder
# Keep in mind your bin preceeds /usr/bin
export PATH=$HOME/.local/bin:$PATH

# Depends on nvr being installed
# if [ -n "$NVIM_LISTEN_ADDRESS" ]; then
	# export VISUAL="nvr -cc tabedit --remote-wait +'set bufhidden=wipe'"
# else
	# export VISUAL="nvim"
# fi
# alias nvim="$VISUAL"
export VISUAL=nvim
export EDITOR=$VISUAL

# Ranger load only ~/.config/ranger/rc.conf
export RANGER_LOAD_DEFAULT_RC=FALSE

# Fixes git weird issue
export GIT_TERMINAL_PROMPT=1

# Completion options
#
# These completion tuning parameters change the default behavior of bash_completion:
#
# Define to access remotely checked-out files over passwordless ssh for CVS
# COMP_CVS_REMOTE=1
#
# Define to avoid stripping description in --option=description of './configure --help'
# COMP_CONFIGURE_HINTS=1
#
# Define to avoid flattening internal contents of tar files
# COMP_TAR_INTERNAL_PATHS=1
#
# Uncomment to turn on programmable completion enhancements.
# Any completions you add in ~/.bash_completion are sourced last.
[[ -f /etc/bash_completion ]] && . /etc/bash_completion

# Sat Oct 14 2017 22:27: fish being default terminal 
# Sat Oct 21 2017 16:14: very pretty but not very useful 
# [ -f /usr/bin/fish ] && exec fish

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
