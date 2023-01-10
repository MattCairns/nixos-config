{ config, pkgs, ... }:
{

  programs = {
    neovim = {
      plugins = [
       pkgs.vimPlugins.nvim-treesitter.withAllGrammars
      ];
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
