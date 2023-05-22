{ config
, pkgs
, ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../config/base.nix
    ../../config/users.nix
  ];

  users.users.matthew.passwordFile = "/persist/passwords/matthew";
  users.users.root.passwordFile = "/persist/passwords/root";

  networking.hostName = "sun";
  networking.nameservers = [ "192.168.1.24" ];

  services.xserver.config = ''
    Section "Monitor"
        Identifier "DP-2.8"
        Option "PreferredMode" "2560x1440"
        Option "Primary" "1"
    EndSection
    Section "Monitor"
        Identifier "DP-2.1"
        Option "PreferredMode" "2560x1440"
        Option "RightOf" "DP-2.8"
        Option "Rotate" "right"
    EndSection
  '';

  services.xserver.videoDrivers = [ "nvidia" ];
  boot.blacklistedKernelModules = [ "nouveau" "i2c_nvidia_gpu" ];
  hardware = {
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      modesetting.enable = true;
      open = true;
    };
    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
        nvidia-vaapi-driver
      ];
    };
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
    cudaPackages.cudnn
    nfs-utils
    qgroundcontrol
    vagrant
  ];

  fileSystems."/mnt/unraid-appdata" = {
    device = "192.168.1.10:/mnt/user/appdata";
    options = [ "x-systemd.automount" "noauto" ];
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.enableNvidia = true;
  virtualisation.libvirtd.enable = true;
  users.users.matthew.extraGroups = [ "qemu-libvirtd" "libvirtd" ];

  system.stateVersion = "22.11";
}
