{
  description = "Matthews System Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/hyprland";
  };

  outputs = inputs @ {
    nixpkgs,
    home-manager,
    hyprland,
    ...
  }: let
    user = "matthew";
  in {
    nixosConfigurations = (
      import ./machines {
        inherit (nixpkgs) lib;
        inherit inputs nixpkgs home-manager hyprland user;
      }
    );

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
  };
}
