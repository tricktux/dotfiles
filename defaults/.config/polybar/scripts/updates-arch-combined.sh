#!/usr/bin/env bash

if ! updates_arch=$(checkupdates 2> /dev/null | wc -l ); then
    updates_arch=0
fi

# if ! updates_aur=$(yay -Qum 2> /dev/null | wc -l); then
# if ! updates_aur=$(cower -u 2> /dev/null | wc -l); then
# if ! updates_aur=$(trizen -Su --aur --quiet | wc -l); then
if ! updates_aur=$(paru -Qum 2> /dev/null | wc -l); then
    updates_aur=0
fi

updates=$(("$updates_arch" + "$updates_aur"))

# Show me only when there are at least 30 packages to upgrade
if [ "$updates" -gt 60 ]; then
    echo "$updates "
else
    echo ""
fi
