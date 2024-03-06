{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  home.packages = with pkgs; [
    # steam-run .opt/remotepcviewer/remotepcviewer
    steam-run
    dpkg
  ];
}
