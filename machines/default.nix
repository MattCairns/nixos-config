{ lib
, inputs
, nixpkgs
, home-manager
, user
, location
, ...
}:
let
  system = "x86_64-linux";

  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  lib = nixpkgs.lib;
in
{
  sun = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs user location; };
    modules = [
      ./sun/configuration.nix
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit user;
        };
        home-manager.users.${user} = {
          imports = [ (import ./home.nix) ];
        };
      }
    ];
  };

  laptop = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs user location; };
    modules = [
      ./laptop/configuration.nix
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit user;
        };
        home-manager.users.${user} = {
          imports = [ (import ./home.nix) ];
        };
      }
    ];
  };

  nuc = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs user location; };
    modules = [
      ./nuc/configuration.nix
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit user;
        };
        home-manager.users.${user} = {
          imports = [ (import ./home.nix) ];
        };
      }
    ];
  };

  cache-runner = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs user location; };
    modules = [
      ./cache-runner/configuration.nix
    ];
  };
}
