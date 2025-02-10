-- Per-filetype settings.

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  command = "setlocal ts=2 sts=2 sw=2"
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  command = "setlocal tw=88"  -- black-style and ruff's default
})
