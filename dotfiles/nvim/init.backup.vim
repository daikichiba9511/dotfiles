let s:jetpackfile = expand('<sfile>:p:h') .. '/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim'
let s:jetpackurl = "https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim"
if !filereadable(s:jetpackfile)
  call system(printf('curl -fsSLo %s --create-dirs %s', s:jetpackfile, s:jetpackurl))
endif

" Pluginが読み込む前に設定する必要がある(feline.nvimの起動ができない)
set termguicolors
packadd vim-jetpack

set encoding=utf-8
set cursorline
set fileencoding=utf-8
set fileencodings=ucs-boms,utf-8,euc-jp,cp932
set fileformats=unix,dos,mac
set number
set backspace=indent,eol,start
set showmatch

set wildmenu " コマンドモードの補完
set wildmode=list:longest
set history=5000 " 補完するコマンドの数

set list " 制御文字を表示
set listchars=eol:$,tab:>-

set autoindent
set autoread

" File Tab Config {{
set expandtab " タブ入力を複数の空白入力に置き換える
set smartindent
set tabstop=4
set softtabstop=4
set shiftwidth=4
autocmd FileType javascript setlocal shiftwidth=2 tabstop=2
autocmd FileType typescript setlocal shiftwidth=2 tabstop=2
autocmd FileType html setlocal shiftwidth=2 tabstop=2
autocmd FileType markdown setlocal shiftwidth=2 tabstop=2
" }}


" ClipBoard Config {{
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
set clipboard+=unnamedplus
" }}


" -- StatusLine Config {{
set showmode " 現在のモードを表示
set showcmd " 打ったコマンドをステータスラインの下に表示
set ruler " ステータスラインの右側にカーソルの現在位置を表示する
set colorcolumn=120
" }}


if !exists('g:vscode')
    set ambiwidth=double " □や○文字が崩れる問題を解決
endif

if exists('&ambw')
    set ambiwidth=single
endif

" ファイルタイプ別のVimプラグイン/インデントを有効にする
filetype plugin indent on

" -- Plugin {{

for name in jetpack#names()
  if !jetpack#tap(name)
    call jetpack#sync()
    break
  endif
endfor

call jetpack#begin()
" IDE Likeに楽に設定するのに必要。そのうち組み込みのに乗り換える
Jetpack 'neoclide/coc.nvim', {'branch': 'release'}

" Lua製のプラグインが依存してることが多いから入れておく
Jetpack 'nvim-lua/popup.nvim'
Jetpack 'nvim-lua/plenary.nvim'
Jetpack 'kyazdani42/nvim-web-devicons'

" Font {{
Jetpack 'lambdalisue/nerdfont.vim'
" }}

" Color {{
Jetpack 'shaunsingh/nord.nvim'
Jetpack 'cocopon/iceberg.vim'
Jetpack 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" }}

" StatusLine {{
Jetpack 'feline-nvim/feline.nvim'
" LuaLineとfelineは動かなかったのでとりあえずlightlineを使う
" Jetpack 'itchyny/lightline.vim'
" Jetpack 'akinsho/bufferline.nvim'
" }}

" Filer {{
Jetpack 'sidebar-nvim/sidebar.nvim'
" }}


" Support Edit {{
Jetpack 'folke/todo-comments.nvim'
Jetpack 'lukas-reineke/indent-blankline.nvim'
Jetpack 't9md/vim-quickhl'
Jetpack 'tpope/vim-commentary'
Jetpack 'kassio/neoterm'
Jetpack 'jiangmiao/auto-pairs'
Jetpack 'rcarriga/nvim-notify'
Jetpack 'famiu/bufdelete.nvim'
" }}

" FuzzyFiner {{
Jetpack 'nvim-telescope/telescope.nvim'
Jetpack 'nvim-telescope/telescope-media-files.nvim'
" }}

" Git {{
" Jetpack 'lambdalisue/gina.vim'
Jetpack 'TimUntersberger/neogit'
" }}

" ------- 言語別package
" Python {{
" Jetpack 'vim-python/python-syntax'
" }}


