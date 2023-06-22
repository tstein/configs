-- autoinstall packer
local install_path = vim.fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  print "packer isn't installed. installing it now."
  PACKER_FRESH_INSTALL = vim.fn.system {
    "git", "clone", "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  vim.cmd [[packadd packer.nvim]]
end

-- auto PackerSync on modifying plugins.lua
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

return packer.startup(function(use)
  use "wbthomason/packer.nvim"

  -- completion
  use "neovim/nvim-lspconfig"
  use "nvim-lua/completion-nvim"
  use "hrsh7th/nvim-cmp"
  use "hrsh7th/vim-vsnip"
  use "hrsh7th/cmp-nvim-lsp"
  use "hrsh7th/cmp-buffer"
  use "hrsh7th/cmp-path"
  use "hrsh7th/cmp-vsnip"
  use "simrat39/rust-tools.nvim"
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
  }

  use "vim-airline/vim-airline"
  use "akinsho/nvim-bufferline.lua"
  use "fs111/pydoc.vim"
  use "preservim/tagbar"
  use "tpope/vim-fugitive"
  use "qpkorr/vim-renamer"
  use "mhinz/vim-signify"
  use "tpope/vim-surround"

  use "sainnhe/edge"
  use "xiyaowong/nvim-transparent"

  if PACKER_FRESH_INSTALL then
    require("packer").sync()
  end
end)
