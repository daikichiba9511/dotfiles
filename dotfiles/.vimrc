set encoding=utf-8
scriptencoding utf-8
let mapleader = "\<Space>"

set relativenumber
set nowritebackup
set nobackup
set virtualedit=block
set backspace=indent,eol,start
set ambiwidth=single
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
set listchars=tab:>-,space:·
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
nnoremap <C-j> :bnext<CR>
nnoremap <C-k> :bprevious<CR>

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

" ===============================================
"  NVM + Node.js Management for CoC
" ===============================================
" Settings: customize these if needed
let g:coc_nvm_dir = get(g:, 'coc_nvm_dir', expand('~/.vim/nvm'))
let g:coc_node_version = get(g:, 'coc_node_version', '20')  " Major version only = auto-update minor
let g:coc_node_ready = v:false

function! s:find_latest_node_version(nvm_dir, ver_pattern) abort
  " Find the latest installed version matching the pattern
  let l:versions_dir = a:nvm_dir . '/versions/node'
  if !isdirectory(l:versions_dir)
    return ''
  endif

  let l:pattern = 'v' . a:ver_pattern . '.'
  let l:versions = globpath(l:versions_dir, l:pattern . '*', 0, 1)
  if empty(l:versions)
    return ''
  endif

  " Sort versions and get the latest
  let l:sorted = sort(l:versions, {a, b -> a > b ? -1 : a < b ? 1 : 0})
  return fnamemodify(l:sorted[0], ':t')
endfunction

function! s:ensure_nvm_and_node() abort
  let l:nvm_dir = g:coc_nvm_dir
  let l:ver = g:coc_node_version

  " Fast path: find latest installed version matching the pattern
  let l:latest_ver = s:find_latest_node_version(l:nvm_dir, l:ver)
  if !empty(l:latest_ver)
    let l:node_bin = l:nvm_dir . '/versions/node/' . l:latest_ver . '/bin'
    if isdirectory(l:node_bin)
      let $PATH = l:node_bin . ':' . $PATH
      " Set explicit Node.js path for CoC
      let g:coc_node_path = l:node_bin . '/node'
      let g:coc_node_ready = v:true
      return
    endif
  endif

  " Check bash availability (required for nvm)
  if !executable('bash')
    echohl ErrorMsg
    echom '[CoC] bash is required to use nvm. CoC will not be loaded.'
    echohl None
    return
  endif

  " Install nvm if not present
  if !filereadable(l:nvm_dir . '/nvm.sh')
    if !executable('git')
      echohl ErrorMsg
      echom '[CoC] git is required to install nvm. CoC will not be loaded.'
      echohl None
      return
    endif

    echom '[CoC] Installing nvm to ' . l:nvm_dir . '...'
    call mkdir(l:nvm_dir, 'p')
    let l:nvm_tag = 'v0.39.7'
    let l:clone_cmd = 'git clone --depth 1 --branch ' . shellescape(l:nvm_tag)
          \ . ' https://github.com/nvm-sh/nvm.git ' . shellescape(l:nvm_dir)
    call system(l:clone_cmd)

    if v:shell_error != 0
      echohl ErrorMsg
      echom '[CoC] Failed to clone nvm. CoC will not be loaded.'
      echohl None
      return
    endif
    echom '[CoC] nvm installed successfully.'
  endif

  " Install Node.js via nvm (installs latest of specified version)
  echom '[CoC] Installing Node.js v' . l:ver . ' (latest available)...'
  let l:cmd = printf(
        \ 'export NVM_DIR=%s; . %s/nvm.sh; nvm install %s >/dev/null 2>&1; nvm use %s >/dev/null 2>&1; node -v',
        \ shellescape(l:nvm_dir),
        \ shellescape(l:nvm_dir),
        \ shellescape(l:ver),
        \ shellescape(l:ver)
        \ )

  let l:out = system('bash -c ' . shellescape(l:cmd))
  if v:shell_error != 0
    echohl ErrorMsg
    echom '[CoC] Node.js installation failed. CoC will not be loaded.'
    echom '[CoC] Error: ' . l:out
    echohl None
    return
  endif

  " Find the actual installed version and add to PATH
  let l:installed_ver = s:find_latest_node_version(l:nvm_dir, l:ver)
  if !empty(l:installed_ver)
    let l:node_bin = l:nvm_dir . '/versions/node/' . l:installed_ver . '/bin'
    if isdirectory(l:node_bin)
      let $PATH = l:node_bin . ':' . $PATH
      " Set explicit Node.js path for CoC
      let g:coc_node_path = l:node_bin . '/node'
      let g:coc_node_ready = v:true
      echom '[CoC] Node.js ' . l:installed_ver . ' installed and configured successfully.'
    else
      echohl ErrorMsg
      echom '[CoC] Node.js bin directory not found after install: ' . l:node_bin
      echohl None
    endif
  else
    echohl ErrorMsg
    echom '[CoC] Could not find installed Node.js version in ' . l:nvm_dir
    echohl None
  endif
