{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  programs.texlive = {
    enable = true;
  };
}
