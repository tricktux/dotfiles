{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  home.packages = with pkgs; [
    acpi
    lm_sensors
    tldr
    atool
    ffmpeg
    highlight
    libcaca
    python312Packages.pillow
    direnv
# kitty
    termite
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    cascadia-code
    inconsolata
    inconsolata-nerdfont
    # polybar
    font-awesome_5
    weather-icons
    iosevka
    # ----
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
  ];
}
