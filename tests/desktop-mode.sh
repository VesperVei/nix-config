#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT_DIR/home/darwin/desktop-mode/desktop-mode.sh"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_eq() {
  local expected="$1"
  local actual="$2"
  local message="$3"

  if [[ "$actual" != "$expected" ]]; then
    printf 'Expected:\n%s\nActual:\n%s\n' "$expected" "$actual" >&2
    fail "$message"
  fi
}

setup_fake_macos_tools() {
  TEST_TMPDIR="$(mktemp -d)"
  export TEST_TMPDIR
  export OPEN_LOG="$TEST_TMPDIR/open.log"
  : > "$OPEN_LOG"

  mkdir -p "$TEST_TMPDIR/bin"

  cat > "$TEST_TMPDIR/bin/osascript" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

expr="${2:-}"
app="${expr#application \"}"
app="${app%\" is running}"

while IFS= read -r running_app; do
  if [[ "$running_app" == "$app" ]]; then
    printf 'true\n'
    exit 0
  fi
done <<< "${RUNNING_APPS:-}"

printf 'false\n'
EOF

  cat > "$TEST_TMPDIR/bin/open" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" != "-a" || -z "${2:-}" ]]; then
  printf 'unexpected open args: %s\n' "$*" >&2
  exit 64
fi

printf '%s\n' "$2" >> "$OPEN_LOG"
EOF

  chmod +x "$TEST_TMPDIR/bin/osascript" "$TEST_TMPDIR/bin/open"
  export PATH="$TEST_TMPDIR/bin:$PATH"
}

teardown_fake_macos_tools() {
  rm -rf "$TEST_TMPDIR"
}

run_desktop_mode() {
  local mode="$1"
  bash "$SCRIPT" "$mode" > "$TEST_TMPDIR/stdout" 2> "$TEST_TMPDIR/stderr"
}

test_unknown_mode_does_not_open_apps() {
  setup_fake_macos_tools
  trap teardown_fake_macos_tools RETURN

  set +e
  run_desktop_mode unknown
  local status=$?
  set -e

  if [[ "$status" -eq 0 ]]; then
    fail 'unknown mode should fail'
  fi

  assert_eq '' "$(cat "$OPEN_LOG")" 'unknown mode should not open apps'
}

test_node_mode_opens_obsidian_and_netease_music() {
  setup_fake_macos_tools
  trap teardown_fake_macos_tools RETURN
  export RUNNING_APPS=''

  run_desktop_mode node

  assert_eq $'Obsidian\nNetEaseMusic' "$(cat "$OPEN_LOG")" 'node mode should open both apps'
}

test_node_mode_skips_apps_that_are_already_running() {
  setup_fake_macos_tools
  trap teardown_fake_macos_tools RETURN
  export RUNNING_APPS='Obsidian'

  run_desktop_mode node

  assert_eq 'NetEaseMusic' "$(cat "$OPEN_LOG")" 'node mode should skip running apps'
}

test_unknown_mode_does_not_open_apps
test_node_mode_opens_obsidian_and_netease_music
test_node_mode_skips_apps_that_are_already_running

printf 'desktop-mode tests passed\n'
