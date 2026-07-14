#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: desktop-mode <node>\n' >&2
}

is_running() {
  local app_name="$1"
  [[ "$(osascript -e "application \"${app_name}\" is running")" == "true" ]]
}

open_if_not_running() {
  local app_name="$1"

  if is_running "$app_name"; then
    return 0
  fi

  open -a "$app_name"
}

node_mode() {
  open_if_not_running "Obsidian"
  open_if_not_running "NetEaseMusic"
}

main() {
  local mode="${1:-}"

  case "$mode" in
    node)
      node_mode
      ;;
    *)
      usage
      return 2
      ;;
  esac
}

main "$@"
