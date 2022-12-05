{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    neovim 
  ];

  environment.variables.EDITOR = "nvim";
  nixpkgs.overlays = [
    (self: super: {
     neovim = super.neovim.override {
     viAlias = true;
     vimAlias = true;
     };
     })
  ];
}
