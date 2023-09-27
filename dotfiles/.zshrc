export CLICOLOR=1
echo hello. ${USER}


# -- vim mode
# bindkey -v

# -- 環境変数
export LANG=ja_JP.UTF-8
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share

# -- ヒストリの設定
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
# -- 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups
#-- 同時に起動したzshの間でヒストリを共有
setopt share_history

# -- 直前のコマンドの重複を削除
setopt hist_ignore_dups

# -- ビープ音を鳴らさない
# setopt no_beep
unsetopt beep

# -- ディレクトリスタック
DIRSTACKSIZE=100
setopt AUTO_PUSHD

# -- zplug {{{
# export ZPLUG_HOME=${HOME}/.zplug
# source $ZPLUG_HOME/init.zsh
# # -- zsh plugins {{
# # syntax highlight
# zplug "zsh-users/zsh-syntax-highlighting", defer:2
# zplug "chrissicool/zsh-256color"
#
# # assist input
# zplug "zsh-users/zsh-history-substring-search"
# zplug "zsh-users/zsh-autosuggestions"
# zplug "zsh-users/zsh-completions"
# # }}
#
# # Install plugins if there are plugins that have not been installed
# if ! zplug check --verbose; then
#     printf "Install? [y/N]: "
#     if read -q; then
#         echo; zplug install
#     fi
# fi
#
# # }}}
#
# # Then, source plugins and add commands to $PATH
# zplug load --verbose
#
# # -- zsh-syntax-highlighting
# if [ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
#   source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# fi

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)


# -- 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# -- 補完候補を詰めて表示
setopt list_packed

# -- 補完候補一覧をカラー表示
autoload colors
zstyle ':completion:*' list-colors ''

# --コマンドのスペルを訂正
setopt correct

# ====================================
# -- git
# ====================================
autoload -Uz compinit && compinit -i # Gitの補完を有効化

export fpath=(~/.zsh/completion $fpath)

# ====================================
# -- コマンドの実行ごとに改行
# ====================================
function precmd() {

    # Print a newline before the prompt, unless it's the
    # first prompt in the process.
    if [ -z "$NEW_LINE_BEFORE_PROMPT" ]; then
        NEW_LINE_BEFORE_PROMPT=1
    elif [ "$NEW_LINE_BEFORE_PROMPT" -eq 1 ]; then
        echo ""
    fi
}

# ====================================
# For neovim
# ====================================
export PATH=$PATH:./node_modules/.bin
export PATH=$HOME/.nodebrew/current/bin:$PATH
export XDG_STATE_HOME=~/.local/state

# ====================================
# -- .zfunc
# ====================================
fpath+=~/.zfunc

# ====================================
# -- julia
# ====================================
export PATH="$PATH:/opt/julia-1.7.1/bin"

# alias julia1.6="/Applications/Julia-1.6.app/Contents/Resources/julia/bin/julia"
export JULIA_CMDSTAN_HOME=/usr/local/bin/cmdstan
# launchctl setenv JULIA_CMDSTAN_HOME /usr/local/bin/cmdstan
export JULIA_NUM_THREADS=4

# ====================================
# -- Python (pyenv)
# ====================================
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
fi

# ====================================
# -- Rust
# ====================================
export PATH=$HOME/.config/coc/extensions/node_modules:$PATH

# ====================================
# -- Go
# ====================================
export PATH=$HOME/go/bin:$PATH

# ====================================
# -- CmdStan
# ====================================
export CMDSTAN_HOME=/usr/local/bin/cmdstan
# launchctl setenv CMDSTAN_HOME /usr/local/bin/cmdstann

# ====================================
# -- Docker
# ====================================
export DOCKER_BUILDKIT=1

# ====================================
# -- deno
# ====================================
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# ====================================
# -- terraform
# ====================================
export PATH=$PATH:$HOME/.bin

# ====================================
# -- tmux
# ====================================
[[ -n "$TMUX" ]] && stty erase '^?'

# ====================================
# tmuxの使用時にtile状にpaneをsplitする
# ====================================
function tide() {
    tmux split-window -v
    tmux split-window -h
    tmux split-window -h
    tmux resize-pane -D 15
    tmux select-pane -t 1
}

# ====================================
# weztermを使用してpaneをsplitする
# ====================================
function wide() {
    local pane_size=${1:-70}
    wezterm cli split-pane --right --percent "${pane_size}"
    wezterm cli split-pane --bottom
}

export PATH="$PATH:$HOME/.local/bin"
export PATH=/usr/local/bin:$PATH

if type "xsel" > /dev/null; then
    alias pbcopy='xsel  --clipboard --input'
fi


# ====================================
# -- ls
# ====================================
alias ls="ls --color"
alias la="ls --color -a"
alias ll="ls --color -l"
alias lla="ls --color -l -a"

