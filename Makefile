.PHONY: stow-default stow-default-delete stow-neovim stow-neovim-delete

all: stow-default

stow-default:
	stow -t $(HOME) -S defaults
stow-default-delete:
	stow -t $(HOME) -D defaults
stow-neovim:
	@mkdir -p $(HOME)/.config/nvim
	stow -d defaults/.config -t $(HOME)/.config/nvim -S nvim
stow-neovim-delete:
	stow -d defaults/.config -t $(HOME)/.config/nvim -D nvim
