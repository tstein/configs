local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end
vim.g.mapleader = ","
vim.g.maplocalleader = vim.g.mapleader

-- telescope pickers
map("n", "<leader>pf", ":lua require'telescope.builtin'.find_files{}<CR>")
map("n", "<leader>pg", ":lua require'telescope.builtin'.git_files{}<CR>")
map("n", "<leader>pd", ":lua require'telescope.builtin'.lsp_document_symbols{}<CR>")
map("n", "<leader>ps", ":lua require'telescope.builtin'.lsp_dynamic_workspace_symbols{}<CR>")

-- save
map("n", "<leader>w", ":w<CR>", opts)
-- save like you mean it
map("c", "w!!", "w !sudo tee % >/dev/null", opts)

-- switch buffers
map("n", "<leader>1", ":1b<CR>", opts)
map("n", "<leader>2", ":2b<CR>", opts)
map("n", "<leader>3", ":3b<CR>", opts)
map("n", "<leader>4", ":4b<CR>", opts)
map("n", "<leader>5", ":5b<CR>", opts)
map("n", "<leader>6", ":6b<CR>", opts)
map("n", "<leader>7", ":7b<CR>", opts)
map("n", "<leader>8", ":8b<CR>", opts)
map("n", "<leader>9", ":9b<CR>", opts)
map("n", "<leader>0", ":10b<CR>", opts)
map("n", "<leader><leader>", "<C-^>", opts)

-- clear highlighting on enter
map("n", "<CR>", ":noh<CR><CR>", opts)

-- cleanup trailing whitespace
map("n", "<leader>s", ":%s/\\s\\+$//<CR>", opts)

-- make tab/shift-tab cycle through completion
vim.cmd [[
  inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
  inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
]]
