{ config
, pkgs
, test-pkgs
, mrc
, ...
}: {
  home.packages = with pkgs; [
    vscode-extensions.ms-vscode.cpptools
  ];
  programs = {
    neovim = {
      plugins = [
        ## Treesitter
        pkgs.vimPlugins.nvim-treesitter
        pkgs.vimPlugins.nvim-treesitter.withAllGrammars
        pkgs.vimPlugins.nvim-treesitter-textobjects
        pkgs.vimPlugins.nvim-lspconfig

        pkgs.vimPlugins.trouble-nvim
        pkgs.vimPlugins.plenary-nvim
        pkgs.vimPlugins.telescope-nvim
        pkgs.vimPlugins.telescope-fzf-native-nvim
        pkgs.vimPlugins.harpoon
        pkgs.vimPlugins.fidget-nvim

        ## cmp
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
        pkgs.vimPlugins.comment-nvim
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
        pkgs.vimPlugins.no-neck-pain-nvim

        ## Debugging
        pkgs.vimPlugins.nvim-dap
        pkgs.vimPlugins.nvim-dap-ui
        pkgs.vimPlugins.nvim-dap-virtual-text

        pkgs.vimPlugins.copilot-vim

        test-pkgs.vimPlugins.neoai-nvim
      ];

      extraConfig = ''
        lua << EOF
        ${builtins.readFile config/mappings.lua}
        ${builtins.readFile config/options.lua}
        ${builtins.readFile config/setup/cmp.lua}
        ${builtins.readFile config/setup/treesitter.lua}
        ${builtins.readFile config/setup/lspconfig.lua}
        ${builtins.readFile config/setup/luasnip.lua}
        ${builtins.readFile config/setup/trouble.lua}
        ${builtins.readFile config/setup/telescope.lua}
        ${builtins.readFile config/setup/kommentary.lua}
        ${builtins.readFile config/setup/lualine.lua}
        ${builtins.readFile config/setup/fidget.lua}
        ${builtins.readFile config/setup/lint.lua}
        ${builtins.readFile config/setup/leap.lua}
        ${builtins.readFile config/setup/gitsigns.lua}
        ${builtins.readFile config/setup/clangd_extensions.lua}
        ${builtins.readFile config/setup/dap.lua}
        ${builtins.readFile config/setup/neoai.lua}
      '';
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
