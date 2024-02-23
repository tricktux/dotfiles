{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  home.packages = with pkgs; [
    pass
    rofi-pass
  ];
}
