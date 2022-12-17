{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
      git
      python3
      gcc12
      clang_14
      cppcheck
      cmake
      gnumake
      lazygit
      pkg-config
      rnix-lsp
      brightnessctl
  ];
}
