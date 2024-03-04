# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs ? import <nixpkgs> { } }: rec {
  inherit (pkgs.llvmPackages_12) stdenv;
  polybar-popup-calendar = pkgs.callPackage ./polybar-popup-calendar.nix { };
  galendae = pkgs.callPackage ./galendae.nix { };
}
