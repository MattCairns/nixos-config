{ config, pkgs, ... }:
{
  imports =
    [ 
      ./hardware-configuration.nix
      ../../config/base.nix
      ../../config/users.nix
      ../../pkgs/dev.nix
    ];

  networking.hostName = "laptop"; 

# Enable touchpad support 
  services.xserver.libinput.enable = true;

  nix = {
  	package = pkgs.nixFlakes;
	  extraOptions = "experimental-features = nix-command flakes";
  };
}
