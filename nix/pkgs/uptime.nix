{ lib
, stdenv
, fetchFromGitHub
, pkgs
}:

with lib;

stdenv.mkDerivation {
  pname = "uptimerm";
  version = "0.1";
  src = pkgs.fetchzip {
    url = "https://github.com/procps-ng/procps/archive/master.zip";
    sha256 = lib.fakeSha256;
  };

  buildInputs = [
    # pkgs.simgrid
    # pkgs.boost
    # pkgs.cmake
  ];

  configurePhase = ''
    ./autogen.sh
    ./configure
  '';

  buildPhase = ''
    make
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp uptime $out/bin/uptimerm
  '';

  # meta = {
  #   description = "A miniature cava sound visualizer";
  #   homepage = "https://github.com/Misterio77/minicava";
  #   license = licenses.mit;
  #   platforms = platforms.all;
  # };
}
