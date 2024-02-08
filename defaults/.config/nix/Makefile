.PHONY: home nixos

USERNAME := $(shell whoami)
HOSTNAME := $(shell hostname)

all: home

home:
	home-manager switch --flake .#$(USERNAME)@$(HOSTNAME)

nixos:
	sudo nixos-rebuild switch --flake .#$(HOSTNAME)
