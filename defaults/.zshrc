# The following lines were added by compinstall

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' max-errors 2
# Autocompletion for sudo
zstyle ':completion::complete:*' gain-privileges 1
zstyle :compinstall filename '/home/reinaldo/.zshrc'

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
# prompt walters

# Autocompletion for aliases
setopt COMPLETE_ALIASES

# Syntax highlight
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# oh-my-zsh

# Path to your oh-my-zsh installation.
ZSH=/usr/share/oh-my-zsh/

if [[ "$TERM" != "linux" && `uname -o` != "Android" ]]; then
	BULLETTRAIN_TIME_12HR=true
	BULLETTRAIN_CONTEXT_DEFAULT_USER=reinaldo
	BULLETTRAIN_IS_SSH_CLIENT=true
	BULLETTRAIN_PROMPT_ORDER=(
		time
		status
		custom
		context
		dir
		screen
		perl
		ruby
		virtualenv
		# nvm
		aws
		go
		rust
		elixir
		git
		hg
		cmd_exec_time
	  )
	# Theme
	ZSH_THEME="bullet-train"
fi
# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="false"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"
	
# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(
	git
	docker
	dotenv
	history-substring-search
	sudo # ESC twice to insert sudo
	command-not-found # Doesnt work with pacman :(
)

# Key bindings for the history substring search
bindkey '' history-substring-search-up
bindkey '' history-substring-search-down

ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
	mkdir $ZSH_CACHE_DIR
fi

source $ZSH/oh-my-zsh.sh

[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases

# fzf setup
if [[ -f /usr/bin/fzf ]]; then
	source /usr/share/fzf/key-bindings.zsh
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

