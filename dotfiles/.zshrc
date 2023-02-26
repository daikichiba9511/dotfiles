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
setopt no_beep

# -- ディレクトリスタック
DIRSTACKSIZE=100
setopt AUTO_PUSHD

# -- zplug {{{
export ZPLUG_HOME=${HOME}/.zplug
source $ZPLUG_HOME/init.zsh
# -- zsh plugins {{
# syntax highlight
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "chrissicool/zsh-256color"

# assist input
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
# }}

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# }}}

# Then, source plugins and add commands to $PATH
zplug load --verbose

# -- zsh-syntax-highlighting
if [ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# -- 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# -- 補完候補を詰めて表示
setopt list_packed

# -- 補完候補一覧をカラー表示
autoload colors
zstyle ':completion:*' list-colors ''

# --コマンドのスペルを訂正
setopt correct

# -- git
autoload -Uz compinit && compinit  # Gitの補完を有効化

# -- コマンドの実行ごとに改行
function precmd() {

    # Print a newline before the prompt, unless it's the
    # first prompt in the process.
    if [ -z "$NEW_LINE_BEFORE_PROMPT" ]; then
        NEW_LINE_BEFORE_PROMPT=1
    elif [ "$NEW_LINE_BEFORE_PROMPT" -eq 1 ]; then
        echo ""
    fi
}

# For neovim
export PATH=$PATH:./node_modules/.bin
export XDG_STATE_HOME=~/.local/state

# -- .zfunc
fpath+=~/.zfunc

# -- julia
export PATH="$PATH:/opt/julia-1.7.1/bin"

# alias julia1.6="/Applications/Julia-1.6.app/Contents/Resources/julia/bin/julia"
export JULIA_CMDSTAN_HOME=/usr/local/bin/cmdstan
# launchctl setenv JULIA_CMDSTAN_HOME /usr/local/bin/cmdstan
export JULIA_NUM_THREADS=4

# -- Python (pyenv)
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
fi

# -- Rust
export PATH=$HOME/.config/coc/extensions/node_modules:$PATH

# -- Go
export PATH=$HOME/go/bin:$PATH

# -- CmdStan
export CMDSTAN_HOME=/usr/local/bin/cmdstan
# launchctl setenv CMDSTAN_HOME /usr/local/bin/cmdstann

# -- Docker
export DOCKER_BUILDKIT=1

# -- deno
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# -- terraform
export PATH=$PATH:$HOME/.bin

# -- tmux
[[ -n "$TMUX" ]] && stty erase '^?'

function tide() {
    tmux split-window -v
    tmux split-window -h
    tmux split-window -h
    tmux resize-pane -D 15
    tmux select-pane -t 1
}

function wide() {
    local pane_size=${1:-60}
    wezterm cli split-pane --right --percent "${pane_size}"
    wezterm cli split-pane --bottom
}

export PATH="$PATH:$HOME/.local/bin"
export PATH=/usr/local/bin:$PATH

if type "xsel" > /dev/null; then
    alias pbcopy='xsel  --clipboard --input'
fi


# -- ls
alias ls="ls --color"
alias la="ls --color -a"
alias ll="ls --color -l"
alias lla="ls --color -l -a"

if [[ $(command -v exa) ]]; then
  alias e='exa --icons'
  alias l=e
  alias ls=e
  alias ea='exa -a --icons'
  alias la=ea
  alias ee='exa -aal --icons'
  alias ll=ee
  alias et='exa -T -L 3 -a -I "node_modules|.git|.cache" --icons'
  alias lt=et
  alias eta='exa -T -a -I "node_modules|.git|.cache" --color=always --icons | less -r'
  alias lta=eta
fi

# -- git
alias g="git"
alias gs="git status -u"
alias ga="git add -v"
alias gcm="git commit"
alias gdf="git diff"
alias gpush="git push"
alias gpull="git pull"
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gco="git checkout"

# -- log
function cdlog() {
    # create daily log file
    local datetime=$(date +%Y-%m-%d)
    local log_file_name="${datetime}.md"
    touch ${log_file_name}
    echo "#${datetime}" >> ${log_file_name}
    cat ~/dotfiles/dotfiles/base_logs.md >> ${log_file_name}
    echo "✅ ${log_file_name} is created."
}

# -- vim
alias v="nvim"

# -- starship : should be put on last line
eval $(starship init zsh)
