.PHONY: home nixos clean upgrade help maintenance doublecmd

USERNAME := $(shell whoami)
HOSTNAME := $(shell hostname)

all: home

maintenance: upgrade clean

help:
	nixos-help
	# man configuration
	# man home-configuration

doublecmd:
	nix build ".#doublecmd" -L

upgrade:
	sudo -i nix upgrade-nix
	sudo nix-channel --update
	sudo nixos-rebuild switch --upgrade --flake .#$(HOSTNAME)
	$(MAKE) home

home:
	home-manager switch --flake ".#$(USERNAME)@$(HOSTNAME)" -b bkp --option eval-cache false

nixos:
	sudo nixos-rebuild switch --flake .#$(HOSTNAME)

clean:
	nix-env --delete-generations +10
	nix-collect-garbage --delete-old
	nix-store --optimise
	nix-store --verify --check-contents
