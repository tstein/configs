-- set leader before plugins
vim.g.mapleader = ","
vim.g.maplocalleader = vim.g.mapleader

-- bootstrap lazy.nvim, via https://lazy.folke.io/installation
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- plugins
require("lazy").setup({
  spec = {
    -- interface
    "akinsho/nvim-bufferline.lua",
    "nvim-lualine/lualine.nvim",
    "lewis6991/gitsigns.nvim",
    "tpope/vim-surround",
    {
      "nvim-telescope/telescope.nvim", branch = "0.1.x",
      dependencies = { "nvim-lua/plenary.nvim" }
    },
    {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
      opts = {transparent="true"},
    },

    -- completion
    "neovim/nvim-lspconfig",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    {
      "nvim-treesitter/nvim-treesitter", branch = "master", lazy = false,
      build = ":TSUpdate"
    },

    -- language support
    "fs111/pydoc.vim",
    "mrcjkb/rustaceanvim",

    -- tools
    "tpope/vim-fugitive",
    "qpkorr/vim-renamer",
  },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
require("bufferline").setup{}
require("lualine").setup{}
require("gitsigns").setup {
  signs = {
    delete       = { text = "▁", show_count = true },
    topdelete    = { text = "▔", show_count = true },
    changedelete = { text = "~", show_count = true },
  }
}

-- modular config bits
local modules_dir = vim.loop.fs_scandir(vim.fn.stdpath("config") .. "/lua/")
for module in function() return vim.loop.fs_scandir_next(modules_dir) end do
  require(module:gsub(".lua$", ""))
end
