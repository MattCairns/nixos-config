{ config, pkgs, ... }:
{
  imports =
    [ 
    /etc/nixos/hardware-configuration.nix
      ../../config/base.nix
      ../../config/users.nix
      ../../pkgs/essentials.nix
      ../../pkgs/essentials.nix
      ../../pkgs/dev.nix
      ../../pkgs/neovim.nix
      ../../pkgs/bspwm.nix
    ];

  networking.hostName = "sun"; 

# Enable touchpad support 
  services.xserver.libinput.enable = true;

  nix = {
  	package = pkgs.nixFlakes;
  	extraOptions = "experimental-features = nix-command flakes";
  };
}
