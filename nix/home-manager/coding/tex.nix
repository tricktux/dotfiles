{ inputs
, outputs
, lib
, config
, pkgs
, tpkgs
, ...
}: {
  programs.texlive = {
    enable = true;
    extraPackages = tpkgs: {
      inherit (tpkgs) collection-basic;
      inherit (tpkgs) collection-latex;
      inherit (tpkgs) collection-latexrecommended;
      inherit (tpkgs) collection-latexextra;
      inherit (tpkgs) collection-luatex;
      inherit (tpkgs) collection-fontsrecommended;
      inherit (tpkgs) collection-fontsextra;
    };
  };
}
