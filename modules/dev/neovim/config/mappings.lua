-- lazygit
-- vim.api.nvim_set_keymap('n', '<leader>lg', '<cmd>LazyGit<cr>', { noremap = true, silent = true })

-- lsp trouble
vim.api.nvim_set_keymap('n', '<leader>tt', '<cmd>Trouble diagnostics toggle<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>tq', '<cmd>Trouble quickfix toggle<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>td', '<cmd>Trouble lsp_definitions toggle<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>tr', '<cmd>Troubl lsp_references toggle<cr>', { noremap = true })

-- telescope
-- vim.api.nvim_set_keymap('n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<cr>", { noremap = true })
-- vim.api.nvim_set_keymap('n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fs', "<cmd>lua require('telescope.builtin').grep_string()<cr>", { noremap = true })
-- vim.api.nvim_set_keymap('n', '<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fd', "<cmd>lua require('telescope.builtin').diagnostics()<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fi', "<cmd>lua require('telescope.builtin').lsp_implementations()<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fw', "<cmd>Telescope telescope-cargo-workspace switch<cr>", { noremap = true })

-- SnipRun
vim.api.nvim_set_keymap('n', '<leader>sr', "<cmd>lua require('sniprun').run()<cr>", { noremap = true })

-- Quickfix
vim.api.nvim_set_keymap('n', '<leader>qn', '<cmd>:cn<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>qp', '<cmd>:cp<CR>', { noremap = true })

-- Clang
vim.api.nvim_set_keymap('n', '<leader>he', '<cmd>ClangdSwitchSourceHeader<cr>', { noremap = true })

-- Oil
vim.api.nvim_set_keymap('n', '<leader>oo', '<cmd>Oil<cr>', { noremap = true })

