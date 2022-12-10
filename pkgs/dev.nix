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
      rnix-lsp
      brightnessctl
  ];
}
