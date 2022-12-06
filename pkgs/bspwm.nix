{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
      polybarFull
      picom
  ];
}

