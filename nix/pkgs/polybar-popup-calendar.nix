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
  name = "polybar-popup-calendar";
  version = "1.0";
  src = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/polybar/polybar-scripts/master/polybar-scripts/popup-calendar/popup-calendar.sh";
    hash = "sha256-qkswDfudTg8b1xkyAG/VPb3KACqUsbwK4x2AUd1jKfg=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    install -Dm 0755 $src $out/bin/polybar-popup-calendar.sh
    wrapProgram $out/bin/polybar-popup-calendar.sh --set PATH \
      "${
        makeBinPath [
            xdotool
            yad
          coreutils
        ]
      }"
  '';

  meta = {
    description = "A small script that displays the date and opens a small popup calendar";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
