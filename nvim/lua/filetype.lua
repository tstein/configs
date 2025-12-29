-- Per-filetype settings.
vim.filetype.add({
  -- systemd units and defs aren't recognized by default.
  extension = {
    container = "systemd",
    service = "systemd",
    timer = "systemd",
    volume = "systemd",
  },
})

-- two-space soft tabs by default
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  command = "setlocal ts=2 sts=2 sw=2"
})

-- Actively unhelpful to wrap some filetypes.
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"fstab", "hlsplaylist"},
  command = "setlocal tw=0"
})
