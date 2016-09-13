# Dependencies. Uncomment if installing for the first time
# sudo apt-get install -y libtool libtool-bin autoconf automake cmake g++ pkg-config unzip 
# sudo apt-get install -y python-dev python-pip python3-dev python3-pip \
# ninja-build
# pip2 install neovim
# pip3 install neovim
# Link vimrc file:
# cd .config/nvim
# ln -s ~/vimrc/_vimrc init.vim
cd
rm -rf neovim
git clone https://github.com/neovim/neovim --depth 1
cd neovim
make -j8 CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX:PATH=$HOME/neovim"
# Sometimes this doesnt work then you could just
# cd ~/bin
# ln -s ~/neovim/bin/nvim
# export PATH="$HOME/neovim/bin:$PATH"


# Uninstallation if used sudo make install
# Otherwise just delete ~/neovim folder
# rm /usr/local/bin/nvim
# rm -r /usr/local/share/nvim/
