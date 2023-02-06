{
  config,
  pkgs,
  user,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../config/base.nix
    ../../config/users.nix
    ../../pkgs/dev.nix
  ];

  networking.hostName = "sun";

  # Enable touchpad support
  services.xserver.libinput.enable = true;

  services.xserver.videoDrivers = ["nvidia"];
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

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  environment.systemPackages = with pkgs; [
    moonlight-qt
    sunshine
  ];

  /* systemd.services.tdarr = {
    script = ''
      docker-compose -f ${HOME}/.config/docker/tdarr.yml
    '';
    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket"];
  }; */

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
  };
}
