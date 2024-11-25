# ---------------------------------------------------------------------------------------------
# -- 設定
# -- ヒストリの設定
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
# -- 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups
#-- 同時に起動したzshの間でヒストリを共有
setopt share_history
# -- 直前のコマンドの重複を削除
setopt hist_ignore_dups
# -- ビープ音を鳴らさない
unsetopt beep
# -- ディレクトリスタック
DIRSTACKSIZE=100
setopt AUTO_PUSHD
# --コマンドのスペルを訂正
setopt correct

# -- Julia
export JULIA_VER=1.7.1
export JULIA_NUM_THREADS=4
export PATH="${PATH}:/opt/julia-${JULIA_VER}/bin"
# -- Python 
if command -v pyenv 1>/dev/null 2>&1; then
  export PYENV_ROOT="${HOME}/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
fi
if [[ -d "${HOME}/.rye" ]]; then
  . "${HOME}/.rye/env"
fi
# -- Rust
if [[ -d "${HOME}/.cargo" ]]; then
  # export PATH="$HOME/.cargo/bin:$PATH"
  . "${HOME}/.cargo/env"
fi
#--- Go
export PATH="${HOME}/go/bin:${PATH}"
#--- CmdStan
export CMDSTAN_HOME=/usr/local/bin/cmdstan
#--- Docker
export DOCKER_BUILDKIT=1
#--- Deno
export DENO_INSTALL="${HOME}/.deno"
export PATH="${PATH}:${DENO_INSTALL}/bin"
#--- Terraform
export PATH="${PATH}:${HOME}/.bin"
#--- Tmux
[[ -n "$TMUX" ]] && stty erase '^?'

# -- git
# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# -- 補完候補を詰めて表示
setopt list_packed
autoload colors
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
autoload -Uz compinit && compinit -i # Gitの補完を有効化
export fpath=(~/.zsh/completion $fpath)
fpath+=~/.zfunc

# -- 環境変数
export LANG=ja_JP.UTF-8
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export PATH="${PATH}:./node_modules/.bin"
export XDG_STATE_HOME="${HOME}/.local/state"
export PATH="${PATH}:${HOME}/.local/bin:/usr/local/bin"
export GPG_TTY="$(tty)"  # 署名付きコミットをするために必要

if type "xsel" > /dev/null; then
    alias pbcopy='xsel  --clipboard --input'
fi
# -- ls
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

