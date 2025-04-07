{
  inputs,
  nixpkgs,
  home-manager,
  user,
  ...
}: let
  system = "x86_64-linux";

  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  lib = nixpkgs.lib;
in {
  framework = lib.nixosSystem {
    inherit system;
    specialArgs = {inherit inputs user;};
    modules = [
      ./framework/configuration.nix
      ../config/optin-persistence.nix
      inputs.nixos-hardware.nixosModules.framework-13-7040-amd
      inputs.sops-nix.nixosModules.sops
      home-manager.nixosModules.home-manager
      {
        home-manager.extraSpecialArgs = let
          machine = "framework";
        in {
          inherit user inputs machine;
        };
        home-manager.users.${user} = {
          imports = [(import ../config/home.nix)];
        };
        home-manager.backupFileExtension = "backup-" + pkgs.lib.readFile "${pkgs.runCommand "timestamp" {} "echo -n `date '+%Y%m%d%H%M%S'` > $out"}";
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.sharedModules = [
          inputs.nixvim.homeManagerModules.nixvim
          inputs.sops-nix.homeManagerModules.sops
        ];
      }
    ];
  };

  laptop = lib.nixosSystem {
    inherit system;
    specialArgs = {inherit inputs user;};
    modules = [
      ./laptop/configuration.nix
      ../config/optin-persistence.nix
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-l13-yoga
      inputs.sops-nix.nixosModules.sops
      home-manager.nixosModules.home-manager
      {
        home-manager.extraSpecialArgs = let
          machine = "laptop";
        in {
          inherit user inputs machine;
        };
        home-manager.users.${user} = {
          imports = [(import ../config/home.nix)];
        };
        home-manager.backupFileExtension = "backup-" + pkgs.lib.readFile "${pkgs.runCommand "timestamp" {} "echo -n `date '+%Y%m%d%H%M%S'` > $out"}";
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
    ];
  };

  nuc = lib.nixosSystem {
    inherit system;
    specialArgs = {inherit inputs user;};
    modules = [
      # inputs.nixos-hardware.nixosModules.intel-nuc-8i7beh
      ./nuc/configuration.nix
      ../config/optin-persistence.nix
      inputs.sops-nix.nixosModules.sops
      home-manager.nixosModules.home-manager
      {
        home-manager.extraSpecialArgs = let
          machine = "nuc";
        in {
          inherit user inputs machine;
        };
        home-manager.users.${user} = {
          imports = [(import ../config/home.nix)];
        };
        home-manager.backupFileExtension = "backup-" + pkgs.lib.readFile "${pkgs.runCommand "timestamp" {} "echo -n `date '+%Y%m%d%H%M%S'` > $out"}";
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
    ];
  };

  cache-runner = lib.nixosSystem {
    inherit system;
    specialArgs = {inherit inputs user pkgs;};
    modules = [
      ./cache-runner/configuration.nix
    ];
  };
}
