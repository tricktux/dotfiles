.PHONY: home nixos clean

USERNAME := $(shell whoami)
HOSTNAME := $(shell hostname)

all: home

home:
	home-manager switch --flake .#$(USERNAME)

nixos:
	sudo nixos-rebuild switch --flake .#$(HOSTNAME)

clean:
	nix-env --delete-generations +10
	nix-collect-garbage --delete-old
