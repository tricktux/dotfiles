#!/bin/sh

sudo pacman -S --needed base-devel cower
mkdir -p ~/.cache/pacaur && cd "$_"
cower -d pacaur
cd pacaur
makepkg -si --noconfirm --needed
