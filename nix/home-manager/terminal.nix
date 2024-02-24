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

    # zsh
    zsh
    zsh-autosuggestions
    zsh-completions
    zsh-history-substring-search
    zsh-syntax-highlighting
    zsh-powerlevel10k
    zsh-vi-mode

    shellcheck
    shfmt
  ];
}
