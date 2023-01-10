require "00_packer"

local modules_dir = vim.loop.fs_scandir(vim.fn.stdpath("config") .. "/lua/")
for module in function() return vim.loop.fs_scandir_next(modules_dir) end do
  require(module:gsub(".lua$", ""))
end
