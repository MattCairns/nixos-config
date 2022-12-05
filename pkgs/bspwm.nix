{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    bspwm
      polybar
      sxhkd
      picom
      rofi
  ];
}

