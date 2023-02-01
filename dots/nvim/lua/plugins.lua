--
-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  is_bootstrap = true
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
  vim.cmd [[packadd packer.nvim]]
end

require('packer').startup(function(use)
  -- Package manager
  use 'wbthomason/packer.nvim'

  -- Essentials
  use { 'nvim-treesitter/nvim-treesitter', run = function()
      pcall(require('nvim-treesitter.install').update { with_sync = true })
    end,
  }

  -- Additional text objects via treesitter
  use { 
    'nvim-treesitter/nvim-treesitter-textobjects',
    after = 'nvim-treesitter',
  }

  use { 'folke/trouble.nvim' }

  -- Telescope
  use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } }
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

  -- Completion
  use { 
    'neovim/nvim-lspconfig',
    requires = {
      'j-hui/fidget.nvim',
    },
  }

  use { 
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'p00f/clangd_extensions.nvim',
    }
  }

  use { 'L3MON4D3/LuaSnip' }
  use { 'saadparwaiz1/cmp_luasnip' }
  use { 'onsails/lspkind-nvim' }

  -- Linting
  use { 'mfussenegger/nvim-lint' } 

  -- -- Dap
  -- use { 'mfussenegger/nvim-dap' }
  -- use { 'rcarriga/nvim-dap-ui' }
  -- use { 'theHamsta/nvim-dap-virtual-text' }
  -- use { 'nvim-telescope/telescope-dap.nvim' }

  -- QOL
  use 'tpope/vim-surround' 
  use 'tpope/vim-obsession' 
  use 'b3nj5m1n/kommentary' 
  use 'sbdchd/neoformat' 
  use 'kdheepak/lazygit.nvim' 
  use 'lewis6991/gitsigns.nvim'
  use 'luochen1990/rainbow'  
  use 'tpope/vim-sleuth' -- Detect tabstop and shiftwidth automatically

  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
  use { 'ggandor/lightspeed.nvim' }
  use { 'ggandor/leap.nvim' }
  use { 'tpope/vim-repeat' }

  -- Themes
  use { 'AlexvZyl/nordic.nvim' }
  use { 'rebelot/kanagawa.nvim' }
  use { 'mcchrish/zenbones.nvim' }
  use { 'rktjmp/lush.nvim' }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if is_bootstrap then
    require('packer').sync()
  end
end)

-- When we are bootstrapping a configuration, it doesn't
-- make sense to execute the rest of the init.lua.
--
-- You'll need to restart nvim, and then it will work.
if is_bootstrap then
  print '=================================='
  print '    Plugins are being installed'
  print '    Wait until Packer completes,'
  print '       then restart nvim'
  print '=================================='
  return
end

-- Automatically source and re-compile packer whenever you save this init.lua
local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
  command = 'source <afile> | PackerCompile',
  group = packer_group,
  pattern = vim.fn.expand '$MYVIMRC',
})


