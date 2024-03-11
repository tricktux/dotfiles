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
  ];

  programs.pywal.enable = true;
  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      i3Support = true;
      alsaSupport = true;
      mpdSupport = true;
      githubSupport = true;
    };
    script = ''
      "$HOME"/.config/polybar/scripts/launch.sh
    '';
  };
}
