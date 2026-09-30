{
  inputs,
  nixpkgs,
  home-manager,
  user,
  ...
}: let
  commonModules = [
    ../config/base.nix
    ../config/users.nix
    ../config/optin-persistence.nix
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        overwriteBackup = true;
        extraSpecialArgs = {inherit inputs user;};
        sharedModules = [
          inputs.nixvim.homeModules.nixvim
          inputs.sops-nix.homeManagerModules.sops
          inputs.noctalia.homeModules.default
          inputs.cargo-warp.homeManagerModules.default
        ];
        users.${user}.imports = [../config/home.nix];
      };
    }
  ];

  mkHost = modules:
    nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs user;};
      modules = commonModules ++ modules;
    };
in {
  framework = mkHost [
    ./framework/configuration.nix
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
  ];
  desktop = mkHost [./desktop/configuration.nix];
}
