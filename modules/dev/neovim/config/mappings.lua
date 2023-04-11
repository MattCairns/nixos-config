-- Terminal
vim.api.nvim_set_keymap('n', '<leader>te', '<cmd>terminal<cr>', { noremap = true })
vim.api.nvim_set_keymap('t', '<leader>jf', '<C-\\><C-n>', { noremap = true })

-- Neoformat
vim.api.nvim_set_keymap('n', '<leader>fm', '<cmd>Neoformat<cr>', { noremap = true })

-- lazygit
vim.api.nvim_set_keymap('n', '<leader>lg', '<cmd>LazyGit<cr>', { noremap = true, silent = true })

-- lsp trouble
vim.api.nvim_set_keymap('n', '<leader>tt', '<cmd>TroubleToggle document_diagnostics<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>tw', '<cmd>TroubleToggle workspace_diagnostics<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>tq', '<cmd>TroubleToggle quickfix<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>td', '<cmd>TroubleToggle lsp_definitions<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>tr', '<cmd>TroubleToggle lsp_references<cr>', { noremap = true })

-- telescope
vim.api.nvim_set_keymap('n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fd', "<cmd>lua require('telescope.builtin').lsp_definitions()<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fi', "<cmd>lua require('telescope.builtin').lsp_implementations()<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fp', ':Telescope project<cr>', { noremap = true })

-- Worktree
vim.api.nvim_set_keymap('n', '<leader>wt', "<cmd>lua require('telescope').extensions.git_worktree.git_worktrees()<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>wc', "<cmd>lua require('telescope').extensions.git_worktree.create_git_worktree()<cr>", { noremap = true })

-- DAP
vim.api.nvim_set_keymap('n', '<leader>db', "<cmd>lua require('dap').toggle_breakpoint()<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>dc', "<cmd>lua require('dap').continue()<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>so', "<cmd>lua require('dap').step_over()<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>si', "<cmd>lua require('dap').step_into()<cr>", { noremap = true })

-- SnipRun
vim.api.nvim_set_keymap('n', '<leader>sr', "<cmd>lua require('sniprun').run()<cr>", { noremap = true })

-- lspconfig
vim.api.nvim_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', { noremap = true })

-- Quickfix
vim.api.nvim_set_keymap('n', '<leader>qn', '<cmd>:cn<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>qp', '<cmd>:cp<CR>', { noremap = true })

-- Harpoon
vim.api.nvim_set_keymap('n', '<leader>s', '<cmd>lua require("harpoon.mark").add_file()<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-e>', '<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-h>', '<cmd>lua require("harpoon.ui").nav_file(1)<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-j>', '<cmd>lua require("harpoon.ui").nav_file(2)<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-k>', '<cmd>lua require("harpoon.ui").nav_file(3)<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-l>', '<cmd>lua require("harpoon.ui").nav_file(4)<cr>', { noremap = true })

