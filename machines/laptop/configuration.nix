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
    ];

  networking.hostName = "laptop"; 

# Enable touchpad support 
  services.xserver.libinput.enable = true;
}
