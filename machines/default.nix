{ lib
, inputs
, nixpkgs
, test-nixpkgs
, home-manager
, mrcpkgs
, user
, ...
}:
let
  system = "x86_64-linux";

  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  test-pkgs = import test-nixpkgs {
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
    specialArgs = { inherit inputs user; };
    modules = [
      ./sun/configuration.nix
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit user mrc test-pkgs;
        };
        home-manager.users.${user} = {
          imports = [ (import ../config/home.nix) ];
        };
      }
    ];
  };

  laptop = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs user; };
    modules = [
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
    specialArgs = { inherit inputs user; };
    modules = [
      inputs.nixos-hardware.nixosModules.intel-nuc-8i7beh
      ./nuc/configuration.nix
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit user mrc test-pkgs;
        };
        home-manager.users.${user} = {
          imports = [ (import ../config/home.nix) ];
        };
      }
    ];
  };

  cache-runner = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs user; };
    modules = [
      ./cache-runner/configuration.nix
    ];
  };
}
