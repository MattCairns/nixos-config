{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../config/base.nix
    ../../config/users.nix
  ];

  networking.hostName = "nuc";
  hardware.bluetooth.enable = true;

  system.stateVersion = "22.11";
}