endfunction

" Setup Node.js before loading plugins
call s:ensure_nvm_and_node()

" ===============================================
"  CoC Node.js Management Commands
" ===============================================

" Show current Node.js version
function! s:show_node_version() abort
  if !g:coc_node_ready
    echohl WarningMsg
    echom '[CoC] Node.js is not configured'
    echohl None
    return
  endif

  let l:node_version = system('node --version 2>/dev/null')
  if v:shell_error == 0
    echom '[CoC] Current Node.js: ' . trim(l:node_version)
  else
    echohl ErrorMsg
    echom '[CoC] Failed to get Node.js version'
    echohl None
  endif
endfunction

" Update Node.js to latest minor/patch version
function! s:update_node_version() abort
  let l:nvm_dir = g:coc_nvm_dir
  let l:ver = g:coc_node_version

  if !executable('bash')
    echohl ErrorMsg
    echom '[CoC] bash is required to update Node.js'
    echohl None
    return
  endif

  if !filereadable(l:nvm_dir . '/nvm.sh')
    echohl ErrorMsg
    echom '[CoC] nvm is not installed. Please restart Vim to install.'
    echohl None
    return
  endif

  " Get current version before update
  let l:old_ver = s:find_latest_node_version(l:nvm_dir, l:ver)

  echom '[CoC] Updating Node.js v' . l:ver . ' to latest version...'
  let l:cmd = printf(
        \ 'export NVM_DIR=%s; . %s/nvm.sh; nvm install %s 2>&1',
        \ shellescape(l:nvm_dir),
        \ shellescape(l:nvm_dir),
        \ shellescape(l:ver)
        \ )

  let l:out = system('bash -c ' . shellescape(l:cmd))
  if v:shell_error != 0
    echohl ErrorMsg
    echom '[CoC] Node.js update failed.'
    echom '[CoC] Error: ' . l:out
    echohl None
    return
  endif

  " Find the newly installed version
  let l:new_ver = s:find_latest_node_version(l:nvm_dir, l:ver)

  if empty(l:new_ver)
    echohl ErrorMsg
    echom '[CoC] Could not find updated Node.js version'
    echohl None
    return
  endif

  " Update PATH
  let l:node_bin = l:nvm_dir . '/versions/node/' . l:new_ver . '/bin'
  if isdirectory(l:node_bin)
    " Remove old version from PATH and add new one
    let l:path_parts = split($PATH, ':')
    let l:filtered_parts = filter(l:path_parts, 'v:val !~# "' . escape(l:nvm_dir, '/') . '"')
    let $PATH = l:node_bin . ':' . join(l:filtered_parts, ':')
    " Update CoC node path
    let g:coc_node_path = l:node_bin . '/node'

    if l:old_ver ==# l:new_ver
      echom '[CoC] Already on latest version: ' . l:new_ver
    else
      echohl MoreMsg
      echom '[CoC] Updated: ' . (empty(l:old_ver) ? 'none' : l:old_ver) . ' → ' . l:new_ver
      echohl None
      echom '[CoC] Restart Vim to reload CoC with new Node.js version'
    endif
  else
    echohl ErrorMsg
    echom '[CoC] Node.js bin directory not found: ' . l:node_bin
    echohl None
  endif
endfunction

" Define commands
command! CoCNodeVersion call s:show_node_version()
command! CoCUpdateNode call s:update_node_version()
command! CoCDebug call s:show_coc_debug_info()

