#!/usr/bin/env zsh

set -eu

script_dir=${0:A:h}
tmp_root=$(mktemp -d "${TMPDIR:-/tmp}/venv-test.XXXXXX")
trap 'rm -rf "$tmp_root"' EXIT

mkdir -p "$tmp_root/root/alpha/bin" "$tmp_root/root/beta" "$tmp_root/root/alpha/nested/.venv" "$tmp_root/root/odd name * env/bin"
newline_name=$'line\nname'
mkdir -p "$tmp_root/root/$newline_name/bin"
control_name=$'control\001name'
mkdir -p "$tmp_root/root/$control_name/bin"
touch "$tmp_root/root/alpha/bin/python"
touch "$tmp_root/root/odd name * env/bin/python"
chmod +x "$tmp_root/root/alpha/bin/python" "$tmp_root/root/odd name * env/bin/python"
touch "$tmp_root/root/$newline_name/bin/python"
chmod +x "$tmp_root/root/$newline_name/bin/python"
touch "$tmp_root/root/$control_name/bin/python"
chmod +x "$tmp_root/root/$control_name/bin/python"

export CHENHUN_PYTHON_VENV_ROOT="$tmp_root/root"
source "$script_dir/venv.zsh"

names=("${(@f)$(venv_names 2>"$tmp_root/warnings")}")
[[ ${#names[@]} -eq 3 ]]
[[ "${names[1]}" == "alpha" ]]
[[ "${names[2]}" == "beta" ]]
[[ "${names[3]}" == "odd name * env" ]]
[[ "${names[(I)$newline_name]}" -eq 0 ]]
[[ "${names[(I)$control_name]}" -eq 0 ]]
[[ "$(<"$tmp_root/warnings")" == *"beta"* ]]
[[ "${names[(I).venv]}" -eq 0 ]]

function assert_empty_va() {
    local root=$1
    local output="$tmp_root/${2}-output"
    export CHENHUN_PYTHON_VENV_ROOT="$root"
    source "$script_dir/venv.zsh"
    (
        va </dev/null >"$output" 2>&1
    ) &
    local va_pid=$!
    sleep 0.2
    if kill -0 "$va_pid" 2>/dev/null; then
        kill "$va_pid" 2>/dev/null || true
        wait "$va_pid" 2>/dev/null || true
        print -u2 -- 'va did not return for an empty root'
        return 1
    fi
    set +e
    wait "$va_pid"
    local va_status=$?
    set -e
    [[ $va_status -ne 0 ]]
    [[ "$(<"$output")" == *"没有找到虚拟环境"* ]]
}

mkdir -p "$tmp_root/empty"
assert_empty_va "$tmp_root/empty" empty
assert_empty_va "$tmp_root/missing" missing

unset CHENHUN_PYTHON_VENV_ROOT
export HOME="$tmp_root/home"
mkdir -p "$HOME/.py_venvs"
source "$script_dir/venv.zsh"
[[ "$VENV_DIR" == "$HOME/.py_venvs" ]]

print -r -- 'PASS'
