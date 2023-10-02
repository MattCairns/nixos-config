{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../config/base.nix
    ../../config/users.nix
  ];
  users.users.matthew.hashedPasswordFile = "/persist/passwords/matthew";
  users.users.root.hashedPasswordFile = "/persist/passwords/root";

  networking.hostName = "nuc";
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  system.stateVersion = "22.11";
}
