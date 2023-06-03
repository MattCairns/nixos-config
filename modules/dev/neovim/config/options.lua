-- THEME
vim.opt.termguicolors = true
vim.opt.background='dark'

-- QOL settings
HOME = os.getenv("HOME")
vim.opt.backupdir = HOME .. '/.config/nvim/tmp/backup_files/'
vim.opt.directory = HOME .. '/.config/nvim/tmp/swap_files/'
vim.opt.undodir = HOME .. '/.config/nvim/tmp/undo_files/'
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.scrolloff=10
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.relativenumber = true
vim.opt.clipboard = 'unnamedplus'

vim.cmd([[
" UltiSnips settings
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

set completeopt=menu,menuone,noselect

autocmd BufWritePre * :lua require('lint').try_lint()
]])

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})
