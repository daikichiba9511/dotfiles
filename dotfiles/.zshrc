export CLICOLOR=1
echo Hello ${USER}

zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
fpath=(~/.zsh $fpath)
fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
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

osc52() {
  local data
  data=$(base64 | tr -d '\r\n')
  if [ -n "$TMUX" ]; then
    # tmux越しでも確実に通すための DCS パススルー
    printf '\033Ptmux;\033\033]52;c;%s\a\033\\' "$data"
  else
    printf '\033]52;c;%s\a' "$data"
  fi
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
source $ZSHRC_DIR/lazy.zsh
# オーバーライドしたsourceを元に戻す
unfunction source

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source <(fzf --zsh)

export SHELL=$(which zsh)
export PATH="${HOME}/dotfiles/dotfiles/bin:${PATH}"
export PATH="${HOME}/.local/bin:${PATH}"

if type mise &>/dev/null; then
  export PATH="${HOME}/.local/share/mise/shims:${PATH}"
  eval "$(mise activate zsh)"
  eval "$(mise activate --shims)"
fi

osc52() {
  local data
  data=$(base64 | tr -d '\r\n')
  if [ -n "$TMUX" ]; then
    # tmux越しでも確実に通すための DCS パススルー
    printf '\033Ptmux;\033\033]52;c;%s\a\033\\' "$data"
  else
    printf '\033]52;c;%s\a' "$data"
  fi
}

export EDITOR=nvim

alias v='nvim'
alias lg='lazygit'
alias g='git'

# -- starship : should be put on last line
eval "$(starship init zsh)"


# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

path=('/Users/chibadaimare/.juliaup/bin' $path)
path=('/Users/chibadaimare/.julia/bin' $path)
export PATH

# <<< juliaup initialize <<<
