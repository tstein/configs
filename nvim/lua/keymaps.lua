local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end
vim.g.mapleader = ","
vim.g.maplocalleader = vim.g.mapleader

-- save
map("n", "<leader>w", ":w<CR>", opts)

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

-- save like you mean it
map("c", "w!!", "w !sudo tee % >/dev/null", opts)
