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
  hardware.opengl.enable = true;
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    open = true;
  };

  nix = {
  	package = pkgs.nixFlakes;
  	extraOptions = "experimental-features = nix-command flakes";
  };
}
