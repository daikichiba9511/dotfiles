export CLICOLOR=1
echo Hello ${USER}

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
if command -v pyenv 1>/dev/null 2>&1; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
fi
if [[ -d "$HOME/.rye" ]]; then
  . "$HOME/.rye/env"
fi

# ====================================
# -- Rust
# ====================================
if [[ -d "$HOME/.cargo" ]]; then
  # export PATH="$HOME/.cargo/bin:$PATH"
  . "$HOME/.cargo/env"
fi

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

# pathを通す
export PATH="$PATH:$HOME/.local/bin"
export PATH=/usr/local/bin:$PATH
export PATH="${PATH}:$HOME/.fzf_bin/bin"  # for fzf installed via ~/.fzf_bin/install

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
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

alias lg="lazygit"

# ====================================
# fzf
# ====================================
alias fzf='fzf --border=rounded'

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
    local filename=$(fzf --preview 'bat --color=always {}')
    if [ $filename != "" ]; then
        code "${filename}"
    fi 
}
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
# fuzzy image cat
# fzfで見つけた画像を表示する
#
# 探す拡張子は以下
# - "png"
# - "jpg"
#
# depends on:
# - fzf
#   - chafa (to preview images)
# - fd
# - wezterm/img2sixel
# ====================================
function fic() {
    local is_in_tmux=$([ "${TMUX}" = "" ] && echo "false" || echo "true")

    local img_cat_cmd="wezterm imgcat"
    if [ "${is_in_tmux}" = "true" ]; then
      img_cat_cmd="img2sixel"
    else
      if command -v "wezterm" > /dev/null; then
        img_cat_cmd="wezterm imgcat"
      elif command -v "img2sixel" > /dev/null; then
        img_cat_cmd="img2sixel"
      else
        echo "No image viewer is found."
        return 1
      fi
    fi

    # I want to use 'wezterm imgcat' to preview images, but It does'n work well with latest fzf
    # Please see below issue for more detail.
    # https://github.com/junegunn/fzf/issues/3646
    local filenames=$(fd -I -e "png" -e "jpg")
    if [[ "${filenames}" = "" ]]; then
      echo "No such file to preview images."
      return 0
    fi

    # alternative cmd to peview: fzf --preview 'fzf-preview.sh {}'
    local filename=$(
      echo "${filenames[@]}" |
        fzf --preview 'chafa -f sixel -s ${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES} {}'
    )
    if [[ "${filename}" = "" ]]; then
      echo "No file is selected."
      return 0
    fi


    if [ $? = 0 ]; then
        echo "-- ${img_cat_cmd} ${filename} --"
        /usr/bin/env bash -c "${img_cat_cmd} ${filename}"
    fi
}
# ====================================
# -- fuzzy hisotry command
# ====================================
function fhc() {
  cmd=$(history -5000 | tac |  fzf | sed 's/ *[0-9]* *//')
  if [ $? = 0 ]; then
    echo "executing: ${cmd}"
    eval "${cmd}"
  else 
    echo "no command is selected."
  fi
}

function fzf-hisotry-search() {
  fhc
  zle redisplay
}

# <C-R> で fzfを使った逆検索を実行
zle -N fzf-hisotry-search
bindkey '^R' fzf-hisotry-search

# ====================================
# -- vim
# ====================================
alias v="nvim"

# ====================================
#
# ====================================
[ -f "/home/d-chiba/.ghcup/env" ] && source "/home/d-chiba/.ghcup/env" # ghcup-env


# ====================================
# -- VSCode
# ====================================
function cf() {
  local filename=$(fzf --preview 'bat --color=always {1}')
  if [ $? = 0 ]; then
      code "${filename}"
  fi
}

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
# function nvim-startuptime() {
#   local file=$1
#   local total_msec=0
#   local msec
#   local i
#   for i in $(seq 1 10); do
#     msec=$({(TIMEFMT='%mE'; time nvim --headless -c q $file ) 2>&3;} 3>/dev/stdout >/dev/null)
#     msec=$(echo $msec | tr -d "ms")
#     echo "${(l:2:)i}: ${msec} [ms]"
#     total_msec=$(( $total_msec + $msec ))
#   done
#   local average_msec
#   average_msec=$(( ${total_msec} / 10 ))
#   echo "\naverage: ${average_msec} [ms]"
# }
#
# function nvim-startuptime-slower-than-default() {
#   local file=$1
#   local time_file_rc
#   time_file_rc=$(mktemp --suffix "_nvim_startuptime_rc.txt")
#   local time_rc
#   time_rc=$(nvim --headless --startuptime ${time_file_rc} -c "quit" $file > /dev/null && tail -n 1 ${time_file_rc} | cut -d " " -f1)
#
#   local time_file_norc
#   time_file_norc=$(mktemp --suffix "_nvim_startuptime_norc.txt")
#   local time_norc
#   time_norc=$(nvim --headless --noplugin -u NONE --startuptime ${time_file_norc} -c "quit" $file > /dev/null && tail -n 1 ${time_file_norc} | cut -d " " -f1)
#
#   echo "my vimrc: ${time_rc}s\ndefault neovim: ${time_norc}s\n"
#   local result
#   result=$(scale=3 echo "${time_rc} / ${time_norc}" | bc)
#   echo "${result}x slower your Neovim than the default."
# }
#
# function nvim-profiler() {
#   local file=$1
#   local time_file
#   time_file=$(mktemp --suffix "_nvim_startuptime.txt")
#   echo "output: $time_file"
#   time nvim --headless --startuptime $time_file -c q $file
#   tail -n 1 $time_file | cut -d " " -f1 | tr -d "\n" && echo " [ms]\n"
#   cat $time_file | sort -n -k 2 | tail -n 20
# }