" Debug command to show CoC setup status
function! s:show_coc_debug_info() abort
  echo '=== CoC Debug Info ==='
  echo 'g:coc_node_ready: ' . g:coc_node_ready
  if exists('g:coc_node_path')
    echo 'g:coc_node_path: ' . g:coc_node_path
  else
    echo 'g:coc_node_path: NOT SET'
  endif
  echo 'Node in PATH: ' . (executable('node') ? 'YES' : 'NO')
  if executable('node')
    echo 'node --version: ' . system('node --version')
  endif
  echo 'CoC loaded: ' . (exists('g:did_coc_loaded') ? 'YES' : 'NO')
  echo 'CoC status: ' . (exists('*CocAction') ? 'AVAILABLE' : 'NOT AVAILABLE')
endfunction

"plugin list
call plug#begin()

" カラースキーム
Plug 'cocopon/iceberg.vim'
Plug 'catppuccin/vim', { 'as': 'catppuccin' }
Plug 'tomasr/molokai'
Plug 'bluz71/vim-moonfly-colors', { 'as': 'moonfly' }
Plug 'bluz71/vim-nightfly-colors', { 'as': 'nightfly' }
Plug 'ayu-theme/ayu-vim'

" Lsp系
" Plug 'prabirshrestha/vim-lsp'
" Plug 'mattn/vim-lsp-settings'
" Plug 'prabirshrestha/asyncomplete.vim'
" Plug 'prabirshrestha/asyncomplete-lsp.vim'

" Load CoC only if Node.js is ready
if g:coc_node_ready
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
endif

" 補完系

" ファイラ
Plug 'lambdalisue/fern.vim'
Plug 'lambdalisue/fern-renderer-nerdfont.vim'
Plug 'lambdalisue/nerdfont.vim'
Plug 'lambdalisue/glyph-palette.vim'

" Fuzzy Finder系
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'tpope/vim-sleuth'
Plug 'tribela/vim-transparent'
Plug 'tpope/vim-commentary'

call plug#end()

runtime! ftplugin/man.vim

" }}}
"
" --------------
"  Fern
" --------------
let g:fern#renderer = 'nerdfont'
let g:fern#default_hidden = 1

augroup fern_custom
  autocmd! *
  autocmd FileType fern call glyph_palette#apply()
augroup END

nnoremap <Leader>e :Fern . -drawer<CR>



" ---------------
"
"  CoC
" ---------------
let g:coc_global_extensions = ['coc-lists']

