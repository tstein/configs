local g = vim.g
local opt = vim.opt

-- interface
opt.mouse = "a"
opt.number = true
opt.pumheight = 10
opt.showtabline = 1  -- only show if >1 tabs
opt.smartcase = true
opt.switchbuf = "usetab"
opt.undofile = true
-- integrates nvim with the system clipboard
opt.clipboard = "unnamedplus"
opt.cursorline = true
opt.foldmethod = "marker"
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
g.vimsyn_embed = "lrP"
