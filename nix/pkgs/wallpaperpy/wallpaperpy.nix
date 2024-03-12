{ lib
, pkgs
, stdenv
, fetchFromGitHub
}:

pkgs.python3Packages.buildPythonPackage rec {
  pname = "wallpaperpy";
  version = "0.1";
  src = lib.sources.cleanSource ./.;
  propagatedBuildInputs = with pkgs; [ feh python3 python3Packages.requests ];
}
