{
  description = "Matthews System Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    mrcoverlays.url = "github:MattCairns/nix-overlays";
    mrcpkgs.url = "github:MattCairns/nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs @ { self
    , nixpkgs
    , nixos-hardware
    , mrcpkgs
    , home-manager
    , ...
    }:
    let
      user = "matthew";
    in
    {
      nixosConfigurations = (
        import ./machines {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs mrcpkgs home-manager user;
        }
      );

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    };
}
