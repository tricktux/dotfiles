.PHONY: stow-default

all: stow-default

stow-default:
	stow -t $(HOME) -S defaults
