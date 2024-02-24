{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  home.packages = with pkgs; [
    luajit
    stylua
    lua-language-server
  ];
}
