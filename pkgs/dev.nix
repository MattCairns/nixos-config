{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
      git
      python3
      gcc12
      clang
      cppcheck
      cmake
      gnumake
      lazygit
      pkg-config
      brightnessctl
      rnix-lsp
  ];
}
