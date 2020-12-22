#!/bin/sh

num_trash=$(ls -la ~/.local/share/Trash/files | wc -l)
if [ "$num_trash"  -gt 100 ]; then
	echo "$num_trash "
else
	echo ""
fi
