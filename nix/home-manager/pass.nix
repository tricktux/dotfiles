{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  home.packages = with pkgs; [
    keepassxc
    rofi-pass
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
}
