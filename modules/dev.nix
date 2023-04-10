{ inputs
, config
, pkgs
, ...
}:
let
in
{
  environment.systemPackages = with pkgs; [
    # Build tools
    gcc12
    clang_14
    clang-tools_14
    cmake
    cmake-format

    # rust
    cargo
    rustc

    ## Cpp Analysis
    pre-commit
    (inputs.mrcoverlays.legacyPackages.x86_64-linux.gptcommit)
    cppcheck

    lazygit
    git-crypt
    pkg-config
    nixpkgs-fmt

    distrobox
    docker-compose

    # Desktop
    brightnessctl
    pinentry

    # Python
    python3
    python310Packages.pip

    # LSP Servers
    nodePackages_latest.pyright
    cmake-language-server
    rnix-lsp

    # Keyboards
    qmk
    vial

    dfu-util
    dfu-programmer
    (inputs.mrcoverlays.legacyPackages.x86_64-linux.aichat)
  ];

  virtualisation.docker.enable = true;
  users.users.matthew.extraGroups = [ "docker" ];
}