# ====================================
# -- Prompt Customization
# ====================================
# カラー設定
# CYAN="%F{cyan}"
# BLUE="%F{blue}"
# LIGHT_BLUE="%F{lightblue}"
# GREEN="%F{green}"
# YELLOW="%F{yellow}"
# WHITE="%F{255}"
# RED="%F{red}"
#
# # Background Color
# BG_CYAN="%K{26}"
# BG_BLUE="%K{blue}"
# BG_BLACK="%K{black}"
# BG_LIGHT_BLUE="%K{031}"
# BG_GRAY="%K{237}"
#
# # リセット
# RESET="%f"
# BG_RESET="%k"
#
# CMD_STATUS_COLOR="%F{green}"
#
# function set_cmd_status_color() {
#     if [ $? -eq 0 ]; then
#         CMD_STATUS_COLOR="%F{green}"
#     else
#         CMD_STATUS_COLOR="%F{red}"
#     fi
# }
#
#
# # GIT_BRANCH_PROMPT=""
#
# function git-current-branch() {
#     local branch_name st branch_status
#     branch_name=$(git symbolic-ref --short HEAD 2> /dev/null)
#     if [ ! -e ".git" ]; then
#         return
#     fi
#
#     st=$(git status 2> /dev/null)
#
#     if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
#         # すべてコミット済み
#         branch_status="${GREEN}"
#     elif [[ -n `echo "$st" | grep "^Untracked files"` ]]; then
#         # Untracked filesがある
#         branch_status="${RED}"
#     elif [[ -n `echo "$st" | grep "^Changes to be committed"` ]]; then
#         # Staged changesがある
#         branch_status="${YELLOW}"
#     elif [[ -n `echo "$st" | grep "^Changes not staged"` ]]; then
#         # Unstaged changesがある
#         branch_status="${RED}"
#     else
#         # その他
#         branch_status="${CYAN}"
#     fi
#
#     echo "${branch_status}${branch_name}${RESET}"
#     # GIT_BRANCH_PROMPT="${branch_status}${branch_name}${RESET}"
# }
#
#
# function prompt() {
#     # sheldon使えば簡単に設定できるけどインストールできない環境があったりするのでプラグイン使わない
#     # %n: ユーザ名
#     # %m: ホスト名の最初の部分
#     # %1~: カレントディレクトリ
#     # %#: ユーザー権限によって表示を変える (#: root, $: 一般ユーザ)
#
#
#     # 各々のプロンプトの設定
#     local USER_PROMPT="${BG_BLACK}${YELLOW} %n@%m  ${RESET}${BG_RESET}"
#     local DIR_POMPT="${BG_LIGHT_BLUE}${WHITE} %1~ ${RESET}${BG_RESET}"
#     if [ -e ".git" ]; then
#         # gitリポジトリの場合
#         local GIT_BRANCH_PROMPT="${BG_GRAY}${WHITE} on $(git-current-branch) ${RESET}${BG_RESET}"
#     else
#         # gitリポジトリでない場合
#         local GIT_BRANCH_PROMPT=""
#     fi
#     local CMD_PROMPT="${CMD_STATUS_COLOR}%(!.#.$) ${RESET}"
#
#     # 改行がそのまま表示される
#     PROMPT="${USER_PROMPT}${DIR_POMPT}${GIT_BRANCH_PROMPT}
# ${CMD_PROMPT}"
# }
#
# function precmd() {
#     set_cmd_status_color
#     # コマンドの実行後にpromptを実行したいのでhookを設定
#     prompt
# }

# コマンドの実行後にpromptを実行したいのでhookを設定
# add-zsh-hook precmd precmd


# ====================================
# -- starship : should be put on last line
# ====================================
eval "$(starship init zsh)"
#
