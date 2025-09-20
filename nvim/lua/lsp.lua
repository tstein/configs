vim.lsp.config("bashls", {})
vim.lsp.config("clangd", {})

vim.lsp.config("ruff", {})
vim.lsp.config("pyright", {
  -- Let ruff handle analysis and imports.
  settings = {
    pyright = {
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        ignore = { '*' },
      },
    },
  },
})

vim.lsp.inlay_hint.enable()
