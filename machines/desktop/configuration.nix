{
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    (import ../../config/disko.nix {
      inherit lib;
      disk = "/dev/disk/by-id/nvme-KINGSTON_SA2000M81000G_50026B7282469435";
      swapSize = "32G";
    })
  ];

  networking.hostName = "desktop";

  # Fill in after running nixos-generate-config on the hardware, or set manually.
  # Common NVMe modules: ["nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod" "usbhid"]
  boot = {
    initrd.availableKernelModules = [];
    kernelModules = [];
    extraModulePackages = [];
  };

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
      OLLAMA_CONTEXT_LENGTH = "32768";
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KEEP_ALIVE = "-1";
      OLLAMA_KV_CACHE_TYPE = "q4_0";
      OLLAMA_MAX_LOADED_MODELS = "1";
      OLLAMA_NUM_PARALLEL = "1";
    };
    host = "0.0.0.0";
    openFirewall = true;
    loadModels = [
      "lfm2.5:8b"
      "qwen3-vl:4b-instruct"
      "qwen2.5:7b-instruct-q4_K_M"
      "qwen2.5-coder:7b-instruct"
      "qwen3.5:9b"
      "qwen3:8b"
    ];
  };

  system.stateVersion = "25.05";
}
