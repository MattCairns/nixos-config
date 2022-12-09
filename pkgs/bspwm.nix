{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
      polybarFull
      pywal
      calc
      networkmanager_dmenu
  ];
}