function! CoCSettings() abort
    " https://raw.githubusercontent.com/neoclide/coc.nvim/master/doc/coc-example-config.vim

    " May need for Vim (not Neovim) since coc.nvim calculates byte offset by count
    " utf-8 byte sequence
    set encoding=utf-8
    " Some servers have issues with backup files, see #649
    set nobackup
    set nowritebackup

    " Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
    " delays and poor user experience
    set updatetime=300

    " Always show the signcolumn, otherwise it would shift the text each time
    " diagnostics appear/become resolved
    set signcolumn=yes

    inoremap <silent><expr> <TAB>
                \ coc#pum#visible() ? coc#pum#next(1) :
                \ CheckBackspace() ? "\<TAB>" :
                \ coc#refresh()

    inoremap <expr><S-TAB> coc#pub#visible() ? coc#pub#prev(1) : "\<C-h>"
    " Use <c-space> to trigger completion
    inoremap <silent><expr> <c-@> coc#refresh()
    " Use <enter> to insert the completion
    inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

    " Use `[g` and `]g` to navigate diagnostics
    " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
    nmap <silent><nowait> [g <Plug>(coc-diagnostic-prev)
    nmap <silent><nowait> ]g <Plug>(coc-diagnostic-next)

    " GoTo code navigation
    nmap <silent><nowait> gd <Plug>(coc-definition)
    nmap <silent><nowait> gy <Plug>(coc-type-definition)
    nmap <silent><nowait> gi <Plug>(coc-implementation)
    nmap <silent><nowait> gr <Plug>(coc-references)

    " Use K to show documentation in preview window
    nnoremap <silent> K :call ShowDocumentation()<CR>

    " Highlight the symbol and its references when holding the cursor
    autocmd CursorHold * silent call CocActionAsync('highlight')

    " Symbol renaming
    nmap <leader>rn <Plug>(coc-rename)

    " Formatting selected code
    xmap <leader>f  <Plug>(coc-format-selected)
    nmap <leader>f  <Plug>(coc-format-selected)

    augroup mygroup
      autocmd!
      " Setup formatexpr specified filetype(s)
      autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    augroup end

    " Applying code actions to the selected code block
    " Example: `<leader>aap` for current paragraph
    xmap <leader>a  <Plug>(coc-codeaction-selected)
    nmap <leader>a  <Plug>(coc-codeaction-selected)

    " Remap keys for applying code actions at the cursor position
    nmap <leader>ac  <Plug>(coc-codeaction-cursor)
    " Remap keys for apply code actions affect whole buffer
    nmap <leader>as  <Plug>(coc-codeaction-source)
    " Apply the most preferred quickfix action to fix diagnostic on the current line
    nmap <leader>qf  <Plug>(coc-fix-current)

    " Remap keys for applying refactor code actions
    nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
    xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
    nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)

    " Run the Code Lens action on the current line
    nmap <leader>cl  <Plug>(coc-codelens-action)
    " Map function and class text objects
    " NOTE: Requires 'textDocument.documentSymbol' support from the language server
    xmap if <Plug>(coc-funcobj-i)
    omap if <Plug>(coc-funcobj-i)
    xmap af <Plug>(coc-funcobj-a)
    omap af <Plug>(coc-funcobj-a)
    xmap ic <Plug>(coc-classobj-i)
    omap ic <Plug>(coc-classobj-i)
    xmap ac <Plug>(coc-classobj-a)
    omap ac <Plug>(coc-classobj-a)

    " Remap <C-f> and <C-b> to scroll float windows/popups
    if has('nvim-0.4.0') || has('patch-8.2.0750')
      nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
      nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
      inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
      inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
      vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
      vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
    endif

    " Use CTRL-S for selections ranges
    " Requires 'textDocument/selectionRange' support of language server
    nmap <silent> <C-s> <Plug>(coc-range-select)
    xmap <silent> <C-s> <Plug>(coc-range-select)

    " Add `:Format` command to format current buffer
    command! -nargs=0 Format :call CocActionAsync('format')

    " Add `:Fold` command to fold current buffer
    command! -nargs=? Fold :call     CocAction('fold', <f-args>)

    " Add `:OR` command for organize imports of the current buffer
    command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

    " Add (Neo)Vim's native statusline support
    " NOTE: Please see `:h coc-status` for integrations with external plugins that
    " provide custom statusline: lightline.vim, vim-airline
    set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

    " Mappings for CoCList
    " Show all diagnostics
    nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
    " Manage extensions
    " nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
    " Find Files
    nnoremap <silent><nowait> <space><space>f :<C-u>CocList --auto-preview files<cr>
    " Show commands
    nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
    " Find symbol of current document
    nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
    " Search workspace symbols
    nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
    " Do default action for next item
    nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
    " Do default action for previous item
    nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
    " Resume latest coc list
    nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
    " Find most recent used
    nnoremap <silent><nowait> <space><space>r :<C-u>CocList --auto-preview mru<CR>

endfunction

" Helper functions for CoC (must be defined before CoCSettings)
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Only configure CoC if Node.js is ready
if g:coc_node_ready
  call CoCSettings()
endif

" CoC Fold キーバインド
nnoremap <leader>zf :Fold<CR>
nnoremap <leader>z1 :Fold 1<CR>
nnoremap <leader>z2 :Fold 2<CR>
nnoremap <leader>zo :normal! zR<CR>

" カラースキーム
set background=dark
" colorscheme iceberg
" colorscheme catppuccin_mocha
" colorscheme molokai
" colorscheme molokai
" colorscheme moonfly
" colorscheme nightfly
colorscheme ayu

" 背景透過トグル
let g:transparent_enabled = v:false
augroup TransparentDisable
    autocmd!
    autocmd VimEnter * TransparentDisable
augroup END
nnoremap <Leader>bg :TransparentToggle<CR>
