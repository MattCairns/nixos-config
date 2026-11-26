{
  lib,
  pkgs,
  config,
  user,
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
  networking.firewall.interfaces.enp34s0 = {
    allowedTCPPorts = [
      8080
      # Sunshine: HTTPS, HTTP, web UI, RTSP
      47984
      47989
      47990
      48010
    ];
    # Sunshine: video, control, audio, mic
    allowedUDPPorts = [47998 47999 48000 48002 48010];
  };

  # Sunshine needs a live graphical session to capture, so log in automatically
  # (the disk is LUKS-encrypted) and force a virtual display since none is plugged in.
  services.displayManager.autoLogin = {
    enable = true;
    inherit user;
  };
  boot.kernelParams = ["video=HDMI-A-1:1920x1080@60e"];
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # KMS capture
  };

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
      # Only fetch the models used by Frigate and Home Assistant.
      "qwen3-vl:4b-instruct"
    ];
  };

  system.stateVersion = "25.05";
}