if [[ $(command -v lsd) ]]; then
  alias ls='lsd'
  alias ll='ls -l'
  alias la='ls -la'
  alias lla='ls -la'
  alias lt='ls --tree'
fi

# ====================================
# -- git
# ====================================
alias g="git"
# alias gs="git status -u"
# alias ga="git add -v"
# alias gcm="git commit"
# alias gdf="git diff"
alias gps="git push"
alias gpl="git pull"
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
# alias gco="git checkout"

# ====================================
# logをつける用のマークダウンを生成する
# ====================================
function cdlog() {
    # create daily log file
    local today=$(date +%Y-%m-%d)
    local log_file_name="${today}.md"
    touch ${log_file_name}
    echo "#${today}" >> ${log_file_name}
    cat ~/dotfiles/dotfiles/base_logs.md >> ${log_file_name}
    echo "✅ ${log_file_name} is created."
}

# ====================================
# fuzzy search files and open with vscode
# fzfで見つけたファイルをvscodeで開く
# ====================================
function fv {
    local filename=$(fzf --preview 'bat --color=always {1} --highlight-line {2}')
    if [ $? = 0 ]; then
        code "${filename}"
    fi }
# ====================================
# fuzzy search files and open with neovim
# fzfで見つけたファイルをvscodeで開く
# ====================================
function fn {
    local filename=$(fzf --preview 'bat --color=always {1} --highlight-line {2}')
    if [ $? = 0 ]; then
        nvim "${filename}"
    fi
}

# ====================================
# -- vim
# ====================================
alias v="nvim"

# ====================================
#
# ====================================
[ -f "/home/d-chiba/.ghcup/env" ] && source "/home/d-chiba/.ghcup/env" # ghcup-env


# ====================================
# asdf
# ====================================
# . "${HOME}/.asdf/asdf.sh"
fpath=(${ASDF_DIR}/completions $fpath)
autoload -Uz compinit && compinit

# ====================================
# cuda
# ====================================
export CUDA_PATH=/usr/local/cuda-12

export LD_LIBRARY_PATH=/usr/local/cuda-11.8/lib64:${LD_LIBRARY_PATH}
export PATH=/usr/local/cuda-11.8/bin:${PATH}

# =====================================
# sheldon : zsh plugin manager
# =====================================
eval "$(sheldon source)"

# =====================================
# nnn
# =====================================
export NNN_PLUG='f:finder;o:fzopen;p:mocq;d:diffs;t:nmount;v:imgview;p:preview-tui'

# =====================================
# measurement utils
# Ref: https://zenn.dev/yutakatay/articles/zsh-neovim-speedcheck
# =====================================
function nvim-startuptime() {
  local file=$1
  local total_msec=0
  local msec
  local i
  for i in $(seq 1 10); do
    msec=$({(TIMEFMT='%mE'; time nvim --headless -c q $file ) 2>&3;} 3>/dev/stdout >/dev/null)
    msec=$(echo $msec | tr -d "ms")
    echo "${(l:2:)i}: ${msec} [ms]"
    total_msec=$(( $total_msec + $msec ))
  done
  local average_msec
  average_msec=$(( ${total_msec} / 10 ))
  echo "\naverage: ${average_msec} [ms]"
}

function nvim-startuptime-slower-than-default() {
  local file=$1
  local time_file_rc
  time_file_rc=$(mktemp --suffix "_nvim_startuptime_rc.txt")
  local time_rc
  time_rc=$(nvim --headless --startuptime ${time_file_rc} -c "quit" $file > /dev/null && tail -n 1 ${time_file_rc} | cut -d " " -f1)

  local time_file_norc
  time_file_norc=$(mktemp --suffix "_nvim_startuptime_norc.txt")
  local time_norc
  time_norc=$(nvim --headless --noplugin -u NONE --startuptime ${time_file_norc} -c "quit" $file > /dev/null && tail -n 1 ${time_file_norc} | cut -d " " -f1)

  echo "my vimrc: ${time_rc}s\ndefault neovim: ${time_norc}s\n"
  local result
  result=$(scale=3 echo "${time_rc} / ${time_norc}" | bc)
  echo "${result}x slower your Neovim than the default."
}

function nvim-profiler() {
  local file=$1
  local time_file
  time_file=$(mktemp --suffix "_nvim_startuptime.txt")
  echo "output: $time_file"
  time nvim --headless --startuptime $time_file -c q $file
  tail -n 1 $time_file | cut -d " " -f1 | tr -d "\n" && echo " [ms]\n"
  cat $time_file | sort -n -k 2 | tail -n 20
}

# ====================================
# -- starship : should be put on last line
# ====================================
eval $(starship init zsh)


