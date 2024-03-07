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

stdenv.mkDerivation {
  pname = "doublecmd";
  version = "1.1.10";
  src = builtins.fetchTarball {
    url = "https://github.com/doublecmd/doublecmd/releases/download/v${version}/doublecmd-${version}.qt.x86_64.tar.xz";
    sha256 = "sha256-qkswDfudTg8b1xkyAG/VPb3KACqUsbwK4x2AUd1jKfg=";
  };

  nativeBuildInputs = [ makeWrapper ];

  # dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  # installPhase = ''
  #   install -Dm 0755 $src $out/bin/polybar-popup-calendar.sh
  #   wrapProgram $out/bin/polybar-popup-calendar.sh --set PATH \
  #   "${
  #   makeBinPath [
  #   xdotool
  #   yad
  #   coreutils
  #   ]
  #   }"
  # '';

}
