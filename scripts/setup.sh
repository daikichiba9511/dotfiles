#!/bin/sh

# I assummed that this scirpts is running under dotfiles

set -eu

echo "=================== start to setup develop environment  ======================="

echo " This Setup scripts if for Ubuntu (because of using apt and running is checked on Ubuntu)"
read -p " Do you want to continue to develop? [y/N]" FLAG
if [ $FLAG = "y"-o $FLAG = "Y" ] ; then
        echo " Ok, continue to setup !! "
elif [ $FLAG = "n" -o $FLAG = "N" ] ; then
        echo " Oh, stop to setup here. "
        exit
else 
        echo "Sorry, your input is invalid..."
        exit

sh installer/install-pre-ubuntu.sh

sh installer/install-around-zsh.sh

sh installer/install-nvim.sh

sh installer/install-nerdfonts.sh

sh installer/install-python.sh

sh installer/install-rust.sh

sh installer/install-code.sh

echo "=================== ✅Finished setupping develop environment  ================="
