
set encoding=utf-8
" highlight of current line
set cursorline
set guicursor=


set fileencoding=utf-8 " 保存時の文字コード
set fileencodings=ucs-boms,utf-8,euc-jp,cp932 " 読み込み時の文字コードの自動判別. 左側が優先される
set fileformats=unix,dos,mac " 改行コードの自動判別. 左側が優先される

if !exists('g:vscode')
       set ambiwidth=double " □や○文字が崩れる問題を解決
endif
if exists('&ambw')
    set ambiwidth=single
endif
    " ================================= 行番号を表示
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
" ============================== コマンドラインの補完
" ==============================
set wildmenu " コマンドモードの補完
set history=5000 " 補完するコマンドの数

set wildmode=list:longest


" =============================
" 不可視文字を可視化
" =============================
set list " 制御文字を表示
set listchars=eol:$,tab:>-
" --------------- tab -----------------------


set autoindent " 改行時に前の行のインデントを継続する
set smartindent

set autoread " 内容が変更されたら自動的にreload

" ============================
" 行頭以外のTab文字の表示幅
" ===========================
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab " タブ入力を複数の空白入力に置き換える


" ================================
" クリップボードからのペースト設定
" ================================
if &term =~ "xterm"
    let &t_SI .= "\e[?2004h"
    let &t_EI .= "\e[?2004l"
    let &pastetoggle = "\e[201~"

    function XTermPasteBegin(ret) set paste
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
set colorcolumn=119


" ファイルタイプ別のVimプラグイン/インデントを有効にする
filetype plugin indent on

" 未インストールのVimプラグインがある場合、インストールするかどうかを尋ねてくれるようにする設定・・・・・・③

call plug#begin('~/.vim/plugged')

" Plug 'prabirshrestha/vim-lsp'
" Plug 'mattn/vim-lsp-settings'

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
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'Yggdroot/indentLine'

" =====
" comment
" =====
Plug 'tpope/vim-commentary'

" =====
" rust
" =====
Plug 'rust-lang/rust.vim'

" =====
" python
" =====
Plug 'vim-python/python-syntax'

" =====
" terminal
" =====
Plug 'kassio/neoterm'

" =====
" markdown
" =====
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
Plug 'dhruvasagar/vim-table-mode'

" =====
" bracket autocompletion
" =====
Plug 'jiangmiao/auto-pairs'

" =====
" git
" =====
Plug 'tpope/vim-fugitive'

" =====
" fzf
" =====
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }

" =====
" asynchronously
" =====
" こっちはALEより古いらしい
" Plug 'neomake/neomake'

Plug 'dense-analysis/ale'


call plug#end()

" =============================
" nerdtree settings
" =============================
nmap <C-b> :NERDTreeToggle<CR>

" =============================
" airline settings
" =============================
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
nmap <C-p> <Plug>AirlineSelectPrevTab
nmap <C-n> <Plug>AirlineSelectNextTab

" insert to normal quickly
set ttimeoutlen=50


" =============================
" treesitter
" =============================
lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  highlight = {
    enable = true,              -- false will disable the whole extension
    disable = { "vue", "ruby" },  -- list of language that will be disabled
  },
}
EOF



" =============================
" NeoMake
" https://github.com/neomake/neomake
" =============================
" autocmd! BufEnter,BufWritePost * Neomake
" let g:neomake_python_enabled_makers = ['python', 'flake8', 'mypy']

" =============================
" ALE
" Ref
" * https://github.com/neomake/neomake
" * https://github.com/neomake/neomake
" =============================
" 開いた瞬間のlintをオフ（これでパッと開ける）
let g:ale_lint_on_enter = 0
let g:ale_fix_on_save = 1
let g:ale_linters = {
\   'python': ['flake8', 'mypy'],
\   'markdown': ['textlint'],
\}

let g:ale_fixers = {
    \ 'python': ['black', 'isort'],
    \ }

nmap <silent> <Leader>x <Plug>(ale_fix)

" =============================
" Netrw
" =============================


" ==============================
" syntax highlight
" ==============================

syntax enable
filetype plugin indent on

" Plugが探し終えた後じゃないとエラーになる
syntax on
if exists('+termguicolors')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    set termguicolors
endif

let ayucolor="mirage"
colorscheme ayu