" Rust {{
Jetpack 'rust-lang/rust.vim'
" }}

" Markdown {{
Jetpack 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }}
Jetpack 'dhruvasagar/vim-table-mode'
" }}

" Terraform {{
Jetpack 'hashivim/vim-terraform' , { 'for': 'terraform'}
" }}

" SATySFi {{
" Jetpack 'qnighy/satysfi.vim'
" }}

" Julia {{
" Jetpack 'JuliaLang/julia-vim'
" }}

" Lua {{
" Jetpack 'ckipp01/stylua-nvim'
" }}

call jetpack#end()


" -------- 各種設定
set sh=zsh
set ttimeoutlen=50

" -- KeyConfig {{
inoremap <silent> jj <ESC>
nnoremap <silent> <C-j> :bprev<CR>
nnoremap <silent> <C-k> :bnext<CR>
" }}

" -- buffer
" Reference:
" [1] https://zenn.dev/sa2knight/articles/e0a1b2ee30e9ec22dea9
set hidden " bufferを保存せずに切り替えできる

" ------------ Lua系のplugin
"
lua << EOF

-- Indent-blankline {{
vim.opt.list = true
vim.opt.listchars:append('eol:$')

require('indent_blankline').setup({
    show_end_of_line = true,
    space_char_blankline = ' ',
    show_current_context = true,
    show_current_context_start = true,
})
-- }}

-- Todo-comments {{
require('todo-comments').setup({})
-- }}

-- Sidebar {{
require('sidebar-nvim').setup({
    open = false, -- 開いたときにsidebarを表示するか
    hide_statusline = true,
    sections = { 'todos', 'files', 'git',},  -- TODO:diagnositicsはbuild-inのlspから取ってくるからcocから移行したら設定する
    files = {
        icon = '',
        show_hidden = false,
        ignored_paths = {"%.git$"},
    },
    todos = {
        icon = '',
        ignored_paths = {'~'}, -- ignore certain paths, this will prevent huge folders like $HOME to hog Neovim with TODO searching
        initially_closed = false, -- whether the groups should be initially closed on start. You can manually open/close groups later.
    },
    symbols = {
        icon = 'ƒ',
    },
    buffers = {
        icon = "",
        ignored_buffers = {}, -- ignore buffers by regex
        sorting = "id", -- alternatively set it to "name" to sort by buffer name instead of buf id
        show_numbers = true, -- whether to also show the buffer numbers
        ignore_not_loaded = false, -- whether to ignore not loaded buffers
        ignore_terminal = true, -- whether to show terminal buffers in the list
    },
})

-- KeyConfig of sidebar
-- CTRL + bでSidebarをtoggleするscroll backを潰したかったけどcocのhover scrolとconflictする（あまりつかってないから）
-- fernのコマンドと合わせて<Leader> = default "\" + "e"に当てた
-- silentで実行コマンドを出さないようにする
vim.api.nvim_set_keymap('n', '<Leader>e', ':SidebarNvimToggle <CR>', { noremap = true, silent = true })

-- }}

-- Treesitter {{
require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'python',
    'rust',
    'typescript',
    'html',
    'javascript',
    'tsx',
    'yaml',
    'toml',
    'vim',
    'make',
    'latex',
    'json',
    'dockerfile',
    'cpp',
    'bash',
    'lua'
  },
  highlight = {
    enable = true, -- false will disable the whole extension
  },
})
-- }}

-- Bufferline{{
require('bufferline').setup({})
-- }}
vim.api.nvim_set_keymap('n', '[b', ':BuuferLineCycleNext <CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'b]', ':BuuferLineCyclePrev <CR>', { noremap = true, silent = true })

-- BufDelete
vim.api.nvim_set_keymap("n", "bw", ":Bwipeout! <CR>", { noremap = true, silent = true })

-- Git {{
require('neogit').setup({})
-- }}

EOF
" }}


"-- Telescope settings {{
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>fm <cmd>Telescope media_files<cr>

