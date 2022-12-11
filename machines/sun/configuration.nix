{ config, pkgs, user, ... }:
{
  imports =
    [ 
      ./hardware-configuration.nix
      ../../config/base.nix
      ../../config/users.nix
      ../../pkgs/dev.nix
    ];

  networking.hostName = "sun"; 

# Enable touchpad support 
  services.xserver.libinput.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    open = true;
  };

  nix = {
  	package = pkgs.nixFlakes;
  	extraOptions = "experimental-features = nix-command flakes";
  };
}
