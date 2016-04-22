#sudo apt-get purge vim-gtk vim-runtime vim gvim
#sudo apt-get build-dep vim-gtk
cd
sudo rm -rf vim
git clone https://github.com/vim/vim.git
cd vim
./configure --with-features=huge \
            --enable-multibyte \
            --enable-rubyinterp \
            --enable-pythoninterp \
            --with-python-config-dir=/usr/lib/python2.7/config \
            --enable-perlinterp \
            --enable-luainterp \
			--enable-gui=gtk2 --enable-cscope --prefix=/usr
cd src
make -j8
sudo make install
#make VIMRUNTIMEDIR=/usr/share/vim/vim74
#sudo make install
#git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
