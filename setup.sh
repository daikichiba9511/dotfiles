#!/usr/bin/env bash
set -eu -o pipefail -o posix

#############################################
# global変数
#############################################
SETUP_PYTHON_FLAG=false
SETUP_RUST_FLAG=false
SETUP_NERDFONT_FLAG=false
OS_TYPE='Linux'

##############################################
# logging function
# Globals:
#   None
# Arguments:
#   None
##############################################
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

##############################################
# logging function
# Globals:
#   OS_TYPE
# Arguments:
#   None
##############################################
function set_os_type() {
  case "$(uname -s)" in
  Linux*) OS_TYPE=Linux ;;
  Darwin*) OS_TYPE=Mac ;;
  *) OS_TYPE="UNKNOWN" ;;
  esac
  log INFO "Detected OS_TYPE => ${OS_TYPE}"
}

##############################################
# Install コマンド用
# Globals:
#   None
# Arguments:
#   None
##############################################
function install_package() {
  if ! dpkg -l | grep -q "^ii $1"; then
    sudo apt-get install -y "$1"
    log INFO "You are enable to install $1 . ✅"
  else
    log INFO "You already install $1. ⭕️"
  fi
}

##############################################
# helpコマンド用
# Globals:
#   None
# Arguments:
#   None
##############################################
function help() {
  cat <<EOS >&2
usage: $0 [-p] [-r] [-n]
        -h flag to show help
        -p flag to setup python environment (tasks/install-python.sh)
        -r flag to setup rust environment (tasks/install-rust.sh)
        -n flag to install nerdfont to your environment (tasks/install-nerdfonts.sh)
EOS
  exit 1
}

##############################################
# 引数の解析
# Globals:
#   SETUP_PYTHON_FLAG
#   SETUP_RUST_FLAG
#   SETUP_NERDFONT_FLAG
#
# Arguments:
#   None
#
# Referece
# 1. https://zenn.dev/kawarimidoll/articles/d546892a6d36eb
# 2. https://zenn.dev/ryo_kawamata/articles/watch-files-in-bash
# 3. https://www.man7.org/linux/man-pages/man1/getopt.1.html
##############################################
function parse_args() {
  while getopts ":hprn" opt; do
    case ${opt} in
    p)
      SETUP_PYTHON_FLAG=true
      ;;
    r)
      SETUP_RUST_FLAG=true
      ;;
    n)
      SETUP_NERDFONT_FLAG=true
      ;;
    h)
      help
      ;;
    *)
      log INFO "Invalid Option: ${OPTARG} see h option, please." 1>&2
      exit 2
      ;;
    esac
    shift
  done
}

function install_ripgrep() {
  # -- Install `ripgrep`
  # new grep alternative
  # for telescope in neovim
  # Reference
  # [1] https://github.com/BurntSushi/ripgrep
  log INFO "Install 'ripgrep' ✅"
  if [[ "${OS_TYPE}" = 'Linux' ]]; then
    local ripgrep_ver='14.1.0'
    wget "https://github.com/BurntSushi/ripgrep/releases/download/${ripgrep_ver}/ripgrep_${ripgrep_ver}-1_amd64.deb" -P /tmp
    sudo dpkg -i "/tmp/ripgrep_${ripgrep_ver}-1_amd64.deb"
    sudo rm "/tmp/ripgrep_${ripgrep_ver}-1_amd64.deb"
  elif [[ "${OS_TYPE}" = 'Mac' ]]; then
    arch -arm64 brew install ripgrep
  fi
}

