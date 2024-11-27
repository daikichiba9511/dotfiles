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

set clipboard+=unnamed
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

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gs <plug>(lsp-document-symbol-search)
    nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> [g <plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g <plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)
    nnoremap <buffer> <expr><c-f> lsp#scroll(+4)
    nnoremap <buffer> <expr><c-d> lsp#scroll(-4)

    let g:lsp_format_sync_timeout = 1000
    autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
    
    " refer to doc to add more commands
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

"plugin list
call plug#begin()

" カラースキーム
" Plug 'cocopon/iceberg.vim'
" Plug 'catppuccin/vim', { 'as': 'catppuccin' }
Plug 'tomasr/molokai'

" Lsp系
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'

" 補完系
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'

" ファイラ
" Plug 'lambdalisue/fern.vim'

" Fuzzy Finder系
" Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
" Plug 'junegunn/fzf.vim'

call plug#end()

" }}}

" カラースキーム
" set background=dark
" colorscheme iceberg
" colorscheme catppuccin_mocha
colorscheme molokai


