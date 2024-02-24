{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  home.packages = with pkgs; [
    nixpkgs-fmt
    statix
    nil
  ];
}
