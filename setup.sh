#!/bin/bash

# I assummed that this scirpts is running under dotfiles

set -eu
echo "################### start to setup develop environment  #######################"

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
#############################################
# global変数
#############################################
SETUP_PYTHON_FLAG=false
SETUP_RUST_FLAG=false
SETUP_NERDFONT_FLAG=false

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
			echo "Invalid Optiona: ${OPTARG} see h option, please." 1>&2
			exit 2
			;;
		esac
		shift
	done
}

# ${#<配列変数>} 配列のサイズ取得
# if [[ "${#ARGS[@]}" ]]

function main() {
	bash tasks/install-pre-ubuntu.sh
	bash tasks/install-around-zsh.sh
	bash tasks/install-sheldon.sh
	bash tasks/install-nvim.sh

	if "${SETUP_PYTHON_FLAG}"; then
		bash tasks/install-python.sh
	else
		echo " -- skip to set up Python environment. -- "
	fi

	if "${SETUP_RUST_FLAG}"; then
		bash tasks/install-rust.sh
	else
		echo " -- skip to set up Rust environment"
	fi

	if "${SETUP_NERDFONT_FLAG}"; then
		bash tasks/install-nerdfonts.sh Hack
	fi

	echo " ###### Sync dotfiles to your environment ####### "
	bash tasks/link.sh

	echo "=================== ✅Finished setup of develop environment  ================="
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	parse_args "$@"
	main
fi
