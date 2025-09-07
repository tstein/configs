require("bufferline").setup{}
require("lualine").setup{}
require("gitsigns").setup {
  signs = {
    delete       = { text = '▁', show_count = true },
    topdelete    = { text = '▔', show_count = true },
    changedelete = { text = '~', show_count = true },
  }
}
