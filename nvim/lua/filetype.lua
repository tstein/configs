-- Per-filetype settings.

vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	command = "setlocal tw=79"
})
