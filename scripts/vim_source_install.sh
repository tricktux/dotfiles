# sudo apt install vim-gtk
sudo apt-get autoremove --purge vim vim-gtk vim-runtime vim-gnome vim-tiny vim-common vim-gui-common
# sudo apt-get build-dep vim-gtk
# If make fails then try using the above line. And if that fails then install ncurses-dev
cd ~/vim/src
sudo make uninstall
sudo rm -rf vim
git clone https://github.com/vim/vim.git --depth 1
cd vim
./configure --with-features=huge \
            --enable-multibyte \
            --enable-rubyinterp \
            --enable-largefile \
            --disable-netbeans \
            --enable-pythoninterp \
            --with-python-config-dir=/usr/lib/python2.7/config \
            --enable-python3interp \
            --with-python3-config-dir=/usr/lib/python3.5/config \
            --enable-perlinterp \
            --enable-gui=auto \
            --enable-fail-if-missing \
            --enable-luainterp \
            --with-lua
            --with-luajit
            --with-lua-prefix=/usr/include/lua5.2 \
            --enable-cscope 
            --prefix=/usr
cd src
make -j8
sudo make install
# sudo make install
#git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
