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
    kitty
    termite

    shellcheck
    shfmt
  ];
}
