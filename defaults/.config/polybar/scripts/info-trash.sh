#!/bin/bash

folder_path="$HOME"/.local/share/Trash/files
threshold=2.0 # threshold in GB

folder_size=$(du -s "$folder_path" | awk '{print $1/1024/1024}')

if [[ $folder_size > $threshold ]]; then
    printf "%.1f GB\n" "$folder_size"
else
    echo ""
fi
