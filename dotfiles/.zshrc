export CLICOLOR=1

echo hello. ${USER}


#========================
# 環境変数
#========================
export LANG=ja_JP.UTF-8


#========================
# ヒストリの設定
#========================
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000


#========================
# 直前のコマンドの重複を削除
#========================
setopt hist_ignore_dups


#========================
# 同じコマンドをヒストリに残さない
#========================
setopt hist_ignore_all_dups


#========================
# 同時に起動したzshの間でヒストリを共有
#========================
setopt share_history


#========================
# 補完機能を有効にする
#========================
zshpath=~/.zshrc/completion
autoload -Uz compinit
compinit -u
if [ -e ${zshpath} ]; then
  fpath=(${zshpath} $fpath)
fi


#========================
# 補完で小文字でも大文字にマッチさせる
#========================
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'


#========================
# 補完候補を詰めて表示
#========================
setopt list_packed


#========================
# 補完候補一覧をカラー表示
#========================
autoload colors
zstyle ':completion:*' list-colors ''


#========================
# コマンドのスペルを訂正
#========================
setopt correct


#========================
# ビープ音を鳴らさない
#========================
setopt no_beep


#========================
# ディレクトリスタック
#========================
DIRSTACKSIZE=100
setopt AUTO_PUSHD


#========================
# git
#========================
autoload -Uz compinit && compinit  # Gitの補完を有効化
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{magenta}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{yellow}+"
zstyle ':vcs_info:*' formats "%F{cyan}%c%u[%b]%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'
precmd () { vcs_info }

# git ブランチ名を色付きで表示させるメソッド
function git-current-branch {
  local branch_name st branch_status

  branch='\ue0a0'
  color='%{\e[38;5;' #  文字色を設定
  green='114m%}'
  red='001m%}'
  yellow='227m%}'
  blue='033m%}'
  reset='%{\e[0m%}'   # reset

  if [ ! -e  ".git" ]; then
    # git 管理されていないディレクトリは何も返さない
    return
  fi
  branch_name=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
  st=`git status 2> /dev/null`
  if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
    # 全て commit されてクリーンな状態
    branch_status="${color}${green}${branch} "
  elif [[ -n `echo "$st" | grep "^Untracked files"` ]]; then
    # git 管理されていないファイルがある状態
    branch_status="${color}${red}${branch} ?"
  elif [[ -n `echo "$st" | grep "^Changes not staged for commit"` ]]; then
    # git add されていないファイルがある状態
    branch_status="${color}${red}${branch} +"
  elif [[ -n `echo "$st" | grep "^Changes to be committed"` ]]; then
    # git commit されていないファイルがある状態
    branch_status="${color}${yellow}${branch} !"
  elif [[ -n `echo "$st" | grep "^rebase in progress"` ]]; then
    # コンフリクトが起こった状態
    echo "${color}${red}${branch}!(no branch)${reset}"
    return
  else
    # 上記以外の状態の場合
    branch_status="${color}${blue}${branch} "
  fi
  # ブランチ名を色付きで表示する
  echo "${branch_status}$branch_name${reset} "
}

# プロンプトが表示されるたびにプロンプト文字列を評価、置換する
setopt prompt_subst

# プロンプトの右側にメソッドの結果を表示させる
# RPROMPT='`git-current-branch`'

#========================
# zsh-syntax-highlighting
#========================
if [ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi


#========================
# プロンプトカスタマイズ
#========================
function left-prompt {
  name_t='179m%}'      # user name text clolr
  name_b='000m%}'    # user name background color
  path_t='255m%}'     # path text clolr
  path_b='031m%}'   # path background color
  arrow='087m%}'   # arrow color
  text_color='%{\e[38;5;'    # set text color
  back_color='%{\e[30;48;5;' # set background color
  reset='%{\e[0m%}'   # reset
  sharp='\uE0B0'      # triangle

  user="${back_color}${name_b}${text_color}${name_t}"
  dir="${back_color}${path_b}${text_color}${path_t}"
  echo "${user}%n%#@%m${back_color}${path_b}${text_color}${name_b}${sharp} ${dir}%~${reset}${text_color}${path_b}${sharp} "'`git-current-branch`'"${reset}\n${text_color}${arrow}$ ${reset}"
}

PROMPT=`left-prompt`


# コマンドの実行ごとに改行
function precmd() {
    # Print a newline before the prompt, unless it's the
    # first prompt in the process.
    if [ -z "$NEW_LINE_BEFORE_PROMPT" ]; then
        NEW_LINE_BEFORE_PROMPT=1
    elif [ "$NEW_LINE_BEFORE_PROMPT" -eq 1 ]; then
        echo ""
    fi
}

# ========================
# .zfunc
# ========================
fpath+=~/.zfunc

# ========================
# julia
# ========================

alias julia1.6="/Applications/Julia-1.6.app/Contents/Resources/julia/bin/julia"
export JULIA_CMDSTAN_HOME=/usr/local/bin/cmdstan
# launchctl setenv JULIA_CMDSTAN_HOME /usr/local/bin/cmdstan
export JULIA_NUM_THREADS=4

# ===============================
# pyenv
# ===============================
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
fi


# ===============================
# CmdStan
# ===============================
export CMDSTAN_HOME=/usr/local/bin/cmdstan
# launchctl setenv CMDSTAN_HOME /usr/local/bin/cmdstann 

export DOCKER_BUILDKIT=1

# ===============================
# Rust
# ===============================
# for rust-analyzer
export PATH=/Users/chibadaimare/.config/coc/extensions/node_modules:$PATH

# ===============================
# tmux
# ===============================
[[ -n "$TMUX" ]] && stty erase '^?'

# ================================
# .local/bin
# ================================
export PATH="$PATH:$HOME/.local/bin"
