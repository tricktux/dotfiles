{ config, pkgs, callPackage, ... }:

{
  #environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw 
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
        rofi #application launcher most people use
        # https://nixos.wiki/wiki/Samba
        lxqt.lxqt-policykit
        xlayoutdisplay
        # i3status # gives you the default i3 status bar
        # i3lock #default i3 screen locker
        # i3blocks #if you are planning on using i3blocks over i3status
      ];
    };
  };
  # ...
}
