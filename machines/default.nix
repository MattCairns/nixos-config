{ lib, inputs, nixpkgs, home-manager, user, location, ... }:

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
      ./sun/configuration.nix

      home-manager.nixosModules.home-manager {         
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit user;
          host = {
            hostName = "sun";     
            mainMonitor = "DP-1"; 
            secondMonitor = "DP-2";   
          };
        };                                                  
        home-manager.users.${user} = {
          /* imports = [(import ./home.nix)] ++ [(import ./desktop/home.nix)]; */
          imports = [(import ./home.nix)];
        };
      }
    ];
  };

  laptop = lib.nixosSystem {                                
    inherit system;
    specialArgs = {
      inherit inputs user location;
      host = {
        hostName = "desktop";
        mainMonitor = "eDP-1";
      };
    };
    modules = [
      ./laptop/configuration.nix

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
          /* imports = [(import ./home.nix)] ++ [(import ./laptop/home.nix)]; */
          imports = [(import ./home.nix)] ;
        };
      }
    ];
  };
}
