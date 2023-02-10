{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../config/base.nix
    ../../config/users.nix
    ../../pkgs/dev.nix
  ];

  networking.hostName = "nuc";
  hardware.bluetooth.enable = true;

  # Enable TLP
  /*
  services.tlp.enable = true;
  */
  # Fingerprint
  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.xscreensaver.fprintAuth = true;
}
