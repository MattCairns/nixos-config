{
  description = "Matthews System Flake";

  inputs =                                                                  
    {
      home-manager = {                                                     
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

  outputs = inputs @ { self, nixpkgs, home-manager, ... }:   
    let                                                                     
      user = "matthew";
      location = "$HOME/.setup";
    in                                                                      
    {
      nixosConfigurations = (                                               
        import ./machines {                                                    
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs home-manager user location;   
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
