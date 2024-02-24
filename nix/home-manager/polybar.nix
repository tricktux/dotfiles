{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  home.packages = with pkgs; [
    jsoncpp
    polybar
    alsa-utils
    paprefs
    alsa-lib
    wirelesstools
    curl
    pywal
    killall
    # TODO
    # galendae-git
  ];
}
