{ inputs
, outputs
, lib
, config
, pkgs
, ...
}:
{
  home.packages = with pkgs; [
    polybar-popup-calendar
    jsoncpp
    alsa-utils
    paprefs
    alsa-lib
    wirelesstools
    curl
    jq
    pamixer
    python3
    uair
    procps # uptime -p
    fast-cli
    redshift
    luajit
    xdotool
    galendae
    # polybarFull
  ];

  programs.pywal.enable = true;
}
