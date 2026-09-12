#!/usr/bin/env zsh

set -eu

script_dir=${0:A:h}
tmp_root=$(mktemp -d "${TMPDIR:-/tmp}/venv-test.XXXXXX")
trap 'rm -rf "$tmp_root"' EXIT

mkdir -p "$tmp_root/root/alpha/bin" "$tmp_root/root/beta" "$tmp_root/root/alpha/nested/.venv"
touch "$tmp_root/root/alpha/bin/python"
chmod +x "$tmp_root/root/alpha/bin/python"

export CHENHUN_PYTHON_VENV_ROOT="$tmp_root/root"
source "$script_dir/venv.zsh"

names=($(venv_names 2>"$tmp_root/warnings"))
[[ "${(j:,:)names}" == "alpha,beta" ]]
[[ "$(<"$tmp_root/warnings")" == *"beta"* ]]
[[ "${names[(I).venv]}" -eq 0 ]]

unset CHENHUN_PYTHON_VENV_ROOT
export HOME="$tmp_root/home"
mkdir -p "$HOME/.py_venvs"
source "$script_dir/venv.zsh"
[[ "$VENV_DIR" == "$HOME/.py_venvs" ]]

print -r -- 'PASS'
