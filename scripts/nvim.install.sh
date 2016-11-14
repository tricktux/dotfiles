# File:					nvim.install.sh
# Description:				Script file that installs nvim to
#					$HOME/neovim. If it failes check
#					Dependencies.
#					**Note** Depends on having setting proper var $install
# Author:				Reinaldo Molina <rmolin88@gmail.com>
# Version:				2.0.0
# Date:					Sat Oct 01 2016 17:24 

install='pacaur -S --noconfirm'

# Dependencies. Uncomment if installing for the first time
# $install libtool libtool-bin autoconf automake cmake g++ pkg-config unzip 
# Ubuntu specific
# $install python-dev python-pip python3-dev python3-pip
# $install python python-pip python2 python2-pip
# ninja-build
# pip2 install neovim
# pip3 install neovim

# Link vimrc file:
# mdir .config/nvim
# cd .config/nvim
# ln -s ~/vimrc/_vimrc init.vim
cd
rm -rf neovim
git clone https://github.com/neovim/neovim.git --depth 1
cd ~/neovim
make -j8 CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX:PATH=$HOME/neovim"
make install
pip2 install --upgrade neovim
pip3 install --upgrade neovim
# cd ~/bin
# ln -s ~/neovim/bin/nvim

# Installing neovim-qt. 
# GUI interface for neovim
# First thing install Qt5
# Go to their wiki website. There is bookmark in Dev folder
# Follow very well all the instructions including the one for configuring a
# compiler
# Then clone the neovim-qt github
# To the neovim-qt/CMakelist.txt add the following line
# set(CMAKE_PREFIX_PATH $ENV{HOME}/Documents/Qt5/5.7/gcc_64/lib/cmake/)
# Where after home is the path to where all the required Qt5Widget, Network crap
# is
# Then again:
# cd ~/bin
# ln -s ~/<path to complied neovim-qt>/bin/nvim-qt

# Uninstallation if used sudo make install
# Otherwise just delete ~/neovim folder
# rm /usr/local/bin/nvim
# rm -r /usr/local/share/nvim/
