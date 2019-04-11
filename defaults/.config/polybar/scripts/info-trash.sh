#!/bin/sh

case "$1" in
    --clean)
		termite -e ~/.config/dotfiles/scripts/arch-maintance.sh
        ;;
    *)
		num_trash=$(ls -la ~/.local/share/Trash/files | wc -l)
		if [ "$num_trash"  -gt 30 ]; then
			echo "$num_trash "
		else
			echo ""
		fi
        ;;
esac
