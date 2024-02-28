{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  home.packages = with pkgs; [
    nix-prefetch-git
    nixpkgs-fmt
    statix
    nil
  ];
}
