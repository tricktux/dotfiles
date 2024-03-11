{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  home.packages = with pkgs; [
    pcmanfm
    xfce.xfconf
    glib
  ];
}
