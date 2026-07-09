#!/usr/bin/env sh
set -eu

pane_commands="$(tmux list-panes -a -F '#{pane_current_command}' 2>/dev/null || true)"
gdb_count="$(printf '%s\n' "$pane_commands" | awk 'BEGIN { count = 0 } /^(gdb|gdb-multiarch|pwndbg|gef)$/ { count++ } END { print count }')"

if [ "${gdb_count:-0}" -gt 0 ]; then
  tmux set -gq @attack 1
  tmux set -gq @mode_name 'ATTACK'
  tmux set -gq @mode_bg '#f7768e'
  tmux set -gq @mode_fg '#1a1b26'
  tmux set -gq @gdb_state "GDB:${gdb_count}"
  tmux set -gq @gdb_bg '#9ece6a'
  tmux set -gq @gdb_fg '#1a1b26'
else
  tmux set -gq @attack 0
  tmux set -gq @mode_name 'PWN'
  tmux set -gq @mode_bg '#7aa2f7'
  tmux set -gq @mode_fg '#1a1b26'
  tmux set -gq @gdb_state 'GDB idle'
  tmux set -gq @gdb_bg '#414868'
  tmux set -gq @gdb_fg '#c0caf5'
fi

tmux set -gq @gdb_count "${gdb_count:-0}"
