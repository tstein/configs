-- leaders are set in init.lua

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- telescope pickers
map("n", "<leader>pf", require'telescope.builtin'.find_files)
map("n", "<leader>pg", require'telescope.builtin'.git_files)
map("n", "<leader>pd", require'telescope.builtin'.lsp_document_symbols)
map("n", "<leader>ps", require'telescope.builtin'.lsp_dynamic_workspace_symbols)

-- save
map("n", "<leader>w", ":w<CR>")
-- save like you mean it
map("c", "w!!", "w !sudo tee % >/dev/null")

-- switch buffers
map("n", "<leader>1", ":1b<CR>")
map("n", "<leader>2", ":2b<CR>")
map("n", "<leader>3", ":3b<CR>")
map("n", "<leader>4", ":4b<CR>")
map("n", "<leader>5", ":5b<CR>")
map("n", "<leader>6", ":6b<CR>")
map("n", "<leader>7", ":7b<CR>")
map("n", "<leader>8", ":8b<CR>")
map("n", "<leader>9", ":9b<CR>")
map("n", "<leader>0", ":10b<CR>")
map("n", "<leader><leader>", "<C-^>")

-- clear highlighting on enter
map("n", "<CR>", ":noh<CR><CR>")

-- cleanup trailing whitespace
map("n", "<leader>s", ":%s/\\s\\+$//<CR>")

-- apply code actions with alt+enter
map("n", "<M-CR>", vim.lsp.buf.code_action)

-- make tab/shift-tab cycle through completion
vim.cmd [[
  inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
  inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
]]

-- Ensure these binds override anything set by the LSP configs.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local map = vim.keymap.set
    local opts = { buffer = ev.buf, silent = true }

    opts.desc = "Smart rename"
    map("n", "<leader>rn", vim.lsp.buf.rename, opts)

    opts.desc = "Show documentation for what is under cursor"
    map("n", "K", vim.lsp.buf.hover, opts)
    opts.desc = "Show LSP references"
    map("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
    opts.desc = "Go to declaration"
    map("n", "gD", vim.lsp.buf.declaration, opts)
    opts.desc = "Show LSP definitions"
    map("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
    opts.desc = "Show LSP implementations"
    map("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
    opts.desc = "Show LSP type definitions"
    map("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
    opts.desc = "Show buffer diagnostics"
    map("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
  end,
})
