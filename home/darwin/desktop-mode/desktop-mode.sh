#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: desktop-mode <node>\n' >&2
}

is_running() {
  local bundle_id="$1"
  [[ "$(osascript -e "application id \"${bundle_id}\" is running")" == "true" ]]
}

open_if_not_running() {
  local bundle_id="$1"

  if is_running "$bundle_id"; then
    return 0
  fi

  open -b "$bundle_id"
}

node_mode() {
  open_if_not_running "md.obsidian"
  open_if_not_running "com.netease.163music"
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
