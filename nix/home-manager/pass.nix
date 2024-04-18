{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  home.packages = with pkgs; [
    gnupg
    keepassxc
    # rofi-pass
    pass
    passExtensions.pass-update
    # A pass extension that allows to add files to password-store
    passExtensions.pass-file
    # A pass extension to check against the Have I been pwned API to see if your passwords are publicly leaked or not
    passExtensions.pass-checkup
    # Pass extension that generates memorable passwords
    passExtensions.pass-genphrase
    # Pass extension for auditing your password repository
    passExtensions.pass-audit
  ];

  services.ssh-agent = {
    enable = true;
  };

  services.gpg-agent = {
    # gpgconf --kill gpg-agent && make
    enable = true;
    enableZshIntegration = true;
    defaultCacheTtl = 7200;
    defaultCacheTtlSsh = 7200;
    maxCacheTtl = 86400;
    maxCacheTtlSsh = 86400;
    enableSshSupport = true;
    pinentryFlavor = "gtk2";
  };
}
