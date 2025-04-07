{
  pkgs,
  lib,
  ...
}: let
  fromGitHub = rev: ref: repo:
    pkgs.vimUtils.buildVimPlugin {
      pname = "${lib.strings.sanitizeDerivationName repo}";
      version = ref;
      doCheck = false;
      src = builtins.fetchGit {
        url = "https://github.com/${repo}.git";
        ref = ref;
        rev = rev;
      };
    };
in {
  home.packages = with pkgs; [
    rust-analyzer
    vscode-extensions.ms-vscode.cpptools
    vscode-extensions.vadimcn.vscode-lldb
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
        pkgs.vimPlugins.nightfox-nvim

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

        pkgs.vimPlugins.plenary-nvim

        ## Telescope
        {
          plugin = pkgs.vimPlugins.telescope-nvim;
          config = builtins.readFile config/setup/telescope.lua;
          type = "lua";
        }
        pkgs.vimPlugins.telescope-fzf-native-nvim

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

        ## Tpope
        # pkgs.vimPlugins.vim-surround
        # pkgs.vimPlugins.vim-sleuth
        # pkgs.vimPlugins.vim-repeat

        ## QoL
        {
          plugin = fromGitHub "1491b543ef1d8a0eb29a6ebc35db4fb808dcb47f" "main" "folke/snacks.nvim";
          config = builtins.readFile config/setup/snacks.lua;
          type = "lua";
        }
        # pkgs.vimPlugins.neogen
        # pkgs.vimPlugins.lspkind-nvim
        # pkgs.vimPlugins.rainbow
        # pkgs.vimPlugins.nvim-web-devicons
        # pkgs.vimPlugins.surround-nvim
        # {
        #   plugin = pkgs.vimPlugins.nvim-autopairs;
        #   config =
        #     /*
        #     lua
        #     */
        #     ''
        #       require('nvim-autopairs').setup {}
        #     '';
        #   type = "lua";
        # }
        # pkgs.vimPlugins.nvim-code-action-menu

        {
          plugin =
            pkgs.vimPlugins.conform-nvim;
          config =
            /*
            lua
            */
            ''
              require("conform").setup({
                formatters_by_ft = {
                  lua = { "stylua" },
                  python = { "isort", "black" },
                  rust = { "rustfmt", lsp_format = "fallback" },
                  javascript = { "prettierd", "prettier", stop_after_first = true },
                  nix = { "alejandra", "nixfmt", stop_after_first = true },
                  cmake = { "gersemi", "cmake_format", lsp_format = "fallback", stop_after_first = true },
                },
              })
            '';
          type = "lua";
        }
        {
          # Updated 25/02/12
          plugin = fromGitHub "a5a7fdacc0ac2f7ca9d241e0e059cb85f0e733bc" "main" "m-demare/hlargs.nvim";
          config = "require('hlargs').setup()";
          type = "lua";
        }
        (fromGitHub "a0ae099c7eb926150ee0a126b1dd78086edbe3fc" "main" "apple/pkl-neovim")
        (fromGitHub "8843b72822151bb7792f3fdad4b63df0bc1dd4a6" "main" "MattCairns/telescope-cargo-workspace.nvim")
        # {
        #   plugin = pkgs.vimPlugins.oil-nvim;
        #   config = "require('oil').setup()";
        #   type = "lua";
        # }
        # {
        #   plugin = pkgs.vimPlugins.fidget-nvim;
        #   config = "require('fidget').setup{}";
        #   type = "lua";
        # }
        # {
        #   plugin = pkgs.vimPlugins.trouble-nvim;
        #   config = "require('trouble').setup {}";
        #   type = "lua";
        # }
        # {
        #   plugin = pkgs.vimPlugins.luasnip;
        #   config = builtins.readFile config/setup/luasnip.lua;
        #   type = "lua";
        # }
        # {
        #   plugin = pkgs.vimPlugins.comment-nvim;
        #   config = "require('Comment').setup()";
        #   type = "lua";
        # }
        # {
        #   plugin = pkgs.vimPlugins.neotest;
        #   config = ''
        #       require("neotest").setup({
        #       adapters = {
        #         require("rustaceanvim.neotest"),
        #       },
        #     })
        #   '';
        #   type = "lua";
        # }
        # {
        #   plugin = pkgs.vimPlugins.gitsigns-nvim;
        #   config = "require('gitsigns').setup()";
        #   type = "lua";
        # }
        (fromGitHub "e2dcf63ba74e6111b53e1520a4f8a17a3d7427a1" "main" "yavorski/lualine-macro-recording.nvim")
        {
          plugin = pkgs.vimPlugins.lualine-nvim;
          config =
            /*
            lua
            */
            ''
               require('lualine').setup {
                 options = {
                   theme = 'tokyonight',
              },
                   sections = {
                   lualine_c = { "macro_recording", "%S" },
                 }
               }
            '';
          type = "lua";
        }
        {
          plugin = pkgs.vimPlugins.noice-nvim;
          config =
            /*
            lua
            */
            ''
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

        ## Debugging
        {
          # Updated 24/19/12
          plugin = fromGitHub "f4eed65f7890023104f7c1979be31baadbfb901f" "main" "olimorris/codecompanion.nvim";
          config =
            /*
            lua
            */
            ''
                require("codecompanion").setup({
                  strategies = {
                    chat = {
                      adapter = "openai",
                    },
                    inline = {
                      adapter = "openai",
                    },
                  },
                  adapters = {
                    openai = function()
                      return require("codecompanion.adapters").extend("openai", {
                        env = {
                          api_key = os.getenv("OPENAI_API_KEY"),
                        },
                      })
                    end,
                  },
              })
            '';
          type = "lua";
        }
        {
          plugin = pkgs.vimPlugins.rustaceanvim;
          config =
            /*
            lua
            */
            ''
              vim.g.rustaceanvim = {
                -- Plugin configuration
                tools = {
                  test_executor = 'background',
                },
                -- LSP configuration
                server = {
                  on_attach = function(client, bufnr)
                    -- you can also put keymaps in here
                  end,
                  settings = {
                    -- rust-analyzer language server configuration
                    ['rust-analyzer'] = {
                     diagnostics = {
                         enable = true,
                         disabled = {"unresolved-proc-macro"},
                         enableExperimental = false,
                     },
                     check = {
                         workspace = false,
                     },
                     cargo = {
                        allFeatures = true,
                        -- loadOutDirsFromCheck = true,
                        runBuildScripts = true,
                        targetDir = true,
                      },
                      checkOnSave = {
                        allFeatures = true,
                        command = "clippy",
                        extraArgs = { "--no-deps" },
                      },
                      procMacro = {
                        enable = true,
                        -- ignored = {
                        --   ["async-trait"] = { "async_trait" },
                        --   ["napi-derive"] = { "napi" },
                        --   ["async-recursion"] = { "async_recursion" },
                        --   ["nereus"] = { "main" },
                        --   ["nereus-derive"] = { "main" },
                        --   ["tracing"] = { "instrument" },
                        -- },
                      },
                    },
                  },
                },
              }
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
