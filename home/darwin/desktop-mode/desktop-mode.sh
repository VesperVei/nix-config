#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: desktop-mode <node|pwn>\n' >&2
}

is_running() {
  local bundle_id="$1"
  [[ "$(osascript -e "application id \"${bundle_id}\" is running")" == "true" ]]
}

is_installed() {
  local bundle_id="$1"

  osascript -e "path to application id \"${bundle_id}\"" >/dev/null 2>&1
}

ensure_installed() {
  local app_name="$1"
  local bundle_id="$2"

  if is_installed "$bundle_id"; then
    return 0
  fi

  printf 'Missing required software: %s\n' "$app_name" >&2
  return 1
}

ensure_apps_installed() {
  while [[ "$#" -gt 0 ]]; do
    ensure_installed "$1" "$2"
    shift 2
  done
}

open_if_not_running() {
  local bundle_id="$1"

  if is_running "$bundle_id"; then
    return 0
  fi

  open -b "$bundle_id"
}

open_apps() {
  while [[ "$#" -gt 0 ]]; do
    open_if_not_running "$2"
    shift 2
  done
}

node_mode() {
  local apps=(
    "Obsidian" "md.obsidian"
    "网易云音乐" "com.netease.163music"
  )

  ensure_apps_installed "${apps[@]}"
  open_apps "${apps[@]}"
}

pwn_mode() {
  local apps=(
    "UTM" "com.utmapp.UTM"
    "kitty" "net.kovidgoyal.kitty"
    "IDA" "com.hexrays.ida"
    "访达" "com.apple.finder"
  )

  ensure_apps_installed "${apps[@]}"
  open_apps "${apps[@]}"
}

main() {
  local mode="${1:-}"

  case "$mode" in
    node)
      node_mode
      ;;
    pwn)
      pwn_mode
      ;;
    *)
      usage
      return 2
      ;;
  esac
}

main "$@"
