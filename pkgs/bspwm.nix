{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
      polybar
      picom
  ];
}

