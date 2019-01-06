# The following lines were added by compinstall

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

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# This will set the default prompt to the walters theme
# prompt walters

# Autocompletion for aliases
setopt COMPLETE_ALIASES

# Syntax highlight
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# oh-my-zsh

# Path to your oh-my-zsh installation.
ZSH=/usr/share/oh-my-zsh/

# Theme
ZSH_THEME="bullet-train"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

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
)

ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
	mkdir $ZSH_CACHE_DIR
fi

source $ZSH/oh-my-zsh.sh

[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases

