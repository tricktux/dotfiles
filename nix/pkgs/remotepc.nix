{ lib
, pkgs
, stdenv
}:

with lib;

stdenv.mkDerivation {
  pname = "remotepc";
  version = "4.17.7";
  src = pkgs.fetchurl {
    url = "https://download.remotepc.com/downloads/rpc/310320/remotepcviewer.deb";
    hash = "sha256-XBbQtFk4ZZIi7Bzaz7pTs5/qUUDHNs6h5WrMNz7A3gE=";
  };

  unpackPhase = "dpkg-deb -x $src .";
  nativeBuildInputs = with pkgs; [
    dpkg
    autoPatchelfHook
    wrapGAppsHook
  ];

  buildInputs = with pkgs; [
    glibc
    gcc-unwrapped
    libdrm
    nwjs
  ];

  runtimeDependencies = [
    pkgs.ffmpeg
  ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/opt
    cp -r usr $out
    cp -r usr/share $out/share
    # cp -r opt/remotepcviewer/* $out/bin
    cp -r opt/* $out/opt
    ln -s $out/opt/remotepcviewer/remotepcviewer $out/bin
  '';
}
