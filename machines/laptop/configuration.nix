{ config
, pkgs
, inputs
, ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../config/base.nix
    ../../config/users.nix
  ];

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ "/home/matthew/.ssh/id_ed25519" ];
  sops.secrets.user-matthew-password.neededForUsers = true;

  #:Wusers.users.matthew.passwordFile = config.sops.secrets.user-matthew-password.path;
  users.users.matthew.passwordFile = "/persist/passwords/matthew";
  users.users.root.passwordFile = "/persist/passwords/root";

  networking.hostName = "laptop";
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable touchpad support
  services.xserver.libinput.enable = true;

  # Fingerprint
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-vfs0090;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.xscreensaver.fprintAuth = true;

  # Kernel mods optimize thinkpad
  boot.initrd.availableKernelModules = [ "nvme" "ehci_pci" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "thinkpad_acpi" ];
  boot.initrd.kernelModules = [ "acpi_call" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  ## Random usb-eth devices
  # networking.interfaces.enp0s13f0u3.ipv4.addresses = [{
  #   address = "192.168.1.20";
  #   prefixLength = 24;
  # }];
  networking.defaultGateway = "192.168.20.1";
  networking.interfaces.enp0s20f0u1.ipv4.addresses = [{
    address = "192.168.20.21";
    prefixLength = 24;
  }];

  fileSystems."/mnt/backup" = {
    device = "192.168.1.10:/mnt/user/backup";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };

  system.stateVersion = "22.11";
}
