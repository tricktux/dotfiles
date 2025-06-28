.PHONY: stow-default stow-default-delete stow-neovim stow-neovim-delete

all: stow-default

stow-default:
	stow -t $(HOME) -S defaults
stow-default-restow:
	stow -t $(HOME) -R defaults
stow-default-delete:
	stow -t $(HOME) -D defaults
stow-neovim:
	@mkdir -p $(HOME)/.config/nvim
	stow -d defaults/.config -t $(HOME)/.config/nvim -S nvim
stow-neovim-delete:
	stow -d defaults/.config -t $(HOME)/.config/nvim -D nvim
stow-neovim-restow:
	stow -d defaults/.config -t $(HOME)/.config/nvim -R nvim
stow-vim:
	@mkdir -p $(HOME)/.config/vim
	stow -d defaults/.config -t $(HOME)/.config/vim -S nvim
lua-fmt:
	stylua --config-path=defaults/.config/nvim/stylua.toml --glob defaults/.config/nvim/**/*.lua
