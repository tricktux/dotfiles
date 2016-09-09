# sudo apt install vim-gtk
# sudo apt-get autoremove --purge vim vim-gtk vim-runtime vim-gnome vim-tiny vim-common vim-gui-common
# sudo apt-get build-dep vim-gtk
# sudo apt-get -y install liblua5.2-dev luajit libluajit-5.1 python-dev
# If make fails then try using the above line. And if that fails then install ncurses-dev
# cd ~/vim/src &&
# sudo make uninstall
# cd
# sudo rm -rf vim
# git clone https://github.com/vim/vim.git --depth 1
# cd ~/vim
# ./configure --with-features=huge \
            # --enable-multibyte \
            # --enable-rubyinterp \
            # --enable-largefile \
            # --disable-netbeans \
            # --enable-pythoninterp \
            # --with-python-config-dir=/usr/lib/python2.7/config \
            # --enable-python3interp \
            # --with-python3-config-dir=/usr/lib/python3.5/config \
            # --enable-perlinterp \
            # --enable-gui=auto \
            # --enable-fail-if-missing \
            # --enable-luainterp \
            # --with-lua \
            # --with-luajit \
            # --with-lua-prefix=/usr/include/lua5.2 \
            # --enable-cscope  \
            # --prefix=/usr
# cd ~/vim/src &&
# make -j8 &&
# sudo make install
# Use this below for force uninstall
# To get vim real location you can use `which vim`
sudo rm -rf /usr/local/share/vim/vim61
sudo rm /usr/local/bin/eview
sudo rm /usr/local/bin/evim
sudo rm /usr/local/bin/ex
sudo rm /usr/local/bin/gview
sudo rm /usr/local/bin/gvim
sudo rm /usr/local/bin/gvim
sudo rm /usr/local/bin/gvimdiff
sudo rm /usr/local/bin/rgview
sudo rm /usr/local/bin/rgvim
sudo rm /usr/local/bin/rview
sudo rm /usr/local/bin/rvim
sudo rm /usr/local/bin/rvim
sudo rm /usr/local/bin/view
sudo rm /usr/local/bin/vim
sudo rm /usr/local/bin/vimdiff
sudo rm /usr/local/bin/vimtutor
sudo rm /usr/local/bin/xxd
sudo rm /usr/local/man/man1/eview.1
sudo rm /usr/local/man/man1/evim.1
sudo rm /usr/local/man/man1/ex.1
sudo rm /usr/local/man/man1/gview.1
sudo rm /usr/local/man/man1/gvim.1
sudo rm /usr/local/man/man1/gvimdiff.1
sudo rm /usr/local/man/man1/rgview.1
sudo rm /usr/local/man/man1/rgvim.1
sudo rm /usr/local/man/man1/rview.1
sudo rm /usr/local/man/man1/rvim.1
sudo rm /usr/local/man/man1/view.1
sudo rm /usr/local/man/man1/vim.1
sudo rm /usr/local/man/man1/vimdiff.1
sudo rm /usr/local/man/man1/vimtutor.1
sudo rm /usr/local/man/man1/xxd.1
