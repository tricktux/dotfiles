{ config, pkgs, lib, callPackage, ... }:
{
  # Needed to fix home-manager/guis.nix#gtk.enable
  programs.dconf.enable = true;
  hardware.brillo.enable = true;
  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false;
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
        # https://nixos.wiki/wiki/Samba
        lxqt.lxqt-policykit
        i3lock-fancy-rapid
        rofi
        alttab
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
        xss-lock
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
