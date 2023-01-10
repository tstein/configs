local linux = vim.api.nvim_create_augroup("linux", { clear = true })
vim.api.nvim_create_autocmd(
  { "FileType" },
  { pattern = {"crontab", "fstab"}, command = "set tw=0", group = linux }
)