lua << EOF
require('telescope').load_extension('media_files')
require('telescope').setup {
  extensions = {
    media_files = {
      -- filetypes whitelist
      -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
      filetypes = {"png", "webp", "jpg", "jpeg", "pdf"},
      find_cmd = "fd" -- find command (defaults to `fd`)
    }
  },
}
EOF
" }}

" -- Feline {{
lua << EOF
require('feline').setup({})
EOF
set laststatus=2 " ステータスラインを常に表示
set noshowmode
" }}

"

" ------------ vim script系のplugin

" -- ligthine {{
" let g:lightline = { "colorscheme": "iceberg"}
" set laststatus=2 " ステータスラインを常に表示
" set noshowmode
"  }}
"
" -- Color {{
syntax enable
syntax on

colorscheme iceberg
" lua << EOF
" require('nord').set()
" EOF

" if exists('+termguicolors')
"     let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
"     let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
"     set termguicolors
" endif
" }}

" -- CoC {{
" Install CoC Plugin List
let g:coc_global_extensions = [
    \ 'coc-eslint8',
    \ 'coc-html',
    \ 'coc-json',
    \ 'coc-lists',
    \ 'coc-prettier',
    \ 'coc-pyright',
    \ 'coc-rust-analyzer',
    \ 'coc-sh',
    \ 'coc-sql',
    \ 'coc-tsserver',
    \ 'coc-sumneko-lua',
    \ 'coc-vimlsp'
\]

" Python
autocmd FileType python let b:coc_root_patterns = [
    \ '.git',
    \ '.env' ,
    \ 'venv',
    \ '.venv',
    \ 'setup.cfg',
    \ 'setup.py',
    \ 'pyproject.toml',
    \ 'pyrightconfig.json'
\]

" TypeScript
function! s:coc_typescript_settings() abort
  nnoremap <silent> <buffer> [dev]f :<C-u>CocCommand eslint.executeAutofix<CR>:CocCommand prettier.formatFile<CR>
endfunction

augroup coc_ts
  autocmd!
  autocmd FileType typescript,typescriptreact call <SID>coc_typescript_settings()
augroup END

" KeyConfig of CoC
function! s:show_documentation() abort
  if index(['vim','help'], &filetype) >= 0
    execute 'h ' . expand('<cword>')
  elseif coc#rpc#ready()
    call CocActionAsync('doHover')
  endif
endfunction


" Hover
inoremap <silent> <expr> <C-Space> coc#refresh()
nnoremap <silent> K       :<C-u>call <SID>show_documentation()<CR>
nmap     <silent> [dev]rn <Plug>(coc-rename)
nmap     <silent> [dev]a  <Plug>(coc-codeaction-selected)iw

" Scrol hover
nnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"

" Move
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

command! -nargs=0 Prettier :CocCommand prettier.forceFormatDocument

" }}

" -- Terminal {{
" Reference:
" [1] https://sy-base.com/myrobotics/vim/neovim-neoterm/
" [2] https://wonderwall.hatenablog.com/entry/2019/08/25/190000

let g:neoterm_default_mod='belowright'
let g:neoterm_size=20
let g:neoterm_autoscroll=1

nnoremap @p :T python %<CR>
autocmd TermOpen * startinsert

nnoremap <C-t><C-t> :Ttoggle<CR>
tnoremap <C-t><C-t> <C-\><C-n> :Ttoggle<CR>
tnoremap <silent> <ESC> <C-\><C-n><C-w>
command! -nargs=* T split | wincmd j resize 20 | terminal <args>
" }}

" -- Rust {{
let g:rustfmt_autsave = 1
" }}


" -- Markdown {{
" Reference:
" [1] https://github.com/iamcco/markdown-preview.nvim
let g:table_mode_corner = '|'
" }}

" -- Json {{
let g:conceallevel=0
" }}


" -- 背景透過(transparency) {{
" highlight Normal ctermbg=NONE guibg=NONE
" highlight NonText ctermbg=NONE guibg=NONE
" highlight LineNr ctermbg=NONE guibg=NONE
" highlight Folded ctermbg=NONE guibg=NONE
" highlight EndOfBuffer ctermbg=NONE guibg=NONE
" }}
