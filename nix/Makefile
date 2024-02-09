.PHONY: home nixos

USERNAME := $(shell whoami)
HOSTNAME := $(shell hostname)

all: home

home:
	home-manager switch --flake .#$(USERNAME)

nixos:
	sudo nixos-rebuild switch --flake .#$(HOSTNAME)
