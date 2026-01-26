#!/bin/bash

DIR="/mnt/skywafer/music/drum.bass/Purified Radioshow Episodes/"
cd "$DIR" || exit 1

# Function to process a file
process_file() {
    file="$1"
    temp_file="${file%.*}_temp.${file##*.}"
    echo "Processing: $file"
    
    if ffmpeg -i "$file" -y -ss 30 -threads 0 -codec:a libmp3lame -b:a 320k -map_metadata 0 "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$file"
        echo "✓ Successfully processed: $file"
    else
        rm -f "$temp_file"
        echo "✗ Failed to process: $file"
    fi
}

# Process files with job control (max 8 concurrent)
for file in *.mp3 *.m4a *.flac *.wav *.aac *.ogg; do
    [[ -f "$file" ]] || continue
    
    # Wait if we have 8 background jobs
    while (( $(jobs -r | wc -l) >= 8 )); do
        sleep 0.1
    done
    
    # Start processing in background
    process_file "$file" &
done

# Wait for all background jobs to finish
wait
echo "Done processing all files!"
