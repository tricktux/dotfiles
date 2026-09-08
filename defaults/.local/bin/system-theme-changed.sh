#!/usr/bin/env bash
# Invoked by noctalia's [hooks] theme_mode_changed
# Usage: sytem-theme-changed <light|dark>
set -euo pipefail

GTK_APPLY=/usr/share/noctalia/assets/templates/gtk/apply.sh
mode="${1:?usage: sytem-theme-changed <light|dark>}"

neovim_setup() {
  local mode=$1
  local key="<c-\><c-n> tcd"
  [[ "$mode" == "dark" ]] && key="<c-\><c-n> tcn"

  for s in ${XDG_RUNTIME_DIR:-${TMPDIR}nvim.${USER}}/nvim.*.0; do
    [[ -S "$s" ]] && nvim --server "$s" --remote-send "$key"
  done
  if [[ -S /tmp/nvim_journal.socket ]]; then
    nvim --server /tmp/nvim_journal.socket --remote-send "$key"
  fi
}

# Sync GNOME/GTK color-scheme (theme templates are already applied by noctalia itself)
"$GTK_APPLY" --appearance-only "$mode"

neovim_setup "$mode"

swaymsg reload

notify-send "theme-changed" "Mode '$mode' applied" -t 3000
