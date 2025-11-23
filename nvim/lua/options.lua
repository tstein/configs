local api = vim.api
local g = vim.g
local opt = vim.opt

-- interface
opt.mouse = "a"
opt.number = true
opt.pumheight = 10
opt.showtabline = 1  -- only show if >1 tabs
opt.ignorecase = true
opt.smartcase = true  -- only effective when ignorecase is also enabled
opt.switchbuf = "usetab"
opt.undofile = true
-- integrates nvim with the system clipboard
opt.clipboard = "unnamedplus"
opt.cursorline = true

-- fold config from :h vim.lsp.foldexpr
opt.foldmethod = "expr"
opt.foldlevel = 9999
-- lsp folding if client supports it, treesitter if not
opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client:supports_method('textDocument/foldingRange') then
      local win = api.nvim_get_current_win()
      vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
    end
  end,
})


-- scroll ahead of the cursor
opt.scrolloff = 5
opt.sidescrolloff = 10
-- splits shouldn't move the current pane
opt.splitright = true
opt.splitbelow = true
-- indent like it's code even when it isn't
opt.smartindent = true
opt.virtualedit = "block"

-- line length
opt.textwidth = 80
opt.colorcolumn = "+1"  -- textwidth + 1
opt.linebreak = true

-- tabs are two spaces
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2

-- treat _ as a word separator
opt.iskeyword:remove { "_" }

-- enable highlighting of embedded scripts
g.vimsyn_embed = "lpPr"
