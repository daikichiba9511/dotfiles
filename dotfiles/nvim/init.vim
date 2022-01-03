
set encoding=utf-8
scriptencoding utf-8

set fileencoding=utf-8 " 保存時の文字コード
set fileencodings=ucs-boms,utf-8,euc-jp,cp932 " 読み込み時の文字コードの自動判別. 左側が優先される
set fileformats=unix,dos,mac " 改行コードの自動判別. 左側が優先される

if !exists('g:vscode')
       set ambiwidth=double " □や○文字が崩れる問題を解決
endif
if exists('&ambw')
    set ambiwidth=single
endif
    " =================================
" 行番号を表示
" =================================
set number

" ================================
" 挿入モードでバックスペースで削除できるようにする
" ===============================
set backspace=indent,eol,start

" ==============================
" 対応する括弧を強調する
" ==============================
set showmatch

" ==============================
" コマンドラインの補完
" ==============================
set wildmenu " コマンドモードの補完
set history=5000 " 補完するコマンドの数

set wildmode=list:longest


" =============================
" 不可視文字を可視化
" =============================
set list " 制御文字を表示
set listchars=eol:$,tab:>-,space:.,
" --------------- tab -----------------------

set expandtab " タブ入力を複数の空白入力に置き換える

set autoindent " 改行時に前の行のインデントを継続する
set smartindent

set autoread " 内容が変更されたら自動的にreload

" ============================
" 行頭以外のTab文字の表示幅
" ===========================
set tabstop=4


" ================================
" クリップボードからのペースト設定
" ================================
if &term =~ "xterm"
    let &t_SI .= "\e[?2004h"
    let &t_EI .= "\e[?2004l"
    let &pastetoggle = "\e[201~"

    function XTermPasteBegin(ret)
        set paste
        return a:ret
    endfunction

    inoremap <special> <expr> <Esc>[200~ XTermPasteBegin("")
endif

" ====================================
" vim plugin の管理
" ====================================
" ステータスラインの設定
"----------------------------------------------------------
set laststatus=2 " ステータスラインを常に表示
set showmode " 現在のモードを表示
set showcmd " 打ったコマンドをステータスラインの下に表示
set ruler " ステータスラインの右側にカーソルの現在位置を表示する
" set colorcolumn=119


" ファイルタイプ別のVimプラグイン/インデントを有効にする
filetype plugin indent on

" 未インストールのVimプラグインがある場合、インストールするかどうかを尋ねてくれるようにする設定・・・・・・③

call plug#begin('~/.vim/plugged')

"ここからdeoplete本体
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'

" Plug 'prabirshrestha/asyncomplete.vim'
" Plug 'prabirshrestha/asyncomplete-lsp.vim'
" let g:deoplete#enable_at_startup = 1


"pythonの自動補完プラグイン（任意）

"Plug 'deoplete-plugins/deoplete-jedi'

"Vim用自動補完プラグイン（任意）

Plug 'Shougo/neco-vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
"Plug 'JuliaLang/julia-vim'
Plug 'itchyny/lightline.vim'
Plug 'ayu-theme/ayu-vim'
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'rust-lang/rust.vim'
Plug 'vim-python/python-syntax'

call plug#end()

" =============================
" nerdtree settings
" =============================
nmap <C-b> :NERDTreeToggle<CR>

" =============================
" airline settings
" =============================
" let g:airline_powerline_fonts = 1
" let g:airline#extensions#tabline#enabled = 1
" nmap <C-p> <Plug>AirlineSelectPrevTab
" nmap <C-n> <Plug>AirlineSelectNextTab

" insert to normal quickly
set ttimeoutlen=50

" =============================
" Netrw
" =============================


" ==============================
" syntax highlight
" ==============================
" Plugが探し終えた後じゃないとエラーになる
syntax on
if exists('+termguicolors')
        let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
        set termguicolors
endif
let ayucolor="mirage"
colorscheme ayu

let g:lsp_diagnostics_echo_cursor = 1
let g:lsc_server_commands = {'python3': 'pyls'}
"let g:lsp_settings = {
"\    'pyls-all': {
"\      'workspace_config': {
"\         'pyls': {
"\             'configurationSources': ['flake8']
"\          }
"\      }
"\    },
"\    'efm-langserver': {
"\       'disabled': 0,
"\       'allowlist': ['markdown'],
"\    },
"\}
let g:lsp_settings = {
\        'efm-langserver':{
\          'disabled':0,
\          'allowlist':['markdown'],
\        },
\}

if executable('rust-analyzer')
        au User lsp_setup call lsp#register_server({
            \   'name': 'Rust Language Server',
            \   'cmd': {server_info->['rust-analyzer']},
            \   'whitelist': ['rust'],
            \   'initialization_options': {
            \       'cargo': {
            \           'loadOutDirsFromCheck': v:true,
            \       },
            \       'procMacro': {
            \           'enable': v:true,
            \       },
            \   },
            \})
endif

" rust auto format
let g:rustfmt_autosave = 1

let g:lsp_signs_error = {'text': 'E'}
let g:lsp_signs_warning = {'text': 'W'}
if !has('nvim')
  let g:lsp_diagnostics_float_cursor = 1
endif
let g:lsp_log_file = ''

" ===============
" python
" ===============
let g:python_highlight_all = 1

function! s:on_lsp_buffer_enabled() abort
  setlocal completeopt=menu
  setlocal omnifunc=lsp#complete
endfunction

augroup lsp_install
  au!
  au User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END


autocmd BufWritePre <buffer> LspDocumentFormatSync

inoremap <silent> jj <ESC>
inoremap { {}<Left>
inoremap {<Enter> {}<Left><CR><ESC><S-o>
inoremap ( ()<ESC>i
inoremap (<Enter> ()<Left><CR><ESC><S-o>

set hidden
