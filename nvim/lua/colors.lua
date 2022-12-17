vim.api.nvim_exec(
[[
  hi LineNr ctermfg=blue
  hi CursorLineNr ctermfg=cyan
  hi ColorColumn ctermbg=darkgrey guibg=lightgrey

  " signify - use standard git colors
  hi SignifySignAdd cterm=bold ctermfg=green ctermbg=black
  hi SignifySignDelete cterm=bold ctermfg=red ctermbg=black
  hi SignifySignChange cterm=bold ctermfg=yellow ctermbg=black

  if has('termguicolors')
    set termguicolors
  endif
  let g:edge_style = 'neon'
  let g:edge_better_performance = 1
  colorscheme edge
  let g:transparent_enabled = v:true
]], false)
