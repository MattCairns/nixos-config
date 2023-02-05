require('lint').linters_by_ft = {
  cpp = {'cppcheck',}
}
vim.cmd[[autocmd BufWritePost * :lua require('lint').try_lint()]]
