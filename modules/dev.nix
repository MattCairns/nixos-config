{ inputs
, config
, pkgs
, ...
}:
let
  python-packages = p:
    with p; [
      pyserial
      torch
      numpy
      sentencepiece
    ];
in
{
  environment.systemPackages = with pkgs; [
    # Build tools
    gcc12
    clang_14
    clang-tools_14
    cmake

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
    (pkgs.python3.withPackages python-packages)
    python310Packages.pip
    (python310.withPackages(ps: with ps; [ pyserial torch numpy sentencepiece ]))
    nodePackages_latest.pyright

    # LSP Servers
    nodePackages_latest.pyright
    cmake-language-server
    rnix-lsp

    qmk
    vial

    dfu-util
    dfu-programmer
    (inputs.mrcoverlays.legacyPackages.x86_64-linux.aichat)

    xorg.xdpyinfo
  ];

  virtualisation.docker.enable = true;
  users.users.matthew.extraGroups = [ "docker" ];
}
