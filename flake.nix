{
  description = "Matthews System Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # hyprland = {
    #   type = "git";
    #   url = "https://github.com/hyprwm/Hyprland";
    #   submodules = true;
    # };
    hyprpaper.url = "github:hyprwm/hyprpaper";
    hyprpaper.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.url = "github:nix-community/nixvim";
    ghostty.url = "github:ghostty-org/ghostty";
    talon-nix = {
      url = "github:nix-community/talon-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    talon-community = {
      url = "github:talonhub/community";
      flake = false;
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      # hyprland,
      hyprpaper,
      nixvim,
      ...
    }:
    let
      user = "matthew";
    in
    {
      nixosConfigurations = (
        import ./machines {
          inherit (nixpkgs) lib;
          inherit
            inputs
            nixpkgs
            home-manager
            # hyprland
            user
            ;
        }
      );

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    };
}
