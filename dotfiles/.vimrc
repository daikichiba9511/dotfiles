set encoding=utf-8
scriptencoding utf-8

set relativenumber
set nowritebackup
set nobackup
set virtualedit=block
set backspace=indent,eol,start
set ambiwidth=double
set wildmenu

" search {{{
set ignorecase
set smartcase
set wrapscan
set incsearch
set hlsearch
" }}}

" display {{{
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

set clipboard+=unnamedplus
set nrformats=
" }}}

if !has('gui_running') && &term =~ '\%(screen\|tmux\)'
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
set termguicolors

" keymap
nnoremap <Esc><Esc> :nohlsearch<CR><ESC>

if has('filetype')
    filetype indent plugin on
endif

if has('syntax')
    syntax on
endif

" vim-plug {{{
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

"plugin list
call plug#begin()

" カラースキーム
Plug 'cocopon/iceberg.vim'

" Lsp系
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'

" 補完系
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'

" ファイラ
Plug 'lambdalisue/fern.vim'

" Fuzzy Finder系
" Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
" Plug 'junegunn/fzf.vim'

call plug#end()

" }}}

" カラースキーム
set background=dark
colorscheme iceberg

