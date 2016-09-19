# sudo apt install vim-gtk
# sudo apt-get autoremove --purge vim vim-gtk vim-runtime vim-gnome vim-tiny vim-common vim-gui-common
# sudo apt-get build-dep vim-gtk
# sudo apt-get -y install liblua5.2-dev luajit libluajit-5.1 python-dev
# If make fails then try using the above line. And if that fails then install ncurses-dev
# Installing LUA is very tricky. Play around with copying files from lua5.2 into
# lua5.2/include. Also uncomment theh lua prefix. Comment everything except for
# code inside PORTION to play around with ./configure. Not until you get it
# right. Very fast way. Once you do uncomment rest of code.
cd ~/vim/src &&
sudo make uninstall
cd
sudo rm -rf vim
git clone https://github.com/vim/vim.git --depth 1
# USE JUST THIS PORTION WHEN CONFIGURE FAILS
cd ~/vim/src
make distclean
./configure --with-features=huge \
            --enable-multibyte \
            --enable-rubyinterp \
            --enable-largefile \
            --disable-netbeans \
            --enable-pythoninterp \
            --enable-python3interp \
            --enable-perlinterp \
            --enable-gui=auto \
            --enable-fail-if-missing \
            --enable-luainterp \
            --enable-cscope

            # --with-python3-config-dir=/usr/lib/python3.5/config \
            # --with-python-config-dir=/usr/lib/python2.7/config \
            # --with-lua-prefix=/usr/include/lua5.2 \
# USE JUST THIS PORTION WHEN CONFIGURE FAILS
cd ~/vim/src &&
make -j8 &&
sudo make install
# Use this below for force uninstall
# To get vim real location you can use `which vim`
# sudo rm -rf /usr/local/share/vim/vim61
# sudo rm /usr/local/bin/eview
# sudo rm /usr/local/bin/evim
# sudo rm /usr/local/bin/ex
# sudo rm /usr/local/bin/gview
# sudo rm /usr/local/bin/gvim
# sudo rm /usr/local/bin/gvim
# sudo rm /usr/local/bin/gvimdiff
# sudo rm /usr/local/bin/rgview
# sudo rm /usr/local/bin/rgvim
# sudo rm /usr/local/bin/rview
# sudo rm /usr/local/bin/rvim
# sudo rm /usr/local/bin/rvim
# sudo rm /usr/local/bin/view
# sudo rm /usr/local/bin/vim
# sudo rm /usr/local/bin/vimdiff
# sudo rm /usr/local/bin/vimtutor
# sudo rm /usr/local/bin/xxd
# sudo rm /usr/local/man/man1/eview.1
# sudo rm /usr/local/man/man1/evim.1
# sudo rm /usr/local/man/man1/ex.1
# sudo rm /usr/local/man/man1/gview.1
# sudo rm /usr/local/man/man1/gvim.1
# sudo rm /usr/local/man/man1/gvimdiff.1
# sudo rm /usr/local/man/man1/rgview.1
# sudo rm /usr/local/man/man1/rgvim.1
# sudo rm /usr/local/man/man1/rview.1
# sudo rm /usr/local/man/man1/rvim.1
# sudo rm /usr/local/man/man1/view.1
# sudo rm /usr/local/man/man1/vim.1
# sudo rm /usr/local/man/man1/vimdiff.1
# sudo rm /usr/local/man/man1/vimtutor.1
# sudo rm /usr/local/man/man1/xxd.1
# 
# Make vim default
sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1
sudo update-alternatives --set editor /usr/local/bin/vim
sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1
sudo update-alternatives --set vi /usr/local/bin/vim