function install_lsd() {
  # -- Install `lsd`
  # new gen ls command
  # Reference
  # [1] https://github.com/lsd-rs/lsd
  log INFO "Install 'lsd' ✅"
  if [[ "${OS_TYPE}" = 'Linux' ]]; then
    local lsd_ver='1.1.2'
    wget "https://github.com/lsd-rs/lsd/releases/download/v${lsd_ver}/lsd-musl_${lsd_ver}_amd64.deb" -P /tmp
    sudo dpkg -i "/tmp/lsd-musl_${lsd_ver}_amd64.deb"
    sudo rm "/tmp/lsd-musl_${lsd_ver}_amd64.deb"
  elif [[ "${OS_TYPE}" = 'Mac' ]]; then
    arch -arm64 brew install lsd
  fi
}

function install_bat() {
  # -- Install `bat`
  # new cat alternative
  # Reference
  # [1] https://github.com/sharkdp/bat
  log INFO "Install 'bat' ✅"
  if [[ "${OS_TYPE}" = 'Linux' ]]; then
    install_package bat
    # /usr/bin/batcatでインストールされるので ~/.local/bin/batにリンク貼る
    [ -f ~/.local/bin/bat ] && rm -f ~/.local/bin/bat
    [ -f /usr/bin/batcat ] && sudo rm -f /usr/bin/bat
    ln -s /usr/bin/batcat ~/.local/bin/bat
  elif [[ "${OS_TYPE}" = 'Mac' ]]; then
    arch -arm64 brew install bat
  fi
}

function install_delta() {
  # -- Install `delta`
  # new diff alternative
  # Reference
  # [1] https://github.com/dandavison/delta
  log INFO "Install 'delta' ✅"
  if [[ "${OS_TYPE}" = 'Linux' ]]; then
    [ -f /usr/local/bin/delta ] && sudo rm -f /usr/local/bin/delta

    local delta_ver='0.16.5'
    wget "https://github.com/dandavison/delta/releases/download/${delta_ver}/delta-${delta_ver}-x86_64-unknown-linux-musl.tar.gz" -P /tmp
    tar xvf "/tmp/delta-${delta_ver}-x86_64-unknown-linux-musl.tar.gz" -C "${HOME}/.local/bin"
    sudo ln -s "${HOME}/.local/bin/delta-${delta_ver}-x86_64-unknown-linux-musl/delta" /usr/local/bin/delta
    sudo rm "/tmp/delta-${delta_ver}-x86_64-unknown-linux-musl.tar.gz"
  elif [[ "${OS_TYPE}" = 'Mac' ]]; then
    arch -arm64 brew install git-delta
  fi
}

function install_fzf() {
  log INFO "Install 'fzf' ✅"
  [ -d "${HOME}/.fzf" ] && rm -rf "${HOME}/.fzf"
  git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf"
  "${HOME}/.fzf/install" --all
}

function install_starship() {
  log INFO "Install 'starship' ✅"
  # zsh promptのカスタマイズにはstarshipを使う
  # Reference
  # [1] https://github.com/starship/starship
  # [2] dotfiles/starship.toml
  sudo curl -sS https://starship.rs/install.sh | sudo bash --posix -s -- -y
}

function install_sheldon() {
  log INFO "Install 'sheldon' ✅"
  # zshのpluginの管理にはshelldonを使う
  if [[ "${OS_TYPE}" = 'Linux' ]]; then
    [ -f "${HOME}/.local/bin/sheldon" ] && rm -f "${HOME}/.local/bin/sheldon"
    curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh | bash -s -- -f --repo rossmacarthur/sheldon --to ~/.local/bin
  elif [[ "${OS_TYPE}" = 'Mac' ]]; then
    arch -arm64 brew install sheldon
  fi
}

function install_lazygit() {
  log INFO 'Install lazygit ✅'
  if [[ "${OS_TYPE}" = 'Linux' ]]; then
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    sudo rm lazygit.tar.gz lazygit
  elif [[ "${OS_TYPE}" = 'Mac' ]]; then
    arch -arm64 brew install lazygit
  fi
}

