{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  home.packages = with pkgs; [
    rofi
  ];
  home.file.".local/share/rofi/Adapta-Nokto.rasi".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/davatorium/rofi/next/themes/Adapta-Nokto.rasi";
    hash = "sha256-5CQJrVTiklMN5ZwV4jK8rQnHCYJitpcXsfBL1dxUdqQ=";
  };
}
