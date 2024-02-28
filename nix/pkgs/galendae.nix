{ lib
, pkgs
, stdenv
, fetchFromGitHub
, gtk3
, pkg-config
}:

with lib;

stdenv.mkDerivation {
  name = "galendae";
  version = "1.0";
  src = fetchFromGitHub {
    owner = "chris-marsh";
    repo = "galendae";
    rev = "7cf032bba678c0782412d3407fabdc750f966f3f";
    hash = "sha256-YWlzlVb9ZYecNA1VUbR2onQf9a8XnqT3MEcH6IKsth4=";
  };

  buildInputs = [ gtk3 pkg-config ];

  installPhase = ''
    mkdir --parents "$out"/bin
    cp galendae "$out"/bin
  '';

  meta = {
    description = "A basic popup calendar that can be styled to match workspace themes.";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
