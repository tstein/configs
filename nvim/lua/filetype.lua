-- Per-filetype settings.

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  command = "setlocal ts=2 sts=2 sw=2"
})

-- Actively unhelpful to wrap some filetypes.
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"fstab", "hlsplaylist"},
  command = "setlocal tw=0"
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  command = "setlocal tw=88"  -- black-style and ruff's default
})
