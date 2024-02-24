{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  home.packages = with pkgs; [
    markdownlint-cli
    write-good
    proselint
    vale
    marksman
    plantuml
    pandoc
  ];
}
