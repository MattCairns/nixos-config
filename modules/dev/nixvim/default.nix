{pkgs, ...}: {
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

    diagnostics = {
      virtual_text = true;
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
      timeoutlen = 300;
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
    ];

    colorschemes.tokyonight.enable = true;

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
        servers = {
          nil_ls.enable = true;
          cmake.enable = true;
          clangd.enable = true;
          buf_ls.enable = true;
          dockerls.enable = true;
          ansiblels.enable = true;
          pyright.enable = true;
          bashls.enable = true;
        };
      };

      cmp = {
        autoEnableSources = true;
        settings.sources = [
          {name = "nvim_lsp";}
          {name = "path";}
          {name = "buffer";}
        ];
      };

      comment.enable = true;
      conform-nvim.enable = true;
      fidget.enable = true;
      gitsigns.enable = true;
      lazygit.enable = true;
      lualine.enable = true;
      neotest.enable = true;
      noice.enable = true;
      nvim-autopairs.enable = true;
      oil.enable = true;
      repeat.enable = true;
      sleuth.enable = true;
      trouble.enable = true;
      vim-surround.enable = true;
      web-devicons.enable = true;

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
