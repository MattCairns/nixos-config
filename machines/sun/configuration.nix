{ config
, pkgs
, ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../config/base.nix
    ../../config/users.nix
  ];

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
    cudaPackages.cudatoolkit
    cudaPackages.cudnn
    nfs-utils
  ];

  fileSystems."/mnt/unraid-appdata" = {
    device = "192.168.1.10:/mnt/user/appdata";
    options = [ "x-systemd.automount" "noauto" ];
  };


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
