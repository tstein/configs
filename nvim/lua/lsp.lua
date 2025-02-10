local lsp = require('lspconfig')

lsp.bashls.setup{}
lsp.clangd.setup{}
lsp.ruff.setup{}
lsp.pyright.setup {
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
}
lsp.rust_analyzer.setup{}
