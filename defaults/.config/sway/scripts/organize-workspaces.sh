#!/usr/bin/env bash
# filepath: ~/.config/sway/scripts/organize-workspaces.sh

# Get outputs from sway and sort by resolution (highest first)
get_sorted_outputs() {
  swaymsg -t get_outputs | jq -r '
  .[] | 
    select(.active == true) | 
    {name: .name, width: .current_mode.width, height: .current_mode.height} |
      .name + " " + (.width * .height | tostring)
  ' | sort -k2 -nr | cut -d' ' -f1
}

# Read outputs into array
readarray -t outputs < <(get_sorted_outputs)

if [ ${#outputs[@]} -eq 0 ]; then
  echo "No active outputs found"
  exit 1
fi

# Get primary, secondary, tertiary (fallback to available monitors)
primary="${outputs[0]}"
secondary="${outputs[1]:-$primary}"
tertiary="${outputs[2]:-$secondary}"

echo "Primary: $primary, Secondary: $secondary, Tertiary: $tertiary"

# Workspace to output mapping
declare -A workspace_map=(
  [1]="$primary"
  [2]="$secondary" 
  [3]="$tertiary"
  [4]="$primary"
  [5]="$secondary"
  [6]="$primary"
  [7]="$secondary"
  [8]="$primary"
  [9]="$secondary"
)

# Apply workspace assignments
for workspace in "${!workspace_map[@]}"; do
  output="${workspace_map[$workspace]}"
  echo "Moving workspace $workspace to $output"
  swaymsg "workspace number $workspace; move workspace to output $output"
done
