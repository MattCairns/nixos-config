{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../config/base.nix
    ../../config/users.nix
    ../../modules/dev.nix
  ];

  networking.hostName = "laptop";
  hardware.bluetooth.enable = true;


  # Enable touchpad support
  services.xserver.libinput.enable = true;
  # Enable TLP
  /*
  services.tlp.enable = true;
  */
  # Fingerprint
  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.xscreensaver.fprintAuth = true;
  # Kernel mods optimize thinkpad
  boot.initrd.availableKernelModules = ["nvme" "ehci_pci" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "thinkpad_acpi"];
  boot.initrd.kernelModules = ["acpi_call"];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = with config.boot.kernelPackages; [acpi_call];
}
