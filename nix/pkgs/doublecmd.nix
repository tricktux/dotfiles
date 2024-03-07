{ lib
, pkgs
, stdenv
, fetchFromGitHub
, makeWrapper
, xdotool
, yad
, coreutils
}:

with lib;

stdenv.mkDerivation rec {
  pname = "doublecmd";
  version = "1.1.10";
  src = builtins.fetchTarball {
    url = "https://github.com/doublecmd/doublecmd/releases/download/v${version}/doublecmd-${version}.qt.x86_64.tar.xz";
    sha256 = "sha256:0z7f3rh43vmvxrhqr8m5zz6fwmpmzas77hgi0igvj8i7kcn15dj3";
  };

  buildInputs = with pkgs; [ xorg.libX11 ];

  # dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    mkdir -p $out/bin
    cp -r $src/* $out/bin
  '';

}
