{ inputs
, outputs
, lib
, config
, pkgs
, ...
}:
{
  home.packages = with pkgs; [
    i3lock-fancy-rapid
    lxappearance
    alttab
    restic
    xdotool
    feh
    redshift
    qrencode
    xclip
    dunst
    libnotify
    scrot
    flameshot
    tdrop
    ncpamixer
    qalculate-qt
    picom
    # mimeo to handle default applications
    # keyword: xdg-open
    mimeo
    xdg-utils
    # TODO
    xdg-ninja
  ];
}
