"""""""""""""
" interface "
"""""""""""""

set number
set cursorline
" set the traditional line width and wrap intelligently
set tw=80 colorcolumn=80 linebreak
" scroll ahead of the cursor
set scrolloff=5
" splits shouldn't move the current pane
set splitright splitbelow

" tabs are two spaces
set expandtab shiftwidth=2 tabstop=2 softtabstop=2
" indent like it's code even when it isn't
set smartindent

set undofile
set switchbuf=usetab

" fold on {{{ }}}}
set foldmethod=marker
" treat _ as a word separator
set iskeyword-=_
" allow visual block mode to make blocks even where text isn't
set virtualedit=block
" case-insensitive search, unless the pattern contains uppercase
set smartcase

hi LineNr ctermfg=blue
hi CursorLineNr ctermfg=cyan
hi ColorColumn ctermbg=darkgrey guibg=lightgrey


""""""""
" maps "
""""""""

let mapleader = ","
let g:mapleader = ","

" save
nmap <leader>w :w<CR>

" switch buffers
nnoremap <leader>1 :1b<CR>
nnoremap <leader>2 :2b<CR>
nnoremap <leader>3 :3b<CR>
nnoremap <leader>4 :4b<CR>
nnoremap <leader>5 :5b<CR>
nnoremap <leader>6 :6b<CR>
nnoremap <leader>7 :7b<CR>
nnoremap <leader>8 :8b<CR>
nnoremap <leader>9 :9b<CR>
nnoremap <leader>0 :10b<CR>
nnoremap <leader><leader> <C-^>

" clear highlighting on enter
nnoremap <CR> :noh<CR><CR>

" cleanup trailing whitespace
nnoremap <leader>s :%s/\s\+$//<CR>

" conflicts with the escape sequence from screen/tmux
nnoremap <C-a> <Nop>

" save like you mean it
cmap w!! w !sudo tee % >/dev/null


""""""""
" code "
""""""""

" C/C++
autocmd FileType c nmap <leader>cf :%!clang-format<CR>
autocmd FileType cpp nmap <leader>cf :%!clang-format<CR>

" python
autocmd FileType python set textwidth=79
autocmd Filetype python nmap <leader>pf :!yapf -i %<CR><CR>

" wide languages
autocmd FileType cs set textwidth=120 colorcolumn=120
autocmd FileType scala set textwidth=120 colorcolumn=120
autocmd FileType java set textwidth=120 colorcolumn=120


"""""""""""
" plugins "
"""""""""""

" signify - use standard git colors
hi SignifySignAdd cterm=bold ctermfg=green ctermbg=black
hi SignifySignDelete cterm=bold ctermfg=red ctermbg=black
hi SignifySignChange cterm=bold ctermfg=yellow ctermbg=black
