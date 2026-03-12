{
  description = "Matthews System Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim.url = "github:nix-community/nixvim";
    talon-nix = {
      url = "github:nix-community/talon-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    talon-community = {
      url = "github:talonhub/community";
      flake = false;
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    worktrunk.url = "github:max-sixty/worktrunk";
    cargo-warp = {
      url = "github:MattCairns/cargo-warp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    opencode = {
      url = "github:anomalyco/opencode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    home-manager,
    ...
  }: let
    user = "matthew";
  in rec {
    nixosConfigurations = (
      import ./machines {
        inherit (nixpkgs) lib;
        inherit
          inputs
          nixpkgs
          home-manager
          user
          ;
      }
    );

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    checks.x86_64-linux = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      only-known-hosts-exist = pkgs.runCommand "check-only-known-hosts-exist" {} ''
        ${pkgs.lib.concatStringsSep "\n" (
          map (name: ''
            echo "FAIL: unexpected configuration '${name}' found"
            exit 1
          '') (builtins.filter (n: !builtins.elem n ["framework" "desktop"]) (builtins.attrNames nixosConfigurations))
        )}
        echo "PASS" > $out
      '';
      framework-amd-params = pkgs.runCommand "check-framework-amd-params" {} ''
        grep -q "amdgpu.dc=1" ${./machines/framework/configuration.nix} || { echo "FAIL"; exit 1; }
        grep -q "amdgpu.gpu_recovery=1" ${./machines/framework/configuration.nix} || { echo "FAIL"; exit 1; }
        echo "PASS" > $out
      '';
      framework-hostname = pkgs.runCommand "check-framework-hostname" {} ''
        grep -q 'networking.hostName = "framework"' ${./machines/framework/configuration.nix} || { echo "FAIL"; exit 1; }
        echo "PASS" > $out
      '';
    };
  };
}
