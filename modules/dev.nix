{ inputs
, config
, pkgs
, ...
}:
let
in
{
  environment.systemPackages = with pkgs; [
    ## Cpp Analysis
    pre-commit
    cppcheck

    lazygit
    nixpkgs-fmt
    cmake-format

    distrobox
    docker-compose

    # Desktop
    brightnessctl

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
