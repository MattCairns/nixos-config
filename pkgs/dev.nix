{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
      python3
      gcc12
      cmake
      gnumake
      lazygit
      pkg-config
  ];
}
