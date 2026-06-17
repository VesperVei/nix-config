#!/usr/bin/env bash

pane_target=${1:-${TMUX_PANE:-}}

if [ -z "$pane_target" ]; then
	tmux display-message "nested tmux passthrough: no target pane"
	exit 1
fi
current_value=$(tmux show-options -pt "$pane_target" -qv @nested_tmux_passthrough 2>/dev/null || printf off)

if [ "$current_value" = on ]; then
	tmux set-option -pt "$pane_target" @nested_tmux_passthrough off
	tmux display-message "nested tmux passthrough: off"
else
	tmux set-option -pt "$pane_target" @nested_tmux_passthrough on
	tmux display-message "nested tmux passthrough: on"
fi
