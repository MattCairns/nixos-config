{ pkgs
, lib
, ...
}:
let
  fromGitHub = rev: ref: repo: pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = ref;
    src = builtins.fetchGit {
      url = "https://github.com/${repo}.git";
      ref = ref;
      rev = rev;
    };
  };
in
{
  home.packages = with pkgs; [
    vscode-extensions.ms-vscode.cpptools
  ];
  programs = {
    neovim = {
      plugins = [
        ## Theme
        {
          plugin = pkgs.vimPlugins.tokyonight-nvim;
          config = "vim.cmd[[colorscheme tokyonight-night]]";
          type = "lua";
        }

        ## Treesitter
        {
          plugin = pkgs.vimPlugins.nvim-treesitter;
          config = builtins.readFile config/setup/treesitter.lua;
          type = "lua";
        }
        pkgs.vimPlugins.nvim-treesitter.withAllGrammars
        pkgs.vimPlugins.nvim-treesitter-textobjects
        {
          plugin = pkgs.vimPlugins.nvim-lspconfig;
          config = builtins.readFile config/setup/lspconfig.lua;
          type = "lua";
        }

        {
          plugin = pkgs.vimPlugins.trouble-nvim;
          config = "require('trouble').setup {}";
          type = "lua";
        }
        pkgs.vimPlugins.plenary-nvim
        {
          plugin = pkgs.vimPlugins.telescope-nvim;
          config = builtins.readFile config/setup/telescope.lua;
          type = "lua";
        }
        pkgs.vimPlugins.telescope-fzf-native-nvim
        pkgs.vimPlugins.harpoon
        {
          plugin = pkgs.vimPlugins.fidget-nvim;
          config = "require('fidget').setup{}";
          type = "lua";
        }

        ## cmp
        {
          plugin = pkgs.vimPlugins.nvim-cmp;
          config = builtins.readFile config/setup/cmp.lua;
          type = "lua";
        }
        pkgs.vimPlugins.cmp-nvim-lsp
        pkgs.vimPlugins.cmp-buffer
        pkgs.vimPlugins.cmp-cmdline
        pkgs.vimPlugins.cmp_luasnip

        ## QoL
        {
          plugin = pkgs.vimPlugins.clangd_extensions-nvim;
          config = builtins.readFile config/setup/clangd_extensions.lua;
          type = "lua";
        }
        {
          plugin = pkgs.vimPlugins.luasnip;
          config = builtins.readFile config/setup/luasnip.lua;
          type = "lua";
        }
        pkgs.vimPlugins.lspkind-nvim
        {
          plugin = pkgs.vimPlugins.nvim-lint;
          config = ''
            require('lint').linters_by_ft = {
              cpp = {'cppcheck',}
            }
            vim.cmd[[autocmd BufWritePost * :lua require('lint').try_lint()]]
          '';
          type = "lua";
        }
        pkgs.vimPlugins.vim-surround
        pkgs.vimPlugins.vim-obsession
        {
          plugin = pkgs.vimPlugins.comment-nvim;
          config = "require('Comment').setup()";
          type = "lua";
        }
        pkgs.vimPlugins.neoformat
        pkgs.vimPlugins.lazygit-nvim
        {
          plugin = pkgs.vimPlugins.gitsigns-nvim;
          config = "require('gitsigns').setup()";
          type = "lua";
        }
        pkgs.vimPlugins.rainbow
        pkgs.vimPlugins.vim-sleuth
        {
          plugin = pkgs.vimPlugins.lualine-nvim;
          config = ''
            require('lualine').setup {
                options = {
                    theme = 'tokyonight',
                }
            }
          '';
          type = "lua";
        }
        pkgs.vimPlugins.nvim-web-devicons
        pkgs.vimPlugins.vim-repeat

        ## Debugging
        {
          plugin = pkgs.vimPlugins.nvim-dap;
          config = builtins.readFile config/setup/dap.lua;
          type = "lua";
        }
        pkgs.vimPlugins.nvim-dap-ui
        pkgs.vimPlugins.nvim-dap-virtual-text

        pkgs.vimPlugins.copilot-vim

        (fromGitHub "c3b6ca031dc29b9b59f760f6d568210c66bd30fe" "main" "MattCairns/telescope-cargo-workspace.nvim")

        pkgs.vimPlugins.nui-nvim
        {
          plugin = (fromGitHub "b90180e30d143afb71490b92b08c1e9121d4416a" "main" "Bryley/neoai.nvim");
          config = builtins.readFile config/setup/neoai.lua;
          type = "lua";
        }

        pkgs.vimPlugins.surround-nvim

        {
          plugin = pkgs.vimPlugins.noice-nvim;
          config = ''
            require("noice").setup({
              lsp = {
                -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                override = {
                  ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                  ["vim.lsp.util.stylize_markdown"] = true,
                  ["cmp.entry.get_documentation"] = true,
                },
              },
              -- you can enable a preset for easier configuration
              presets = {
                bottom_search = true, -- use a classic bottom cmdline for search
                command_palette = true, -- position the cmdline and popupmenu together
                long_message_to_split = true, -- long messages will be sent to a split
                inc_rename = false, -- enables an input dialog for inc-rename.nvim
                lsp_doc_border = false, -- add a border to hover docs and signature help
              },
            })
          '';
          type = "lua";
        }

      ];

      extraLuaConfig = ''
        ${builtins.readFile config/mappings.lua}
        ${builtins.readFile config/options.lua}
      '';
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
