"""""""""""""""
" Options.
" death to vi, long live vim
set nocompatible

" the outside world
set encoding=utf8
set shell=/bin/zsh

" affordances
syntax on
set title
set cursorline
set scrolloff=4 "scroll ahead of the cursor
set number
set ruler
set showcmd "enable a couple of useful realtime prints on the status bar
set showmatch
set bg=dark
set shortmess+=aO
set visualbell t_vb=

" wildmenu
set wildmenu
set wildmode=list:longest,full

" identation, tabs, and text wrap
set autoindent
set smartindent

set expandtab
set shiftwidth=4
set tabstop=4
set softtabstop=4

set tw=80
set wrap
set linebreak

" there is a backspace option
set backspace=indent,eol,start

" text selection
set mouse=a
set virtualedit=block

" search
set smartcase
set incsearch
set hlsearch

" buffers
set hidden
set switchbuf=usetab

" backup and swap
set nobackup
set backupdir=~/.vim-tmp,~/.tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,/tmp

" colors
"colorscheme solarized



"""""""""""""""
" Remaps.
let mapleader = ","
let g:mapleader = ","

" Serious Save
cmap w!! w !sudo tee % > /dev/null

" fast save
nmap <leader>w :w<CR>

" fast buffer switch
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

" vimnav for windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" alternate escape - maybe not so useful
imap <M-Space> <ESC>

" vimline on demand
imap <ESC>v vim:foldmethod=marker autoindent expandtab shiftwidth=4 filetype=



"""""""""""""""
" Plugins.
call pathogen#runtime_append_all_bundles()

" miniBufExplorer
let g:miniBufExplModSelTarget = 1

" filetype
filetype plugin indent on
autocmd FileType xml set shiftwidth=2 tabstop=2 softtabstop=2
" Use the following responsibly.
autocmd FileType gitcommit set nolinebreak

" omnicomplete
set omnifunc=syntaxcomplete#Complete

" taglist
nnoremap <silent> <F8> :TlistToggle<CR>

" and also views
autocmd BufWritePost, BufLeave, WinLeave ?* mkview
autocmd BufReadPre ?* silent loadview


" What's a vimrc without a vimline?
"vim:foldmethod=marker autoindent expandtab shiftwidth=4 filetype=vim

