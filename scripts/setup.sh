#!/bin/sh

# I assummed that this scirpts is running under dotfiles

set -eu

echo "=================== start to setup develop environment  ======================="

echo " This Setup scripts if for Ubuntu (because of using apt and running is checked on Ubuntu)"
if [ $1 = "y" -o $1 = "Y" ] ; then
    echo "skip check..."
    FLAG="y"
else
    read -p " Do you want to continue to develop? [y/N]" FLAG
fi 

if [ $FLAG = "y" -o $FLAG = "Y" ] ; then
        echo " Ok, continue to setup !! "
elif [ $FLAG = "n" -o $FLAG = "N" ] ; then
        echo " Oh, stop to setup here. "
        exit
else 
        echo "Sorry, your input is invalid..."
        exit
fi

sh installer/install-pre-ubuntu.sh

sh installer/install-around-zsh.sh

sh installer/install-nvim.sh

sh installer/install-nerdfonts.sh

PYTHON=${1:-SKIP}
if [ $PYTHON = "python" -o $PYTHON = "p" ] ; then
    sh installer/install-python.sh
else
    echo "skip installation of python"
fi

RUST=${3:-SKIP}
if [ $RUST = "rust" -o $RUST = "r" ] ; then
    sh installer/install-rust.sh
else
    echo "skip installation of rust"
fi

CODE=${4:-SKIP}
if [ $CODE = "code" -o $CODE = "c" ] ; then
    sh installer/install-code.sh
else
    echo "skip installation of vscode"
fi

sh scripts/link.sh

echo "=================== ✅Finished setupping develop environment  ================="
