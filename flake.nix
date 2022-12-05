{
  description = "Matthews System Flake";

  inputs =                                                                  
    {
      home-manager = {                                                     
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      hyprland = {
        url = "github:vaxerski/Hyprland";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

  outputs = inputs @ { self, nixpkgs, home-manager, hyprland, ... }:   
    let                                                                     
      user = "matthew";
      location = "$HOME/.setup";
    in                                                                      
    {
      nixosConfigurations = (                                               
        import ./machines {                                                    
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs home-manager user location hyprland;   
        }
      );

      homeConfigurations = (                                               
        import ./nix {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs home-manager user;
        }
      );
    };
}
