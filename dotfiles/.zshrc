function log() {
  local level="${1}"
  shift
  local color
  local reset="\033[0m"
  case "${level}" in
  INFO)
    color="\033[0;32m" # Green
    ;;
  WARN)
    color="\033[0;33m" # Yellow
    ;;
  ERROR)
    color="\033[0;31m" # Red
    ;;
  DEBUG)
    color="\033[0;36m" # Cyan
    ;;
  *)
    color="\033[0;37m" # White
    ;;
  esac

  echo -e "[${color}${level}${reset}] : [$(date '+%Y-%m-%d %H:%M:%S')] : $*"
}

export CLICOLOR=1
echo Hello ${USER}

# -- 環境変数
export LANG=ja_JP.UTF-8
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export PATH="${PATH}:./node_modules/.bin"
export XDG_STATE_HOME="${HOME}/.local/state"
export PATH="${PATH}:${HOME}/.local/bin:/usr/local/bin"
export GPG_TTY="${TTY}"

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

# -- sheldon : zsh plugin manager
eval "$(sheldon source)"

# -- git
alias g="git"
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias lg="lazygit"

#--- vim
alias v="nvim"

#--- imgcat
if [[ ! $(command -v imgcat) ]] && [[ $(command -v img2sixel) ]]; then
  alias imgcat="img2sixel"
fi

#--- measurement utils
# Ref: https://zenn.dev/yutakatay/articles/zsh-neovim-speedcheck
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
#   log INFO "\naverage: ${average_msec} [ms]"
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
#   log INFO "my vimrc: ${time_rc}s\ndefault neovim: ${time_norc}s\n"
#   local result
#   result=$(scale=3 echo "${time_rc} / ${time_norc}" | bc)
#   log INFO "${result}x slower your Neovim than the default."
# }
#
# function nvim-profiler() {
#   local file=$1
#   local time_file
#   time_file=$(mktemp --suffix "_nvim_startuptime.txt")
#   log INFO "output: $time_file"
#   time nvim --headless --startuptime $time_file -c q $file
#   tail -n 1 $time_file | cut -d " " -f1 | tr -d "\n" && echo " [ms]\n"
#   cat $time_file | sort -n -k 2 | tail -n 20
# }

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
# -- 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# -- 補完候補を詰めて表示
setopt list_packed
# --コマンドのスペルを訂正
setopt correct

# -- Git
autoload -Uz compinit && compinit -i # Gitの補完を有効化
export fpath=(~/.zsh/completion $fpath)
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

# ------------------------------------ FUNCTIONS -------------------------------------
#---tmuxの使用時にtile状にpaneをsplitする
function tide() {
    tmux split-window -v
    tmux split-window -h
    tmux split-window -h
    tmux resize-pane -D 15
    tmux select-pane -t 1
}
#---weztermを使用してpaneをsplitする
function wide() {
    local pane_size=${1:-70}
    wezterm cli split-pane --right --percent "${pane_size}"
    wezterm cli split-pane --bottom
}
#--- bat
export BAT_THEME="Monokai Extended Bright"
#--- fzf
export PATH="${PATH}:${HOME}/.fzf_bin/bin"  # for fzf installed via ~/.fzf_bin/install
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# fzfをtmuxで使う
export FZF_TMUX=1
export FZF_TMUX_OPTS="-p 80%"

export FZF_DEFAULT_OPTS=$(cat << "EOF"
--bind "ctrl-y:execute-silent(echo {+} | pbcopy)"
--bind "ctrl-v:execute(echo {+} | xargs -o nvim)"
--bind "ctrl-t:toggle-preview"
--preview "
if file --mime-type {} | grep -qF image/; then
  img2sixel {}
  # img2sixel -w \${FZF_PREVIEW_COLUMNS} -h \${FZF_PREVIEW_LINES} {}
  # fzf-preview.sh {}
  # chafa -f iterm -s \${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES} {}
  echo
else
  bat --style=numbers --color=always --line-range :500 {}
fi
"
--preview-window=down,border-top
--reverse
--border=rounded
EOF
)

# --preview-window=right:60%
#
# CTRL-Y to copy the command into clipboard using pbcopy
export FZF_CTRL_R_OPTS=$(cat << "EOF"
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --bind 'ctrl-e:execute(echo {+} | xargs -o eval)'
  --color header:italic
  --header 'Press C-y:copy to clipboard,C-e:execute command'
EOF
)

# -- fuzzy hisotry command
# function fhc() {
#   cmd=$(history -5000 | tac |  fzf | sed 's/ *[0-9]* *//')
#   if [ $? = 0 ]; then
#     echo "executing: ${cmd}"
#     eval "${cmd}"
#   else 
#     echo "no command is selected."
#   fi
# }
#
# function fzf-hisotry-search() {
#   fhc
#   zle redisplay
# }
#
# # <C-R> で fzfを使った逆検索を実行
# zle -N fzf-hisotry-search
# bindkey '^R' fzf-hisotry-search
# Preview file content using bat (https://github.com/sharkdp/bat)

function fzf-history-widget-accept() {
  fzf-history-widget
  zle accept-line
}
zle     -N     fzf-history-widget-accept
bindkey '^R' fzf-history-widget-accept


#--- logをつける用のマークダウンを生成する
# function cdlog() {
#     # create daily log file
#     local today=$(date +%Y-%m-%d)
#     local log_file_name="${today}.md"
#     touch ${log_file_name}
#     echo "#${today}" >> ${log_file_name}
#     cat ~/dotfiles/dotfiles/base_logs.md >> ${log_file_name}
#     echo "✅ ${log_file_name} is created."
# }

#--- fuzzy search files and open with vscode
#--- NOTE: fzfで見つけたファイルをvscodeで開く
#
# function fv {
#     local filename=$(fzf --preview 'bat --color=always {}')
#     if [ $filename != "" ]; then
#         code "${filename}"
#     fi 
# }

#--- fuzzy image cat
#--- NOTE:fzfで見つけた画像を表示する
#--- 探す拡張子: png, jpg
#--- depends on: fzf, chafa (to preview images), fd, wezterm/img2sixel
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
    # fzf --preview 'chafa -f sixel -s ${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES} {}'
    local filename=$(
      echo "${filenames[@]}" | fzf
    )
    if [[ "${filename}" = "" ]]; then
      echo "No file is selected."
      return 0
    fi

    if [ $? = 0 ]; then
        echo "-- ${img_cat_cmd} ${filename} --"
        # "${SHELL}" -c "${img_cat_cmd} '${filename}'"
        eval "${img_cat_cmd} '${filename}'"
    fi
}
#--- Haskell
[ -f "/home/d-chiba/.ghcup/env" ] && source "/home/d-chiba/.ghcup/env" # ghcup-env
#--- Cuda
export CUDA_PATH=/usr/local/cuda-12
export LD_LIBRARY_PATH=/usr/local/cuda-11.8/lib64:${LD_LIBRARY_PATH}
export PATH=/usr/local/cuda-11.8/bin:${PATH}
#--- nnn
export NNN_PLUG='f:finder;o:fzopen;p:mocq;d:diffs;t:nmount;v:imgview;p:preview-tui'
# -- starship : should be put on last line
eval "$(starship init zsh)"
