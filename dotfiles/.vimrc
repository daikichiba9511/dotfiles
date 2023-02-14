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

" -- dein {
set nocompatible
let s:dein_base = '~/.local/share/dein'
let s:dein_src = s:dein_base . '/repos/github.com/Shougo/dein.vim'
execute 'set runtimepath^=' . s:dein_src

" check installation
if &runtimepath !~# '/dein.vim'
    if !isdirectory(s:dein_src)
        execute '!git clone https://github.com/Shogo/dein.vim' s:dein_src
    endif
    execute 'set runtimepath^=' . s:dein_src
endif

" begin settings
if dein#load_state(s:dein_base)
    call dein#begin(s:dein_base)
    " -- plugins (
    let s:rc_dir = expand('~/.vim')
    if !isdirectory(s:rc_dir)
        call mkdir(s:rc_dir, 'p')
    endif
    let s:toml = s:rc_dir . '/dein.toml'
    " read toml cache
    " call dein#load_toml(s:toml, {'lazy':0})
    " )

    call dein#add("sickill/vim-monokai")

    call dein#end()
    call dein#save_state()
endif

if has('filetype')
    filetype indent plugin on
endif

if has('syntax')
    syntax on
endif

if dein#check_install()
    call dein#install()
endif

let s:removed_plugins = dein#check_clean()
if len(s:removed_plugins) > 0
    call map(s:removed_plugins, "delete(v:val, 'rf')")
    call dein#recache_runtimepath()
endif
" }

" -- ddc {
" }

" colorscheme iceberg
colorscheme monokai
