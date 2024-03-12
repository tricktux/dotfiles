# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs ? import <nixpkgs> { } }: rec {
  polybar-popup-calendar = pkgs.callPackage ./polybar-popup-calendar.nix { };
  galendae = pkgs.callPackage ./galendae.nix { };
  remotepc = pkgs.callPackage ./remotepc.nix { };
  wallpaperpy = pkgs.callPackage ./wallpaperpy/wallpaperpy.nix { };
}
