# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# The following lines were added by compinstall

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' max-errors 2
# Autocompletion for sudo
zstyle ':completion::complete:*' gain-privileges 1
zstyle :compinstall filename '/home/reinaldo/.zshrc'

zstyle ':completion:*:pacman:*' force-list always
zstyle ':completion:*:*:pacman:*' menu yes select

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*'   force-list always

zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:killall:*' force-list always

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

# vi mode
bindkey -v
# reduce timeout
export KEYTIMEOUT=1

# Depends on `pkgfile`
if [[ -f /usr/bin/pkgfile ]]; then
	source /usr/share/doc/pkgfile/command-not-found.zsh
fi

# zplug
ZPLUG_INIT=/usr/share/zsh/scripts/zplug/init.zsh
if [[ -f $ZPLUG_INIT ]]; then
	source $ZPLUG_INIT

	zplug "zsh-users/zsh-syntax-highlighting", defer:2

	# Load theme file
	zplug 'dracula/zsh', as:theme

	zplug 'zsh-users/zsh-autosuggestions'
else
	# Syntax highlight
	HIGHLIGHT=/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
	if [[ -f $HIGHLIGHT ]]; then
		source $HIGHLIGHT
	fi
fi

export _Z_DATA="$HOME/.local/share/z"

# Path to your oh-my-zsh installation.
ZSH=/usr/share/oh-my-zsh/
if [[ -f $ZSH/oh-my-zsh.sh ]]; then
	source $ZSH/oh-my-zsh.sh

	if [[ -f $ZPLUG_INIT ]]; then
		zplug "plugins/git",   from:oh-my-zsh
		zplug "plugins/docker",   from:oh-my-zsh
		zplug "plugins/dotenv",   from:oh-my-zsh
		zplug "plugins/sudo",   from:oh-my-zsh
		zplug "plugins/history-substring-search",   from:oh-my-zsh
		zplug "plugins/z",   from:oh-my-zsh
		# TODO update prompt
		zplug "plugins/nice-exit-code",   from:oh-my-zsh
		zplug "plugins/oh-my-git",   from:oh-my-zsh
		zplug "romkatv/powerlevel10k", use:powerlevel10k.zsh-theme
		# zplug "plugins/command-not-found",   from:oh-my-zsh
		# Breaks fzf mappings
		# zplug "plugins/vi-mode",   from:oh-my-zsh
	else
		plugins=(
			nice-exit-code
			oh-my-git
			git
			docker
			dotenv
			history-substring-search
			sudo # ESC twice to insert sudo
			command-not-found # Doesnt work with pacman :(
		)
	fi
	# Key bindings for the history substring search
	bindkey '' history-substring-search-up
	bindkey '' history-substring-search-down
	# <c-space> accept sugguestion
	bindkey '^ ' autosuggest-accept

	ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
	if [[ ! -d $ZSH_CACHE_DIR ]]; then
		mkdir $ZSH_CACHE_DIR
	fi
fi

# if [[ "$TERM" != "linux" && `uname -o` != "Android" && -f $ZSH/oh-my-zsh.sh ]]; then

	# # Theme
	# if [[ -f $ZPLUG_INIT ]]; then
		# setopt prompt_subst # Make sure prompt is able to be generated properly.
		 # # defer until other plugins like oh-my-zsh is loaded
		# zplug "caiogondim/bullet-train.zsh", use:bullet-train.zsh-theme, defer:3
	# else
		# ZSH_THEME="bullet-train"
	# fi

	# BULLETTRAIN_PROMPT_ORDER=(
		# # time
		# status
		# custom
		# context
		# dir
		# screen
		# perl
		# ruby
		# virtualenv
		# # nvm
		# aws
		# go
		# rust
		# elixir
		# git
		# hg
		# cmd_exec_time
	  # )
	# BULLETTRAIN_TIME_12HR=true
	# BULLETTRAIN_CONTEXT_DEFAULT_USER="reinaldo"
	# # BULLETTRAIN_IS_SSH_CLIENT=true
# else
# prompt walters
# fi

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

[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases

export IGNORE_FILE="--ignore-file $HOME/.config/ignore-file"

# fzf setup
if [[ -f /usr/bin/fzf ]]; then
	source /usr/share/fzf/key-bindings.zsh

	# Depends on `install fd`
	if [[ -f /usr/bin/fd ]]; then
		export FZF_ALT_C_COMMAND="fd --type directory --hidden --no-ignore-vcs $IGNORE_FILE . /home/reinaldo"
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

# context for resume making
# install context-minimals-git
# mtxrun --generate
[[ -f /opt/context-minimals/setuptex ]] && source /opt/context-minimals/setuptex

# init zplug
if [[ -f $ZPLUG_INIT ]]; then
	# Install plugins if there are plugins that have not been installed
	if ! zplug check --verbose; then
		printf "Install? [y/N]: "
		if read -q; then
			echo; zplug install
		fi
	fi

	# Then, source plugins and add commands to $PATH
	# For errors use --verbose
	zplug load
fi

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Start ssh-agent to cache ssh keys passphrases. Or use an existing one
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! "$SSH_AUTH_SOCK" ]]; then
    eval "$(<"$XDG_RUNTIME_DIR/ssh-agent.env")" > /dev/null || echo "Failed to start ssh-agent"
fi

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
