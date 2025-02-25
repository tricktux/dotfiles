#
# bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export HISTCONTROL="erasedups:ignorespace"

complete -c man which

run-help() { help "$READLINE_LINE" 2>/dev/null || man "$READLINE_LINE"; }
bind -m vi-insert -x '"\eh": run-help'

shopt -s autocd
shopt -s checkwinsize

# Enable vi mode
set -o vi
