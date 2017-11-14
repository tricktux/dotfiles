## Configuration files for:
- (Neo)Vim
- i3
- tmux
- polybar
- i3bar
- pacaur
- make
- vnc
- cmder
- wbar
- ideavim
- mutt
- bash
- openbox
- rofi
- lxpanel

## Installation
- Use `stow`
- I.e: cd to the dotfiles repository, and from the root of the repo do:
- `$stow -t <target location> -S <directory>`
- I.e: `$stow -t /home/reinaldo/.config -S mutt`
- Directories must be in the format `mutt/mutt/<files>`
- Otherwise the folder `/home/reinaldo/.config/mutt` has to be created manually and the
`<target>` updated to this location.
- Full installation example:
- `stow -t /home/reinaldo -S defaults` 
- Then adjust the `.Xresources` in order to properly reflect Dots Per Inch (dpi) of the
system. 
- `stow -t /home/reinaldo -S defaults_<system>`
- Other is generic. If any of these options need to be changed is better to create a
whole `defaults_<X>` system and update there.
