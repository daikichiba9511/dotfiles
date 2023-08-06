#!/bin/bash
set -eu

# References:
# https://qiita.com/rainbartown/items/d7f59fe4047733c14e8b

dotfiles_root="$(cd "$(dirname "$0")/.." && pwd)"
echo "${dotfiles_root}"

##############################################
# linklist.txtのコメントを削除
#
# Globals:
#   None
# Arguments:
#   None
##############################################
function __remove_linklist_comment() {
	(
		# '#'以降と空行を削除
		sed -e 's/\s*#.*//' \
			-e '/^\s*$/d' \
			"$1"
	)
}

# シンボリックリンクを作成
cd "${dotfiles_root}/dotfiles"

if [ "$(uname)" == "Darwin" ]; then
	linklist="linklist_macos.txt"
else
	linklist="linklist.txt"
fi

[ ! -r "$linklist" ] && return

__remove_linklist_comment "${linklist}" | while read -r target link; do
	# ~ や環境変数を展開
	target=$(eval echo "${PWD}/${target}")
	link=$(eval echo "${link}")
	# シンボリックリンクを作成
	mkdir -p "$(dirname "${link}")"
	ln -fsn "${target}" "${link}"
done
