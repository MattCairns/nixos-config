{
  description = "Matthews System Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim.url = "github:nix-community/nixvim";
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cargo-warp = {
      url = "github:MattCairns/cargo-warp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    codex = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-desktop = {
      url = "github:aaddrick/claude-desktop-debian";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    home-manager,
    ...
  }: let
    user = "matthew";
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    installDesktop = pkgs.callPackage ./scripts/install-desktop.nix {};
  in {
    packages.x86_64-linux = {
      install-desktop = installDesktop;
      hypruse = pkgs.callPackage ./modules/dev/hypruse/package.nix {};
    };
    apps.x86_64-linux = rec {
      install-desktop = {
        type = "app";
        program = "${installDesktop}/bin/install-desktop";
      };
      default = install-desktop;
    };

    nixosConfigurations = import ./machines {
      inherit inputs nixpkgs home-manager user;
    };

    formatter.x86_64-linux = pkgs.alejandra;
  };
}
