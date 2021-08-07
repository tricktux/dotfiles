# Start configuration added by Zim install {{{
#
# User configuration sourced by interactive shells
#

# -----------------
# Zsh configuration
# -----------------

#
# History
#

# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

#
# Input/output
#

# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -e

# Prompt for spelling correction of commands.
#setopt CORRECT

# Customize spelling correction prompt.
#SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}


# --------------------
# Module configuration
# --------------------

#
# completion
#

# Set a custom path for the completion dump file.
# If none is provided, the default ${ZDOTDIR:-${HOME}}/.zcompdump is used.
#zstyle ':zim:completion' dumpfile "${ZDOTDIR:-${HOME}}/.zcompdump-${ZSH_VERSION}"

#
# git
#

# Set a custom prefix for the generated aliases. The default prefix is 'G'.
#zstyle ':zim:git' aliases-prefix 'g'

#
# input
#

# Append `../` to your input for each `.` you type after an initial `..`
#zstyle ':zim:input' double-dot-expand yes

#
# termtitle
#

# Set a custom terminal title format using prompt expansion escape sequences.
# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
# If none is provided, the default '%n@%m: %~' is used.
#zstyle ':zim:termtitle' format '%1~'

#
# zsh-autosuggestions
#

# Customize the style that the suggestions are shown with.
# See https://github.com/zsh-users/zsh-autosuggestions/blob/master/README.md#suggestion-highlight-style
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

#
# zsh-syntax-highlighting
#

# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Customize the main highlighter styles.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md#how-to-tweak-it
#typeset -A ZSH_HIGHLIGHT_STYLES
#ZSH_HIGHLIGHT_STYLES[comment]='fg=242'

# ------------------
# Initialize modules
# ------------------

if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  # Update static initialization script if it does not exist or it's outdated, before sourcing it
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
source ${ZIM_HOME}/init.zsh

# ------------------------------
# Post-init module configuration
# ------------------------------

#
# zsh-history-substring-search
#

# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Bind up and down keys
zmodload -F zsh/terminfo +p:terminfo
if [[ -n ${terminfo[kcuu1]} && -n ${terminfo[kcud1]} ]]; then
  bindkey ${terminfo[kcuu1]} history-substring-search-up
  bindkey ${terminfo[kcud1]} history-substring-search-down
fi

bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
# }}} End configuration added by Zim install

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#{{{compinstall
# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' max-errors 2
# Autocompletion for sudo
zstyle ':completion::complete:*' gain-privileges 1
zstyle :compinstall filename '/home/reinaldo/.config/zsh/.zshrc'

zstyle ':completion:*:pacman:*' force-list always
zstyle ':completion:*:*:pacman:*' menu yes select

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*'   force-list always

zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:killall:*' force-list always

#}}}

# My Options{{{
# Prevent double entries in $PATH
typeset -U path

# Avoid duplicates.
# Taken from: https://leetschau.github.io/remove-duplicate-zsh-history.html
setopt PUSHD_IGNORE_DUPS
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
# setopt HIST_BEEP

autoload -Uz compinit promptinit
compinit
promptinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
setopt appendhistory autocd extendedglob nomatch notify
unsetopt beep
# End of lines configured by zsh-newuser-install

# This will set the default prompt to the walters theme

# Autocompletion for aliases
setopt COMPLETE_ALIASES

# Module for async
zmodload zsh/zpty

# }}}

# Source plugins{{{
# Depends on `pkgfile`
if [[ -f /usr/bin/pkgfile ]]; then
  source /usr/share/doc/pkgfile/command-not-found.zsh
fi

# Depends on `zsh-syntax-highlighting`
HIGHLIGHT=/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
if [[ -f $HIGHLIGHT ]]; then
  source $HIGHLIGHT
fi

SUGG=/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
if [[ -f $SUGG ]]; then
  source $SUGG
fi
# }}}

# Exports {{{
export IGNORE_FILE="--ignore-file $HOME/.config/ignore-file"

# reduce timeout
export KEYTIMEOUT=1

export _Z_DATA="$HOME/.local/share/z"

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
# }}}

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="false"

# Uncomment the following line to disable auto-setting terminal title
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"
	
# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Source files{{{
[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases

# context for resume making
# install context-minimals-git
# mtxrun --generate
[[ -f /opt/context-minimals/setuptex ]] && source /opt/context-minimals/setuptex

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
# }}}

# fzf setup{{{
if [[ -f /usr/bin/fzf ]]; then
  source /usr/share/fzf/key-bindings.zsh

  # Depends on `install fd`
  if [[ -f /usr/bin/fd ]]; then
    export FZF_ALT_C_COMMAND="fd --type directory --hidden --no-ignore-vcs $IGNORE_FILE . $(pwd)"
    export FZF_DEFAULT_COMMAND="fd --type file --hidden --follow $IGNORE_FILE 2> /dev/null"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
    # Taken from: https://github.com/junegunn/fzf/wiki/Color-schemes
    # Looks really weird with the dark color scheme
    export FZF_DEFAULT_OPTS="--layout=reverse --info=inline"
    # --color fg:240,bg:230,hl:33,fg+:241,bg+:221,hl+:33
    # --color info:33,prompt:33,pointer:166,marker:166,spinner:33
  fi

  # TODO-[RM]-(Wed Oct 25 2017 10:10): Download it
  # https://github.com/urbainvaes/fzf-marks
fi
# }}}

# ssh agent {{{
# Start ssh-agent to cache ssh keys passphrases. Or use an existing one
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
  ssh-agent > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! "$SSH_AUTH_SOCK" ]]; then
  eval "$(<"$XDG_RUNTIME_DIR/ssh-agent.env")" > /dev/null || echo "Failed to start ssh-agent"
fi
# }}}

# tmux on ssh{{{
# Run tmux automatically on ssh
if [[ "$TMUX" == "" ]] &&
        [[ "$SSH_CONNECTION" != "" ]]; then
    WHOAMI=$(whoami)
    if tmux has-session -t $WHOAMI 2>/dev/null; then
			tmux -2 attach-session -t $WHOAMI
    else
			tmux -2 new-session -s $WHOAMI
    fi
fi
# }}}

# vim: fdm=marker
