{
  inputs,
  nixpkgs,
  home-manager,
  user,
  ...
}:
let
  inherit (nixpkgs) lib;

  defaultSystem = "x86_64-linux";

  mkPkgs = system:
    import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

  mkHomeManagerModule = { machine, pkgs }:
    {
      home-manager.extraSpecialArgs = {
        inherit user inputs machine;
      };

      home-manager.users.${user}.imports = [
        (import ../config/home.nix)
      ];

      home-manager.backupFileExtension =
        "backup-" + pkgs.lib.readFile "${pkgs.runCommand "timestamp" {} "echo -n `date '+%Y%m%d%H%M%S'` > $out"}";

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.sharedModules = [
        inputs.nixvim.homeModules.nixvim
        inputs.sops-nix.homeManagerModules.sops
      ];
    };

  mkBaseModules = { machine, pkgs }:
    [
      inputs.sops-nix.nixosModules.sops
      home-manager.nixosModules.home-manager
      (mkHomeManagerModule { inherit machine pkgs; })
    ];

  persistenceModule = ../config/optin-persistence.nix;

  hostDefaults = {
    system = defaultSystem;
    useHomeManager = true;
    enablePersistence = true;
    modules = [];
    extraModules = [];
    specialArgs = {};
  };

  mkHost =
    name: hostCfg:
    let
      cfg = lib.recursiveUpdate hostDefaults hostCfg;
      system = cfg.system;
      pkgs = mkPkgs system;

      hmModules =
        if cfg.useHomeManager then
          mkBaseModules { machine = name; inherit pkgs; }
        else
          [];

      persistenceModules =
        lib.optionals cfg.enablePersistence [ persistenceModule ];

      modules =
        cfg.modules
        ++ persistenceModules
        ++ hmModules
        ++ cfg.extraModules;

      specialArgs =
        {inherit inputs user;}
        // cfg.specialArgs;
    in
      lib.nixosSystem {
        inherit system modules specialArgs;
      };

  hosts = {
    framework.modules = [
      ./framework/configuration.nix
      inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    ];

    laptop.modules = [
      ./laptop/configuration.nix
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-l13-yoga
    ];

    nuc.modules = [
      ./nuc/configuration.nix
    ];

    cache-runner = {
      useHomeManager = false;
      enablePersistence = false;
      modules = [
        ./cache-runner/configuration.nix
      ];
    };
  };
in
  lib.mapAttrs mkHost hosts
