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
set colorcolumn=80
hi ColorColumn ctermbg=darkgrey guibg=lightgrey
set scrolloff=4 "scroll ahead of the cursor
set laststatus=2
set number
set ruler
set showcmd "enable a couple of useful realtime prints on the status bar
set showmatch
set bg=dark
set shortmess+=aO
set visualbell t_vb=
set ttimeoutlen=0
set list
set listchars=tab:»·,trail:·

" wildmenu
set wildmenu
set wildmode=list:longest,full

" identation, tabs, and text wrap
set autoindent
set smartindent

set expandtab
set shiftwidth=2
set tabstop=2
set softtabstop=2

set tw=80
set wrap
set linebreak

" folding
set foldmethod=marker

" there is a backspace option
set backspace=indent,eol,start

" text selection
set virtualedit=block

" search
set smartcase
set incsearch
set hlsearch

" buffers
set hidden
set switchbuf=usetab

" backup, swap, and undo
set nobackup
set writebackup
set undofile
set backupdir=~/.local/tmp
set directory=~/.local/tmp
set undodir=~/.local/tmp

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

" Fast trailing whitespace cleanup.
nnoremap <leader>s :%s/\s\+$//<CR>

" vimnav for windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l
map <leader>r <C-W>=<C-W>k<C-W>k<C-W>100-<C-W>j

" alternate escape - maybe not so useful
imap <M-Space> <ESC>

" vimline on demand
imap <ESC>v vim:foldmethod=marker autoindent expandtab shiftwidth=2 filetype=

" Conflicts with a tic from screen/tmux.
nnoremap <C-a> <Nop>

" filetype
filetype plugin indent on
"set omnifunc=syntaxcomplete#Complete
if has("autocmd") && exists("+omnifunc")
   autocmd Filetype *
       \    if &omnifunc == "" |
       \        setlocal omnifunc=syntaxcomplete#Complete |
       \    endif
endif

autocmd FileType python set textwidth=79
autocmd FileType java set textwidth=100 colorcolumn=100
" Use the following responsibly.
autocmd FileType gitcommit set nolinebreak


"""""""""""""""
" Plugins.
" vundle
set rtp+=~/.vim/bundle/vundle
call vundle#rc()
Bundle 'airblade/vim-gitgutter'
Bundle 'bling/vim-airline'
Bundle 'fholgado/minibufexpl.vim'
Bundle 'fs111/pydoc.vim'
Bundle 'gmarik/vundle'
Bundle 'scrooloose/syntastic'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-surround'
Bundle 'Valloric/YouCompleteMe'
Bundle 'vim-scripts/file-line'
Bundle 'vim-scripts/taglist.vim'
Bundle 'vim-scripts/TaskList.vim'
Bundle 'vim-scripts/tComment'
Bundle 'vim-scripts/UltiSnips'

" airline
let g:airline_powerline_fonts=1

" miniBufExplorer
let g:miniBufExplModSelTarget = 1

" syntastic
let g:syntastic_check_on_open=1
let g:syntastic_cpp_check_header = 1
let g:syntastic_cpp_auto_refresh_includes = 1
let g:syntastic_java_checkers = ['javac']
let g:syntastic_javascript_checkers = ['gjslint']
let g:syntastic_ruby_checkers = ['ruby', 'rubocop']

" taglist
nnoremap <silent> <F8> :TlistToggle<CR>

" and also views
autocmd BufWritePost, BufLeave, WinLeave ?* mkview
autocmd BufReadPre ?* silent loadview

" Go
set rtp+=$GOROOT/misc/vim
autocmd BufRead,BufNewFile *.go set filetype=go

" What's a vimrc without a vimline?
"vim:foldmethod=marker autoindent expandtab shiftwidth=2 filetype=vim

