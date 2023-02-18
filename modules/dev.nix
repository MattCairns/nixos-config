{
  config,
  pkgs,
  ...
}: let
  my-python-packages = p:
    with p; [
      pyserial
    ];
in {
  environment.systemPackages = with pkgs; [
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

    distrobox

    #nix
    cachix

    # Python
    (pkgs.python3.withPackages my-python-packages)
    python3
  ];

  virtualisation.docker.enable = true;
  users.users.matthew.extraGroups = ["docker"];
}
