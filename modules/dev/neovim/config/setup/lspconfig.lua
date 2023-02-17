local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

require'lspconfig'.clangd.setup{
  cmd = {
    -- see clangd --help-hidden
    "clangd",
    "--background-index",
    -- by default, clang-tidy use -checks=clang-diagnostic-*,clang-analyzer-*
    -- to add more checks, create .clang-tidy file in the root directory
    -- and add Checks key, see https://clang.llvm.org/extra/clang-tidy/
    "--clang-tidy",
    "--completion-style=bundled",
    "--cross-file-rename",
    "--header-insertion=iwyu",
  },
  capabilities=capabilities
}
require'lspconfig'.rust_analyzer.setup{capabilities=capabilities}
require'lspconfig'.cmake.setup{capabilities=capabilities}
require'lspconfig'.dockerls.setup{capabilities=capabilities}
require'lspconfig'.rnix.setup{capabilities=capabilities}
require'lspconfig'.pyright.setup{
  capabilities=capabilities,
  settings = {
    python = {
      analysis = {       
        typeCheckingMode = "off",                                                                                          
      }
    }
  }   
}

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.diagnostic.config({
  virtual_text = false
})
-- You will likely want to reduce updatetime which affects CursorHold
-- note: this setting is global and should be set only once
vim.o.updatetime = 500
vim.cmd [[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]
