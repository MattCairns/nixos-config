{lib, ...}: {
  imports = [
    ../../config/base.nix
    ../../config/users.nix
    (import ../../config/disko.nix {
      inherit lib;
      # Replace with your actual drive ID before running disko:
      #   ls /dev/disk/by-id/
      disk = "/dev/disk/by-id/PLACEHOLDER";
      swapSize = "32G";
    })
  ];

  networking.hostName = "desktop";

  # Fill in after running nixos-generate-config on the hardware, or set manually.
  # Common NVMe modules: ["nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod" "usbhid"]
  boot.initrd.availableKernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "25.05";
}
