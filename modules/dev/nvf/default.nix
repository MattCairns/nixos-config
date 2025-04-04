{
  pkgs,
  lib,
  ...
}: {
  programs.nvf = {
    enable = true;
    settings = {

      vim = {
        viAlias = false;
        vimAlias = true;

      theme = {
        enable = true;
        name = "tokyonight";
        # style = "darker";
      };
        globals.mapleader = "\\";

        # Plugins
        telescope.enable = true;
        mini.surround.enable = true;
        # lsp.lspkind.enable = true;
        lsp.trouble.enable = true;
        visuals.rainbow-delimiters.enable = true;
        visuals.nvim-web-devicons.enable = true;
        visuals.fidget-nvim.enable = true;
        autopairs.nvim-autopairs.enable = true;
        utility.oil-nvim.enable = true;
        snippets.luasnip.enable = true;
        comments.comment-nvim.enable = true;
        git.gitsigns.enable = true;
        statusline.lualine.enable = true;
        # assistant.codecompanion-nvim = true;

        # LSP
        languages = {
          enableTreesitter = true;
          enableLSP = true;

          nix.enable = true;
          rust.enable = true;
        };
      };
    };
  };
}
