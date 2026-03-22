{
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    ../../config/base.nix
    ../../config/users.nix
    (import ../../config/disko.nix {
      inherit lib;
      disk = "/dev/disk/by-id/nvme-KINGSTON_SA2000M81000G_50026B7282469435";
      swapSize = "32G";
    })
  ];

  users.users.matthew.hashedPasswordFile = "/persist/passwords/matthew";
  users.users.root.hashedPasswordFile = "/persist/passwords/root";

  networking.hostName = "desktop";

  # Fill in after running nixos-generate-config on the hardware, or set manually.
  # Common NVMe modules: ["nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod" "usbhid"]
  boot.initrd.availableKernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # NVIDIA drivers
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  services.xserver.videoDrivers = ["nvidia"];

  # Ollama (CUDA-accelerated, LAN-accessible)
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "16384";
    };
    host = "0.0.0.0";
    openFirewall = true;
    loadModels = [
      "qwen2.5:7b-instruct-q4_K_M"
      "qwen2.5-coder:7b-instruct"
      "qwen3.5:9b"
      "qwen3:8b"
    ];
  };

  system.stateVersion = "25.05";
}
