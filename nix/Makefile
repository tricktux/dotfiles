.PHONY: home nixos clean upgrade help maintenance doublecmd nix-remove

USERNAME := $(shell whoami)
HOSTNAME := $(shell hostname)
# Variable with date
bkp := $(shell date +%F_%R)

all: home

maintenance: upgrade-home clean

help:
	nixos-help
	# https://nixos.org/manual/nixpkgs/unstable/
	# man configuration
	# man home-configuration

doublecmd:
	nix build ".#doublecmd" -L

upgrade-home:
	nix-channel --update
	$(MAKE) home

upgrade-nixos:
	# sudo -i nix upgrade-nix
	sudo nix-channel --update
	sudo nixos-rebuild switch --upgrade --flake .#$(HOSTNAME)
	$(MAKE) home

home:
	home-manager switch --flake ".#$(USERNAME)@$(HOSTNAME)" -b "$(bkp)" --option eval-cache false --show-trace

nixos:
	sudo nixos-rebuild switch --flake .#$(HOSTNAME)

clean:
	nix-env --delete-generations +20
	nix-collect-garbage --delete-old

deep-clean:
	nix-store --optimise
	nix-store --verify --check-contents

boot-errors:
	journalctl --user -b

nix-remove:
	sudo rm -rf /nix/
	rm -rf ~/.nix-channels ~/.nix-defexpr ~/.nix-profile