" let g:lsp_diagnostics_echo_cursor = 1
" let g:lsp_settings = {
" \    'efm-langserver': {
" \       'disabled': 0,
" \       'allowlist': ['markdown'],
" \    },
" \}


" let g:lsp_signs_error = {'text': 'E'}
" let g:lsp_signs_warning = {'text': 'W'}
" if !has('nvim')
  " let g:lsp_diagnostics_float_cursor = 1
" endif
" let g:lsp_log_file = ''

" ===============
" python
" ===============
let g:python_highlight_all = 1
autocmd FileType python let b:coc_root_patterns = ['.git', '.env', 'venv', '.venv', 'setup.cfg', 'setup.py', 'pyproject.toml', 'pyrightconfig.json']

" vim-lspのpycodestyleをoffにしてflake8にする
" let g:lsp_settings = {
  " \  'pylsp-all': {
  " \    'workspace_config': {
  " \      'pylsp': {
  " \        'configurationSources': ['flake8'],
  " \        'plugins': {
  " \          'flake8': {
  " \            'enabled': 1,
  " \            "ignore": ["E203", "W503", "504", "W391", "E402"],
  " \            "max-line-length": 119
  " \          },
  " \          'mccabe': {
  " \            'enabled': 0
  " \          },
  " \          'pycodestyle': {
  " \            'enabled': 0
  " \          },
  " \          'pyflakes': {
  " \            'enabled': 0
  " \          },
  " \          'pyls-black': { 'enabled': 1, "line-length": 119
  " \           } 
  " \        }
  " \      }
  " \    }
  " \  }
  " \}

" function! s:on_lsp_buffer_enabled() abort
  " setlocal completeopt=menu
  " setlocal omnifunc=lsp#complete
" endfunction

" augroup lsp_install
  " au!
  " au User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
" augroup END

" autocmd BufWritePre <buffer> LspDocumentFormatSync

inoremap <silent> jj <ESC>

" カッコの保管 -> auto-pairsに移行
" inoremap { {}<Left>
" inoremap {<Enter> {}<Left><CR><ESC><S-o>
" inoremap ( ()<ESC>i
" inoremap (<Enter> ()<Left><CR><ESC><S-o>

" ========
" rust
" ========
let g:rustfmt_autsave = 1
" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)


" ========
" neovim内でデフォルトで起動するシェルを変える
" デフォルトはsh
" ========
set sh=zsh


" =========
" neotermの設定
" 参考:
" [1] https://sy-base.com/myrobotics/vim/neovim-neoterm/
" [2] https://wonderwall.hatenablog.com/entry/2019/08/25/190000
" =========
" Ttoggleはneotermのterminal windowの切り替え
nnoremap <C-t><C-t> :Ttoggle<CR>
" terminal modeの時は<C-\n><C-n>でターミナルモードを抜けてから:Ttoggleを実行
tnoremap <C-t><C-t> <C-\><C-n> :Ttoggle<CR>
" ESCでターミナルモードを抜ける
tnoremap <silent> <ESC> <C-\><C-n><C-w>
" Tでターミナルを開いたときにウィンドウ下部に開く
command! -nargs=* T split | wincmd j resize 20 | terminal <args>
" 常にinsert mode
autocmd TermOpen * startinsert



" 起動時の位置
let g:neoterm_default_mod='belowright'
" 起動時のサイズ
let g:neoterm_size=20
" 起動時に画面下部に実行結果が表示される
let g:neoterm_autoscroll=1

" 今編集してるpythonファイルを走らせる
" %はカレントファイル名
nnoremap @p :T python %<CR>


" =============
" buffer周りの設定
" 参考
" [1] https://zenn.dev/sa2knight/articles/e0a1b2ee30e9ec22dea9
" =============
nnoremap <silent> <C-j> :bprev<CR>
nnoremap <silent> <C-k> :bnext<CR>

" bufferを保存せずに切り替えできる
set hidden

" ===============
" markdown
" Ref
" https://github.com/iamcco/markdown-preview.nvim
" ===============

" vim-table-mode
let g:table_mode_corner = '|'

" ===============
" vim-fugitive
" ===============
nmap [figitive] <Nop>
map <Leader>g [figitive]
nmap <silent> [figitive]s :<C-u>Gstatus<CR>
nmap <silent> [figitive]d :<C-u>Gdiff<CR>
nmap <silent> [figitive]b :<C-u>Gblame<CR>
nmap <silent> [figitive]l :<C-u>Glog<CR>



