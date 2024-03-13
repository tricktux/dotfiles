{ config, pkgs, callPackage, ... }:

{
  programs.noisetorch.enable = true;
  # Needed to fix home-manager/guis.nix#gtk.enable
  programs.dconf.enable = true;
  programs.nm-applet = {
    enable = true;
    indicator = true;
  };
  programs.xss-lock = {
    enable = true;
    lockerCommand = "${pkgs.i3lock-fancy-rapid}/bin/i3lock-fancy-rapid";
  };
  qt = {
    enable = true;
    platformTheme = "gtk2";
    style = "gtk2";
  };
  hardware.brillo.enable = true;
  services.picom.enable = true;
  services.xserver = {
    enable = true;

    desktopManager = {
      xfce.enable = true;
    };

    # Touchpad
    libinput.enable = true;
    libinput.touchpad.tapping = true;

    displayManager = {
      defaultSession = "none+i3";
      lightdm.enable = true;
      autoLogin.enable = true;
      autoLogin.user = "reinaldo";
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        rofi #application launcher most people use
        # https://nixos.wiki/wiki/Samba
        lxqt.lxqt-policykit
        i3lock-fancy-rapid
        lxappearance
        alttab
        restic
        xdotool
        feh
        redshift
        qrencode
        xclip
        dunst
        libnotify
        scrot
        flameshot
        tdrop
        ncpamixer
        qalculate-qt
        picom
        # mimeo to handle default applications
        # keyword: xdg-open
        mimeo
        xdg-utils
        # TODO
        xdg-ninja
      ];
    };
  };
  # ...
}
