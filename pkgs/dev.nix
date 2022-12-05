{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
      python3
      ccache
      gcc12
      cmake
      gnumake
      lazygit
  ];
}
