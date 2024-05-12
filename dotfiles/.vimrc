set encoding=utf-8
scriptencoding utf-8

set relativenumber
set nowritebackup
set nobackup
set virtualedit=block
set backspace=indent,eol,start
set ambiwidth=double
set wildmenu

" -- search {
set ignorecase
set smartcase
set wrapscan
set incsearch
set hlsearch
" }

" -- display {
set termguicolors
set noerrorbells
set showmatch matchtime=1
set cinoptions+=:0
set cmdheight=1
set laststatus=2
set showcmd
set display=lastline
set list
set listchars="tab:>-"
set history=5000

set expandtab
set smarttab
set shiftwidth=4
set softtabstop=4
set tabstop=8
set autoindent
set smartindent

set guioptions=2
set guioptions+=a
set guioptions-=m

set showmatch
set noswapfile

set wildmenu
set autoread
set title

set clipboard=unnamed,autoselect
set nrformats=

" keymap (
nnoremap <Esc><Esc> :nohlsearch<CR><ESC>
" )
" }

if has('filetype')
    filetype indent plugin on
endif

if has('syntax')
    syntax on
endif
