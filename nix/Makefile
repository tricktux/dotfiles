.PHONY: home nixos clean log

USERNAME := $(shell whoami)
HOSTNAME := $(shell hostname)

all: home

home:
	home-manager switch --flake ".#$(USERNAME)@$(HOSTNAME)" -b bkp --option eval-cache false

nixos:
	sudo nixos-rebuild switch --flake .#$(HOSTNAME)

log:
	nix log ./result

clean:
	nix-env --delete-generations +10
	nix-collect-garbage --delete-old
