{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bspwm
      polybar
      sxhkd
      picom
      rofi
  ];
}

