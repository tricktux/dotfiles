{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  # Programs for you personal development environment
  home.packages = with pkgs; [
    # neovim related
    # neovim it's at 0.9.5 using arch
    fswatch
    fd
    ripgrep
    tree-sitter

    # cli related
    # https://haseebmajid.dev/posts/2023-08-12-how-sync-your-shell-history-with-atuin-in-nix/
    bat
    fzf
    direnv
    atuin
    ripgrep-all
    stow
    tldr
    unzip
    zip
    xclip
    htop-vim
    ranger
    eza
    wget
    z-lua
    rsync

    nodejs

    delta # lazygit

    # Compression
    atool
    _7zz
    unrar
  ];

  programs = {
    lazygit = {
      enable = true;
      settings = {
        gui = {
          theme.activeBorderColor = [ "yellow" "bold" ];
          commandLogSize = 20;
        };

        git.paging = {
          colorArg = "always";
          pager = "delta --paging=never";
        };
      };
    };
  };
}
