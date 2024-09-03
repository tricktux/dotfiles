#!/usr/bin/env sh

wget -O /tmp/gvim.appimage https://github.com/vim/vim-appimage/releases/download/v9.0.1413/GVim-v9.0.1413.glibc2.14-x86_64.AppImage
chmod +x /tmp/gvim.appimage
/tmp/gvim.appimage

# If you want a terminal Vim (with X11 and clipboard feature enabled), just create a symbolic link with a name starting with "vim". Like:
ln -s /tmp/gvim.appimage /tmp/vim.appimage
