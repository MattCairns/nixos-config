{ lib, inputs, nixpkgs, home-manager, user, location, hyprland, ... }:

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
    specialArgs = {
      inherit inputs user location;
      host = {
        hostName = "desktop";
        mainMonitor = "DP-1";
        secondMonitor = "DP-2";
      };
    };                                                      
    modules = [                                             
      hyprland.nixosModules.default
      ./sun/configuration.nix

      /* home-manager.nixosModules.home-manager {         
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit user;
          host = {
            hostName = "sun";     
            mainMonitor = "HDMI-A-3"; #HDMIA3         | HDMI-A-1
            secondMonitor = "DP-1";   #DP1            | DisplayPort-1
          };
        };                                                  # Pass flake variable
        home-manager.users.${user} = {
          imports = [(import ./home.nix)] ++ [(import ./desktop/home.nix)];
        };
      } */
    ];
  };

  laptop = lib.nixosSystem {                                # Laptop profile
    inherit system;
    specialArgs = {
      inherit inputs user location hyprland;
      host = {
        hostName = "desktop";
        mainMonitor = "eDP-1";
      };
    };
    modules = [
      hyprland.nixosModules.default
      ./laptop/configuration.nix
/*
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit user;
          host = {
            hostName = "desktop";
            mainMonitor = "eDP-1";
          };
        };
        home-manager.users.${user} = {
          imports = [(import ./home.nix)] ++ [(import ./laptop/home.nix)];
        };
      } */
    ];
  };
}