function install_neovim() {
  log INFO 'Install neovim ✅'
  if [[ "${OS_TYPE}" = 'Linux' ]]; then

    wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz -P /tmp
    tar xzvf /tmp/nvim-linux64.tar.gz -C ~/.local/bin/
    sudo rm /tmp/nvim-linux64.tar.gz
    [ -e /usr/local/bin/nvim ] && sudo rm /usr/local/bin/nvim
    sudo ln -s ~/.local/bin/nvim-linux64/bin/nvim /usr/local/bin/nvim

  elif [[ "${OS_TYPE}" = 'Mac' ]]; then

    arch -arm64 brew unlink neovim
    arch -arm64 brew install --HEAD neovim

  fi
}

function install_nodejs() {
  log INFO 'Install nodejs@22 ✅'
  if [[ "${OS_TYPE}" = 'Linux' ]]; then
    export NVM_DIR="${HOME}/.nvm"
    [ -d "${NVM_DIR}" ] && rm -rf "${NVM_DIR}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    source "${HOME}/.zshrc"
    # nvm install 22

  elif [[ "${OS_TYPE}" = 'Mac' ]]; then
    if [[ -x "$(commnd -v node) " ]]; then
      brew uninstall node@22
    fi
    brew install node@22
  fi
}

function install_github_cli() {
  log INFO 'Install github-cli ✅'
  if [[ ${OS_TYPE} = 'Linux' ]]; then
    (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) &&
      sudo mkdir -p -m 755 /etc/apt/keyrings &&
      wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null &&
      sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
      sudo apt update &&
      sudo apt install gh -y
  elif [[ ${OS_TYPE} = 'Mac' ]]; then
    arch -arm64 brew install gh
  fi
}

function install_fdfind() {
  log INFO 'Install fd-find ✅'
  if [[ ${OS_TYPE} = 'Linux' ]]; then
    sudo apt install fd-find
    [ -f ~/.local/bin/fd ] && rm -f ~/.local/bin/fd
    ln -s "$(which fdfind)" ~/.local/bin/fd
  elif [[ ${OS_TYPE} = 'Mac' ]]; then
    arch -arm64 brew install fd
  fi
}

# ${#<配列変数>} 配列のサイズ取得
# if [[ "${#ARGS[@]}" ]]

function main() {
  log INFO "################### start to setup develop environment  #######################"

  log INFO '###### Sync dotfiles to your environment #######'
  bash tasks/link.sh

  log INFO "################### start to install prerequire tools  #######################"
  if [ "${OS_TYPE}" = 'Linux' ]; then
    install_package sudo
    sudo apt-get update && sudo apt-get upgrade
    install_package zsh
    install_package gcc
    install_package g++
    install_package make
    install_package cmake
    install_package git
    install_package vim
    install_package tmux
    install_package bat
    install_package curl
    install_package wget
    install_package unzip

    install_package sqlite3
    install_package libsqlite3-dev

    install_package powerline
    install_package fonts-powerline
    install_package python3-venv # for ruff

  elif [[ "${OS_TYPE}" = 'Mac' ]]; then
    arch -arm64 brew install \
      gcc \
      make \
      cmake \
      git \
      vim \
      tmux \
      curl \
      wget \
      sqlite3
  fi

  # Ubuntu & Mac(M3)
  mkdir -p "${HOME}/.local/bin"
  install_ripgrep
  install_lsd
  install_fdfind
  install_bat
  install_delta
  install_fzf
  install_sheldon
  install_starship
  install_lazygit
  install_neovim
  install_github_cli
  install_nodejs

  # デフォルトのshellをzshにする
  if [ "${OS_TYPE}" = 'Linux' ]; then
    sudo chsh "${USER}" -s "$(which zsh)"
  fi

  log INFO '=================== ✅Finished setup of develop environment  ================='
}

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
  set_os_type
  if [ "${OS_TYPE}" = 'UNKNOWN' ]; then
    log ERROR "Not supported: OS_TYPE=UNKNOWN "
    exit 1
  fi
  main
fi
