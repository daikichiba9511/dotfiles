export CLICOLOR=1
echo Hello ${USER}

zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
fpath=(~/.zsh $fpath)
autoload -Uz compinit && compinit

# Reference:
# 1. https://zenn.dev/fuzmare/articles/zsh-plugin-manager-cache
ZSHRC_DIR=${${(%):-%N}:A:h}
# source command override technique
function ensure_zcompiled {
  local compiled="$1.zwc"

  # skip filedescriptor like /proc/self/fd/N
  if [[ $1 =~ ^/proc ]]; then
    return
  fi
  if [[ $1 =~ ^/dev ]]; then
    return
  fi

  if [[ ! -r "$compiled" || "$1" -nt "$compiled" ]]; then
    echo "\033[1;36mCompiling\033[m $1"
    zcompile $1
  fi
}

function source {
  ensure_zcompiled $1
  builtin source $1
}

# -- sheldon : zsh plugin manager
cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}
sheldon_cache="$cache_dir/sheldon.zsh"
sheldon_toml="$HOME/.config/sheldon/plugins.toml"
# キャッシュがない、またはキャッシュが古い場合にキャッシュを作成
if [[ ! -r "$sheldon_cache" || "$sheldon_toml" -nt "$sheldon_cache" ]]; then
  mkdir -p $cache_dir
  sheldon source > $sheldon_cache
fi
source "$sheldon_cache"
# 使い終わった変数を削除
unset cache_dir sheldon_cache sheldon_toml

#--- Node.js
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# 読み込み
source $ZSHRC_DIR/nonlazy.zsh
zsh-defer source $ZSHRC_DIR/lazy.zsh
# オーバーライドしたsourceを元に戻す
zsh-defer unfunction source

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if type mise &>/dev/null; then
  export PATH="${HOME}/.local/sahre/mise/shims:${PATH}"
  eval "$(mise activate zsh)"
  eval "$(mise activate --shims)"
fi
export SHELL=$(which zsh)

[ -f "${HOME}/.local/bin/mise" ] && eval "$(~/.local/bin/mise activate zsh)"

# -- starship : should be put on last line
eval "$(starship init zsh)"

