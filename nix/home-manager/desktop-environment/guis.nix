{ inputs
, outputs
, lib
, config
, pkgs
, ...
}:
let
  cursor_name = "Bibata-Modern-DarkRed";
  cursor_pkg = pkgs.runCommand "moveUp" { } ''
    mkdir -p $out/share/icons
    ln -s ${pkgs.fetchzip {
    url = "https://github.com/ful1e5/Bibata_Extra_Cursor/releases/download/v1.0.1/Bibata-Modern-DarkRed.tar.gz";
    hash = "sha256-Vqyb0wT7dh3aPdeKqksx/ISxuLQUSLE9V7e9N+FPB6I=";
    }} $out/share/icons/${cursor_name}
  '';
in
{
  services = {
    nextcloud-client = {
      enable = true;
      startInBackground = true;
    };
  };

  home.packages = with pkgs; [
    meld
    zeal
    dconf
    teams-for-linux
    networkmanagerapplet
    remmina
    evolution
    doublecmd
    peazip
    libreoffice-fresh
    hunspell
    anki-bin
    pinta
    obsidian
    baobab
  ];

  gtk = {
    enable = true;

    iconTheme = {
      name = "Paper-Mono-Dark";
      package = pkgs.paper-icon-theme;
    };

    theme = {
      name = "Paper";
      package = pkgs.paper-icon-theme;
    };

    cursorTheme = {
      name = cursor_name;
      package = cursor_pkg;
    };
  };

  home.file.".icons/default/index.theme".text = ''
    [icon theme]
    Inherits=${cursor_name}
  '';

  home.pointerCursor = {
    name = cursor_name;
    size = 32;
    package = cursor_pkg;
  };
}
