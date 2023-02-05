{ config
, pkgs
, ...
}: {
  environment.systemPackages = with pkgs; [
    git
    python3
    gcc12
    clang_14
    clang-tools_14
    cmake

    ## Cpp Analysis
    pre-commit
    cppcheck

    lazygit
    pkg-config
    rnix-lsp
    nixpkgs-fmt
    brightnessctl
    pinentry
  ];

  virtualisation.docker.enable = true;
  users.users.matthew.extraGroups = [ "docker" ];
}
