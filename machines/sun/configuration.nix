{ config
, sops
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

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
      nvidia-vaapi-driver
    ];
  };

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    modesetting.enable = true;
    open = true;
  };

  environment.systemPackages = with pkgs; [
    # cudaPackages.cudatoolkit
    # cudaPackages.cudnn
    nfs-utils
    qgroundcontrol
  ];

  fileSystems."/mnt/unraid-appdata" = {
    device = "192.168.1.10:/mnt/user/appdata";
    options = [ "x-systemd.automount" "noauto" ];
  };


  virtualisation.libvirtd.enable = true;
  users.users.matthew.extraGroups = [ "qemu-libvirtd" "libvirtd" ];


  /*
     systemd.services.tdarr = {
    script = ''
      docker-compose -f ${HOME}/.config/docker/tdarr.yml
    '';
    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket"];
    };
  */

  system.stateVersion = "22.11";
}
