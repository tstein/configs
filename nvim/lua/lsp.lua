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
vim.lsp.enable({"bashls", "clangd", "pyright", "ruff"})

vim.lsp.inlay_hint.enable()
