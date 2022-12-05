{ config, pkgs, user, ... }:
{
  imports =
    [ 
      ./hardware-configuration.nix
      ../../config/base.nix
      ../../config/users.nix
      ../../pkgs/dev.nix
      ../../modules/desktop/hyprland/default.nix
    ];

  networking.hostName = "sun"; 

# Enable touchpad support 
  services.xserver.libinput.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  services.xserver.screenSection = ''
    Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
    Option         "AllowIndirectGLXProtocol" "off"
    Option         "TripleBuffer" "on"
  '';

  nix = {
  	package = pkgs.nixFlakes;
  	extraOptions = "experimental-features = nix-command flakes";
  };
}
