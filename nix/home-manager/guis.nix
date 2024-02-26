{ inputs
, outputs
, lib
, config
, pkgs
, ...
}:
let
  bibata_name = "Bibata-Modern-DarkRed";
  bibata_pkg = pkgs.runCommand "moveUp" { } ''
    mkdir -p $out/share/icons
    ln -s ${pkgs.fetchzip {
    url = "https://github.com/ful1e5/Bibata_Extra_Cursor/releases/download/v1.0.1/Bibata-Modern-DarkRed.tar.gz";
    hash = "sha256-jpEuovyLr9HBDsShJo1efRxd21Fxi7HIjXtPJmLQaCU=";
    }} $out/share/icons/${bibata_name}
  '';
in
{
  home.packages = with pkgs; [
    meld
    zeal
    dconf
    lxappearance
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
      name = bibata_name;
      package = bibata_pkg;
    };
  };

  home.file.".icons/default/index.theme".text = ''
    [icon theme]
    Inherits=${bibata_name}
  '';

  home.pointerCursor = {
    name = bibata_name;
    size = 32;
    package = bibata_pkg;
  };
}
