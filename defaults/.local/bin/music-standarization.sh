#!/bin/bash

# Music standardization script
MUSIC_DIR="$1"
OUTPUT_DIR="${2:-${MUSIC_DIR}_standardized}"
TARGET_FORMAT="mp3"
BITRATE="320k"
LOG_FILE="${OUTPUT_DIR}_conversion.log"
MAX_JOBS=$(nproc)

# Validate input directory
if [ ! -d "$MUSIC_DIR" ]; then
  echo "Error: Directory '$MUSIC_DIR' does not exist"
  exit 1
fi

# Resolve absolute paths to avoid issues
MUSIC_DIR=$(realpath "$MUSIC_DIR")
OUTPUT_DIR=$(realpath -m "$OUTPUT_DIR")

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "Converting files from: $MUSIC_DIR"
echo "Output directory: $OUTPUT_DIR"
echo "---"
echo "Using $MAX_JOBS CPU cores for parallel processing"
echo "> Log file: $LOG_FILE"
echo "" >"$LOG_FILE" # Clear/create log file

process_files_parallel() {
  local -n files_array=$1
  local file_type="$2"
  local total=${#files_array[@]}
  local completed=0
  local running=0

  if [ $total -eq 0 ]; then
    echo "No $file_type files found."
    return
  fi

  echo "Processing $total $file_type files using $MAX_JOBS parallel jobs..."

  for file in "${files_array[@]}"; do
    # Wait if we've hit max jobs
    while [ $running -ge $MAX_JOBS ]; do
      wait -n # Wait for any background job to finish
      ((running--))
      ((completed++))
      echo "Progress: $completed/$total $file_type files completed"
    done

    # Start conversion in background
    {
      convert_file "$file" "$MUSIC_DIR" "$OUTPUT_DIR"
    } &
    ((running++))
  done

  # Wait for remaining jobs
  wait
  echo "All $total $file_type files completed!"
  echo ""
}

# Function to convert a single file
convert_file() {
  local file="$1"
  local source_dir="$2"
  local dest_dir="$3"

  local filename=$(basename "$file")
  local name="${filename%.*}"

  # Get relative directory path
  local file_dir=$(dirname "$file")
  local rel_dir=""

  # Calculate relative path from source directory
  if [ "$file_dir" != "$source_dir" ]; then
    rel_dir="${file_dir#$source_dir/}"
  fi

  # Create output subdirectory
  local output_subdir
  if [ -n "$rel_dir" ]; then
    output_subdir="$dest_dir/$rel_dir"
  else
    output_subdir="$dest_dir"
  fi
  mkdir -p "$output_subdir"

  local output_file="$output_subdir/$name.$TARGET_FORMAT"

  echo "Converting: $filename"

  # Log detailed info to file
  {
    echo "=== Converting: $filename ==="
    echo "Input: $file"
    echo "Output: $output_file"
    echo "Command: ffmpeg -i \"$file\" -threads 0 -af loudnorm -codec:a libmp3lame -b:a $BITRATE -map_metadata 0 -id3v2_version 3 -write_id3v1 1 \"$output_file\" -y"
    echo ""
  } >>"$LOG_FILE"

  # Convert with threading and output redirected to log
  if ffmpeg -i "$file" \
    -threads 0 \
    -af loudnorm=I=-10:TP=-1.5 \
    -codec:a libmp3lame \
    -b:a "$BITRATE" \
    -map_metadata 0 \
    -id3v2_version 3 \
    -write_id3v1 1 \
    "$output_file" \
    -y >>"$LOG_FILE" 2>&1; then
    echo "✓ Converted successfully"
  else
    echo "✗ Failed to convert (check $LOG_FILE for details)"
  fi
  echo ""
}

mapfile -t audio_files < <(find "$MUSIC_DIR" -type f \( -iname "*.flac" -o -iname "*.wav" -o -iname "*.m4a" -o -iname "*.ogg" -o -iname "*.wma" -o -iname "*.aac" \))

# Create array of MP3 files
mapfile -t mp3_files < <(find "$MUSIC_DIR" -type f -iname "*.mp3")

# Process all files in parallel
process_files_parallel audio_files "non-MP3 audio"
process_files_parallel mp3_files "MP3"

echo "---"
echo "Conversion complete! Standardized files saved to: $OUTPUT_DIR"
