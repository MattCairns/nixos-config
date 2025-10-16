{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    clipboard = {
      providers = {
        wl-copy.enable = true; # For Wayland
        xsel.enable = true; # For X11
      };
      register = "unnamedplus";
    };

    diagnostic = {
      settings = {
        virtual_text = true;
      };
    };

    opts = {
      number = true;
      relativenumber = true;
      showmode = false;
      breakindent = true;
      undofile = true;
      ignorecase = true;
      smartcase = true;
      updatetime = 250;
      timeoutlen = 500;
      splitright = true;
      splitbelow = true;
      inccommand = "split";
      cursorline = true;
      scrolloff = 10;
      hlsearch = true;
    };

    globals = {
      mapleader = "\\";
      maplocalleader = "\\";
      ttimeoutlen = 100;
      have_nerd_font = false;
    };

    keymaps = [
      {
        action = "<cmd>:cn<CR>";
        key = "<leader>qn";
      }
      {
        action = "<cmd>:pn<CR>";
        key = "<leader>qp";
      }
      {
        action = "<cmd>Oil<CR>";
        key = "<leader>oo";
      }
      {
        action = "<cmd>LazyGit<CR>";
        key = "<leader>lg";
      }
      {
        action = "<cmd>lua require('conform').format({async = true})<CR>";
        key = "<leader>fm";
      }
    ];

    colorschemes.tokyonight.enable = true;
    # colorschemes.catppuccin.settings.flavour = "latte";
    # colorschemes.catppuccin.enable = f;

    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "telescope-cargo-workspace-nvim";
        doCheck = false;
        src = pkgs.fetchFromGitHub {
          owner = "MattCairns";
          repo = "telescope-cargo-workspace.nvim";
          rev = "8843b72822151bb7792f3fdad4b63df0bc1dd4a6";
          hash = "sha256-QlOQetD34EkUIByMOeN7pfnud/ZxIu8HlvO/Dzoa3eQ=";
        };
      })
    ];

    plugins = {
      treesitter = {
        enable = true;
        settings = {
          highlight = {
            enable = true;
            additional_vim_regex_highlighting = true;
          };
          indent.enable = true;
        };
      };

      lsp = {
        enable = true;
        keymaps = {
          lspBuf = {
            "<leader>ca" = "code_action";
            "<leader>rn" = "rename";
            "K" = "hover";
            "gD" = "declaration";
            "gd" = "definition";
          };
          diagnostic = {
            "<leader>dn" = "goto_prev";
            "<leader>dp" = "goto_next";
            "<leader>e" = "open_float";
            "<leader>q" = "setloclist";
          };
        };
        servers = {
          nil_ls.enable = true;
          cmake.enable = true;
          clangd.enable = true;
          buf_ls.enable = true;
          dockerls.enable = true;
          pyright.enable = true;
          bashls.enable = true;
          jsonls.enable = true;
        };
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          # snippet = {
          # expand = ''
          #   function(args)
          #     require('luasnip').lsp_expand(args.body)
          #   end
          # '';
          # };
          completion = {
            completeopt = "menu,menuone,noinsert";
          };
          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
          mapping = {
            "<C-n>" = "cmp.mapping.select_next_item()";
            "<C-p>" = "cmp.mapping.select_prev_item()";
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-y>" = "cmp.mapping.confirm { select = true }";
            # "<CR>" = "cmp.mapping.confirm { select = true }";
            "<C-Space>" = "cmp.mapping.complete {}";

            # Think of <c-l> as moving to the right of your snippet expansion.
            #  So if you have a snippet that's like:
            #  function $name($args)
            #    $body
            #  end
            #
            # <c-l> will move you to the right of each of the expansion locations.
            # <c-h> is similar, except moving you backwards.
            # "<C-l>" = ''
            #   cmp.mapping(function()
            #     if luasnip.expand_or_locally_jumpable() then
            #       luasnip.expand_or_jump()
            #     end
            #   end, { 'i', 's' })
            # '';
            # "<C-h>" = ''
            #   cmp.mapping(function()
            #     if luasnip.locally_jumpable(-1) then
            #       luasnip.jump(-1)
            #     end
            #   end, { 'i', 's' })
            # '';

            # For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
            #    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
          };
        };
      };

      comment.enable = true;
      conform-nvim = {
        enable = true;
        autoLoad = true;
        settings = {
          notify_on_error = true;
          notify_no_formatters = true;
          format_on_save = ''
            function(bufnr)
              local disable_filetypes = { c = true, cpp = true }
              return {
                timeout_ms = 500,
                lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype]
              }
            end
          '';
        };
      };
      fidget.enable = true;
      gitsigns.enable = true;
      lazygit.enable = true;
      lualine.enable = true;
      neotest = {
        enable = true;
        adapters.rust = {
          enable = true;
        };
      };
      noice.enable = true;
      nvim-autopairs.enable = true;
      oil.enable = true;
      repeat.enable = true;
      sleuth.enable = true;
      trouble.enable = true;
      vim-surround.enable = true;
      web-devicons.enable = true;
      codecompanion = {
        enable = true;
        settings = {
          strategies = {
            agent = {
              adapter = "openai";
            };
            chat = {
              adapter = "openai";
            };
            inline = {
              adapter = "openai";
            };
          };
          adapters = {
            openai = {
              __raw = ''
                 function()
                  return require("codecompanion.adapters").extend("openai", {
                    env = {
                      api_key = os.getenv("OPENAI_API_KEY"),
                    },
                  })
                end
              '';
            };
          };
        };
      };

      rustaceanvim = {
        enable = true;
        settings = {
          server = {
            default_settings = {
              rust-analyzer = {
                check = {
                  command = "clippy";
                  workspace = false;
                };
                cargo = {
                  allFeatures = true;
                  allTargets = true;
                  runBuildScripts = true;
                  targetDir = true;
                };
                inlayHints = {
                  lifetimeElisionHints = {
                    enable = "always";
                  };
                };
              };
            };
            standalone = false;
          };
        };
      };

      telescope = {
        enable = true;
        keymaps = {
          "<leader>fg" = "live_grep";
          "<leader>ff" = "find_files";
          "<leader>fb" = "buffers";
          "<leader>fs" = "grep_string";
          "<leader>fd" = "diagnostics";
          "<leader>fi" = "lap_implementations";
          "<leader>fw" = "telescope-cargo-workspace switch";
        };
      };
    };
  };
}
