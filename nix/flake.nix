{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
      # Supported systems for your flake packages, shell, etc.
      lib = nixpkgs.lib // home-manager.lib;
      systems = [
        # "aarch64-linux"
        # "i686-linux"
        "x86_64-linux"
        # "aarch64-darwin"
        # "x86_64-darwin"
      ];
      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor = lib.genAttrs systems (system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });
      forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});
    in
    {
      # Your custom packages
      # Accessible through 'nix build', 'nix shell', etc
      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };
      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules = import ./modules/nixos;
      # Reusable home-manager modules you might want to export
      # These are usually stuff you would upstream into home-manager
      homeManagerModules = import ./modules/home-manager;

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = {
        # TODO replace with your hostname
        surbook = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            # > Our main nixos configuration file <
            ./nixos/configuration.nix
            ./nixos/hardware-configuration.surbook.nix
            ./nixos/i3.nix
            ./nixos/video-intel.nix
            ./nixos/nas-mount.nix
            ./nixos/accelerated-video-playback.nix
            ./nixos/hardware-programs.nix
            ./nixos/fonts.nix
            ./nixos/power-management.nix
            ./nixos/pipewire.nix
            ./nixos/bluetooth.nix
            ./nixos/run-executables.nix
            ./nixos/keyboard.nix
          ];
        };
        aero = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            # > Our main nixos configuration file <
            ./nixos/configuration.nix
            ./nixos/hardware-configuration.aero.nix
            ./nixos/accelerated-video-playback-amd.nix
            ./nixos/video-amd.nix
            ./nixos/thunderbolt.nix
            ./nixos/i3.nix
            ./nixos/nas-mount.nix
            ./nixos/hardware-programs.nix
            ./nixos/fonts.nix
            ./nixos/power-management.nix
            ./nixos/pipewire.nix
            ./nixos/bluetooth.nix
            ./nixos/run-executables.nix
            ./nixos/keyboard.nix
            ./nixos/ssh.nix
          ];
        };
      };

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations = {
        # TODO replace with your username@hostname
        "reinaldo@surbook" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            # > Our main home-manager configuration file <
            ./home-manager/home.nix
            ./home-manager/screens-surbook.nix
            ./home-manager/coding
            ./home-manager/zsh.nix
            ./home-manager/terminal.nix
            ./home-manager/pass.nix
            ./home-manager/services.nix
            ./home-manager/xfce.nix
            ./home-manager/polybar.nix
            ./home-manager/guis.nix
            ./home-manager/firefox.nix
            ./home-manager/rofi.nix
          ];
        };
        "reinaldo@aero" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            # > Our main home-manager configuration file <
            ./home-manager/home.nix
            ./home-manager/screens-aero.nix
            ./home-manager/coding
            ./home-manager/zsh.nix
            ./home-manager/terminal.nix
            ./home-manager/pass.nix
            ./home-manager/services.nix
            ./home-manager/xfce.nix
            ./home-manager/polybar.nix
            ./home-manager/guis.nix
            ./home-manager/firefox.nix
            ./home-manager/rofi.nix
          ];
        };
        "reinaldo@xps" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            # > Our main home-manager configuration file <
            ./home-manager/home.nix
            ./home-manager/screens-xps.nix
            ./home-manager/coding
            ./home-manager/pass.nix
            ./home-manager/polybar.nix
            ./home-manager/zsh.nix
          ];
        };
      };
    };
}
