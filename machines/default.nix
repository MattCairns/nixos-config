{ lib
, inputs
, nixpkgs
, home-manager
, mrcpkgs
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

  mrc = import mrcpkgs {
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
          inherit user mrc;
        };
        home-manager.users.${user} = {
          imports = [ (import ../config/home.nix) ];
        };
      }
    ];
  };

  laptop = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs user location; };
    modules = [
      inputs.agenix.nixosModules.default
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-l13-yoga
      ./laptop/configuration.nix
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit user mrc;
        };
        home-manager.users.${user} = {
          imports = [ (import ../config/home.nix) ];
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
          inherit user mrc;
        };
        home-manager.users.${user} = {
          imports = [ (import ../config/home.nix) ];
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
