#!/bin/bash

folder_path="$HOME"/.local/share/Trash/files
threshold=2.0 # threshold in GB

folder_size=$(du -s "$folder_path" | awk '{printf("%.1f", $1/1024/1024)}')

if [[ $folder_size > $threshold ]]; then
    echo "$folder_size GB"
else
    echo ""
fi
