git clone --branch=master --depth 1 https://github.com/ryanoasis/nerd-fonts.git
cd nerd-fonts
./install.sh $1  # "Source" to install Sauce Code Nerd Font
cd ..
rm -rf nerd-fonts
