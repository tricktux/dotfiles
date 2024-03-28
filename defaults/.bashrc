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

# fzf setup
if [[ -f /usr/bin/fzf/key-bindings.bash ]]; then
	source /usr/share/fzf/key-bindings.bash
	# if we have rg. use it!
	if [ -f /usr/bin/rg ]; then
		export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.{git,svn}" 2> /dev/null'
		export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
		export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
	fi

	# Depends on `install bfs`
	export FZF_ALT_C_COMMAND="fd -t d . $HOME"

	# TODO-[RM]-(Wed Oct 25 2017 10:10): Download it
	# https://github.com/urbainvaes/fzf-marks
fi

# context for resume making
# install context-minimals-git
# mtxrun --generate
[[ -f /opt/context-minimals/setuptex ]] && source /opt/context-minimals/setuptex
# Sat Oct 14 2017 22:27: fish being default terminal
# Sat Oct 21 2017 16:14: very pretty but not very useful
# [ -f /usr/bin/fish ] && exec fish
