{ config, pkgs, ... }:
{

  programs = {
    neovim = {
      plugins = [
	pkgs.vimPlugins.nvim-treesitter
	pkgs.vimPlugins.nvim-treesitter.withAllGrammars
	pkgs.vimPlugins.nvim-treesitter-textobjects
	pkgs.vimPlugins.trouble-nvim
	pkgs.vimPlugins.plenary-nvim
	pkgs.vimPlugins.telescope-nvim
	pkgs.vimPlugins.telescope-fzf-native-nvim
	pkgs.vimPlugins.nvim-lspconfig
	pkgs.vimPlugins.fidget-nvim
	pkgs.vimPlugins.nvim-cmp
	pkgs.vimPlugins.cmp-nvim-lsp
	pkgs.vimPlugins.cmp-buffer
	pkgs.vimPlugins.cmp-cmdline
	pkgs.vimPlugins.clangd_extensions-nvim
	pkgs.vimPlugins.luasnip
	pkgs.vimPlugins.cmp_luasnip
	pkgs.vimPlugins.lspkind-nvim
	pkgs.vimPlugins.nvim-lint
	pkgs.vimPlugins.vim-surround
	pkgs.vimPlugins.vim-obsession
	pkgs.vimPlugins.kommentary
	pkgs.vimPlugins.neoformat
	pkgs.vimPlugins.lazygit-nvim
	pkgs.vimPlugins.gitsigns-nvim
	pkgs.vimPlugins.rainbow
	pkgs.vimPlugins.vim-sleuth
	pkgs.vimPlugins.lualine-nvim
	pkgs.vimPlugins.nvim-web-devicons
	pkgs.vimPlugins.lightspeed-nvim
	pkgs.vimPlugins.leap-nvim
	pkgs.vimPlugins.vim-repeat
	pkgs.vimPlugins.kanagawa-nvim
      ];

      extraConfig =
        ''
          lua << EOF
          ${builtins.readFile ../dots/nvim/lua/mappings.lua }
          ${builtins.readFile ../dots/nvim/lua/options.lua }
          ${builtins.readFile ../dots/nvim/lua/setup/cmp.lua }
          ${builtins.readFile ../dots/nvim/lua/setup/treesitter.lua }
          ${builtins.readFile ../dots/nvim/lua/setup/lspconfig.lua }
          ${builtins.readFile ../dots/nvim/lua/setup/luasnip.lua }
          ${builtins.readFile ../dots/nvim/lua/setup/trouble.lua }
          ${builtins.readFile ../dots/nvim/lua/setup/telescope.lua }
          ${builtins.readFile ../dots/nvim/lua/setup/kommentary.lua }
          ${builtins.readFile ../dots/nvim/lua/setup/lualine.lua }
          ${builtins.readFile ../dots/nvim/lua/setup/fidget.lua }
          ${builtins.readFile ../dots/nvim/lua/setup/lint.lua }
          ${builtins.readFile ../dots/nvim/lua/setup/leap.lua }
          ${builtins.readFile ../dots/nvim/lua/setup/gitsigns.lua }
          ${builtins.readFile ../dots/nvim/lua/setup/clangd_extensions.lua }
        ''; 
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
