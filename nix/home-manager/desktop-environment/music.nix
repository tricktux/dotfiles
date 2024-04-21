{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  home.packages = with pkgs; [
    pavucontrol
    playerctl
    ncpamixer
    ytmdl
    ytfzf
    cmus
  ];

  # services.easyeffects.enable = true;
  services.playerctld.enable = true;
}
