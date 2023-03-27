{ inputs
, config
, pkgs
, ...
}:
let
  python-packages = p:
    with p; [
      pyserial
    ];
in
{
  environment.systemPackages = with pkgs; [
    # Build tools
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

    distrobox
    docker-compose

    # Desktop
    brightnessctl
    pinentry

    # Python
    python3
    (pkgs.python3.withPackages python-packages)

    qmk
    vial

    dfu-util
    dfu-programmer
    (inputs.mrcoverlays.legacyPackages.x86_64-linux.aichat)

    xorg.xdpyinfo
  ];

  virtualisation.docker.enable = true;
}
