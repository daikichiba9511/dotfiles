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

# --- fzf
# CTRL-Y to copy the command into clipboard using pbcopy
export FZF_CTRL_R_OPTS=$(cat << "EOF"
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --bind 'ctrl-e:execute(echo {+} | xargs -o eval)'
  --color header:italic
  --header 'Press C-y:copy to clipboard,C-e:execute command'
EOF
)
function fzf-history-widget-accept() {
  fzf-history-widget
  zle accept-line
}
zle     -N     fzf-history-widget-accept
bindkey '^R' fzf-history-widget-accept


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
  # dim=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}
  dim=400x400
  height=$(echo $dim | cut -d x -f 2)
  width=$(echo $dim | cut -d x -f 1)
  img2sixel --height=$height --width=$width {}
  # img2sixel -w \${FZF_PREVIEW_COLUMNS} -h \${FZF_PREVIEW_LINES} {}
  # fzf-preview.sh {}
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

#--- fuzzy image cat
#--- NOTE:fzfで見つけた画像を表示する
#--- 探す拡張子: png, jpg
#--- depends on: fzf, chafa (to preview images), fd, wezterm/img2sixel
function fic() {
    local is_in_tmux=$([ "${TMUX}" = "" ] && echo "false" || echo "true")

    local img_cat_cmd="wezterm imgcat"
    if [ "${is_in_tmux}" = "true" ] && command -v "wezterm" > /dev/null; then
      img_cat_cmd="wezterm imgcat"
    elif [ "${is_in_tmux}" = "true" ] && ! command -v "wezterm" > /dev/null; then
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

# --- Environment
local os_type=$(uname -s)
if [[ "${os_type}" == "Darwin" ]]; then
  export PATH=/"opt/homebrew/bin:${PATH}"
fi


# --- measurement utils
# Ref: https://zenn.dev/yutakatay/articles/zsh-neovim-speedcheck
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
  log INFO "\naverage: ${average_msec} [ms]"
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

  log INFO "my vimrc: ${time_rc}s\ndefault neovim: ${time_norc}s\n"
  local result
  result=$(scale=3 echo "${time_rc} / ${time_norc}" | bc)
  log INFO "${result}x slower your Neovim than the default."
}

function nvim-profiler() {
  local file=$1
  local time_file
  time_file=$(mktemp --suffix "_nvim_startuptime.txt")
  log INFO "output: $time_file"
  time nvim --headless --startuptime $time_file -c q $file
  tail -n 1 $time_file | cut -d " " -f1 | tr -d "\n" && echo " [ms]\n"
  cat $time_file | sort -n -k 2 | tail -n 20
}

#--- vim
alias v="nvim"

alias g="git"
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias lg="lazygit"

#--- vim
alias v="nvim"

#--- imgcat
if [[ ! $(command -v imgcat) ]] && [[ $(command -v img2sixel) ]]; then
  alias imgcat="img2sixel"
fi


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

