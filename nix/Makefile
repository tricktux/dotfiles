.PHONY: home nixos clean log

USERNAME := $(shell whoami)
HOSTNAME := $(shell hostname)

all: home

help:
	nixos-help
	# man configurattion
	# man home-comfiguration

doublecmd:
	nix build ".#doublecmd" -L

upgrade:
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
