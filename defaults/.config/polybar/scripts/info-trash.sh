#!/bin/sh

case "$1" in
    --clean)
		gio trash --empty
        ;;
    *)
		num_trash=$(gio list -h | wc -l)
		if [ "$num_trash"  -gt 50 ]; then
			echo "$num_trash "
		else
			echo ""
		fi
        ;;
esac
