set et
set sw=4
set tabstop=4
set softtabstop=4
"set nowrap
set autoindent
set number

set tw=100

syntax on
filetype plugin indent on
let g:asmsyntax="asmx86"
nnoremap <silent> <F8> :TlistToggle<CR>

set smartcase
autocmd BufEnter * lcd %:p:h
set incsearch
set hlsearch
nnoremap <CR> :noh<CR><CR>
set tags=tags;

imap <M-Space> <Esc>

set hidden
set wildmenu
set wildmode=list:longest
set title
set backspace=2

" autobackup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp

" miniBufExplorer settings
let g:miniBufExplModSelTarget = 1

" Set buffer shortcut
nnoremap ,1 :1b<CR>
nnoremap ,2 :2b<CR>
nnoremap ,3 :3b<CR>
nnoremap ,4 :4b<CR>
nnoremap ,5 :5b<CR>
nnoremap ,6 :6b<CR>
nnoremap ,7 :7b<CR>
nnoremap ,8 :8b<CR>
nnoremap ,9 :9b<CR>
nnoremap ,0 :10b<CR>
nnoremap ,, <C-^>

set ruler

"colorscheme desert
