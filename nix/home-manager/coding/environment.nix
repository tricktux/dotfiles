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
    neovim
    fswatch
    bat
    fd
    fzf
    ripgrep
    ripgrep-all
    tree-sitter

    # cli related
    # https://haseebmajid.dev/posts/2023-08-12-how-sync-your-shell-history-with-atuin-in-nix/
    direnv
    atuin
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

    nodejs
  ];

  programs = {
    # Enable home-manager
    home-manager.enable = true;
    lazygit = {
      enable = true;
      settings = {
        gui = {
          theme.activeBorderColor = [ "yellow" "bold" ];
          commandLogSize = 20;
        };
      };
    };
  };
}
