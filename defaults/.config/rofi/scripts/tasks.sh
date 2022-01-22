#!/bin/bash

conf="$HOME/.config/rofi/scripts/confirm.sh"
config_file="$HOME/.config/rofi/scripts/tasks.json"
tasks=$(cat "$config_file")

if [[ $# -gt 0 ]]; then
  if [[ $ROFI_RETV -ne 1 ]]; then
    exit 2
  fi

  task=$(echo "$tasks" | jq ".[] | select(.name == \"$1\")")

  # Exit if no task was found
  if [[ $task == "" ]]; then
    echo "No task defined as '$1' within config file."
    exit 1
  fi

  task_command=$(echo "$task" | jq ".command")
  confirm=$(echo $task | jq ".confirm")

  # Check whether we need confirmation to run this task
  if [[ $confirm == "true" ]]; then
    # Chain the confirm command before executing the selected command
    confirm_script="$conf 'Confirm $selected?'"
    # coproc is the key so that rofi does not wait for the command output
    coproc ( eval "$confirm_script && \"$task_command\" >>/tmp/task.log 2>&1" )
  else
    # coproc is the key so that rofi does not wait for the command output
    coproc ( eval "\"$task_command\" >>/tmp/task.log 2>&1" )
  fi
else
  if [[ $ROFI_RETV -ne 0 ]]; then
    exit 3
  fi
  echo "$tasks" | jq -j 'map(.name) | join("\n")'
fi
