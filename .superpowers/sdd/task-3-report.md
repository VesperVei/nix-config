# Task 3 Report

## Status

Implemented unified Python virtual environment root integration for Nix and Zsh.

- Nix now sets both `WORKON_HOME` and `CHENHUN_PYTHON_VENV_ROOT` to `${config.home.homeDirectory}/.py_venvs`.
- Zsh uses `CHENHUN_PYTHON_VENV_ROOT`, falling back to `$HOME/.py_venvs` when unset.
- Added `venv_names` for deterministic direct-child inventory without scanning nested project directories.
- Unusable direct children without an executable `bin/python` produce warnings on stderr.
- `va` and existing helpers continue to use `VENV_DIR`.
- Neovim Lua was not modified.

## Verification

Commands run in `/Users/zaochuan/nix-config/.worktrees/python-venv-cross-platform`:

```text
$ zsh home/base/tui/zsh/scripts/venv_test.zsh
PASS

$ nix flake check --no-build
fetching git input 'git+file:///Users/zaochuan/nix-config/.worktrees/python-venv-cross-platform'
warning: Git tree '/Users/zaochuan/nix-config/.worktrees/python-venv-cross-platform' is dirty
evaluating flake...
checking flake output 'homeConfigurations'...
checking flake output 'darwinConfigurations'...

$ git diff --check
# no output
```

The smoke test verifies two direct children are listed, a nested `.venv` is ignored, an unusable child emits a warning, and an unset root falls back to `$HOME/.py_venvs`.

## Concerns

- Any direct child directory that is not a complete virtual environment will be listed and warned about; this preserves inventory visibility while making the problem explicit.
- `pwn` and `crypto` retain their existing activation behavior and assume their named environments exist under the shared root.

## Task 3 Review Fix

The empty-inventory review issue was fixed by collecting `venv_names` through a line-by-line read into an explicitly empty array. `va` now returns before any prompt when the root is missing or has no direct children, and unset `VIRTUAL_ENV` is safe under `set -u`.

The smoke test now covers:

- Empty and nonexistent roots returning nonzero without waiting for input.
- Direct-child names containing spaces and `*` remaining one array element.
- Existing direct-child-only and unusable `bin/python` warning behavior.

Commands run for the review fix:

```text
$ zsh home/base/tui/zsh/scripts/venv_test.zsh
PASS

$ nix flake check --no-build
fetching git input 'git+file:///Users/zaochuan/nix-config/.worktrees/python-venv-cross-platform'
warning: Git tree '/Users/zaochuan/nix-config/.worktrees/python-venv-cross-platform' is dirty
evaluating flake...
checking flake output 'homeConfigurations'...
checking flake output 'darwinConfigurations'...

$ git diff --check
# no output
```

The initial expanded smoke test failed before the fix because the empty inventory became one empty array element and `va` did not emit the no-environment prompt. After the fix, all requested checks pass.
