#!/usr/bin

# Example modify this
# TODO finish this
if ask "Install symlink for .config/nvim?" Y; then
  ln -sfn ${dir}/.config/nvim ${HOME}/.config/nvim
fi
