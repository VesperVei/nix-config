# Python Venv Cross-Platform Design

## Goal

让 Neovim 和 Zsh 在 macOS+nix-darwin、Linux+NixOS 上共享同一套 Python venv 管理规则：共享环境统一放在 `~/.py_venvs`，项目自己的 `.venv` 自动识别但不进入总列表。

## Environment Classes

### Shared environments

- Location: `$CHENHUN_PYTHON_VENV_ROOT`, defaulting to `$HOME/.py_venvs`.
- Each direct child directory is a named environment, for example `~/.py_venvs/pwn`.
- Neovim's chooser and `va` enumerate only these direct children.
- The implementation does not scan arbitrary directories for Python projects or venvs.

### Project-local environments

- Only `.venv/` is recognized.
- Search starts at the file's directory and walks upward.
- A directory is usable only when `bin/python` exists; a broken interpreter is reported as unhealthy.
- Local environments are not added to the shared inventory, except that the current project's local environment is shown in the chooser so the user can switch back to it.

## Resolution Order

For a Python buffer, resolve in this exact order:

1. A manual override for the resolved project scope. It may select a shared environment, the current project's local `.venv`, or `system`.
2. The nearest usable project-local `.venv`.
3. The nearest `.pyvenv` declaration. Its first non-empty trimmed line is a shared environment name under `~/.py_venvs`.
4. The configured system `python3`.

Manual overrides are session-only and keyed by project scope. Selecting an environment from `<leader>pv` therefore remains effective when opening another Python file in the same project. Selecting `system` explicitly suppresses automatic local/declaration discovery for that scope.

## Project Scope

Resolve scope from a file path using this fallback order:

1. Nearest ancestor containing `.pyvenv`; that directory is the scope.
2. Nearest ancestor containing `pyproject.toml`, `setup.py`, or `setup.cfg`.
3. Nearest ancestor containing `.git`.
4. No scope (`nil`) for standalone files with no marker.

The resolver must be path-boundary aware, so `/work/app` does not match `/work/application`. Existing Pyright integration continues to use this resolver first, then its existing `requirements.txt` fallback and file directory fallback.

## Health and Failure Behavior

- A venv is healthy only if its `bin/python` path exists and is executable/usable.
- A dangling `bin/python` symlink must not silently become the system interpreter. Neovim emits one warning per environment per session, including the path and a concrete `uv venv --python ...` rebuild hint, then falls back to the system interpreter for runtime safety.
- A missing `.pyvenv` target produces the same warning and system fallback.
- Manual selection refuses unknown or unhealthy shared environments and leaves the current state unchanged.
- The chooser includes unhealthy shared environments with a warning marker, but selecting one only shows the rebuild guidance.

## Chooser Contract

`<leader>pv` displays, in order:

1. Current project's `.venv` when present, labeled as local/current project.
2. All direct child directories under `~/.py_venvs`, sorted deterministically.
3. `system`.

The current local entry uses its absolute path internally, while shared entries use names. No other local project venv is displayed.

## Platform Contract

Lua must not contain platform-specific Python installation paths. Nix sets both `WORKON_HOME` and `CHENHUN_PYTHON_VENV_ROOT` to `${config.home.homeDirectory}/.py_venvs`; this expands correctly for both Home Manager targets. `python3` continues to come from `vim.fn.exepath("python3")`.

The Zsh helper reads `CHENHUN_PYTHON_VENV_ROOT` with the same `~/.py_venvs` fallback, so it discovers exactly the same shared inventory as Neovim. It must not hard-code the previous Documents path.

## Removal

Delete the obsolete `python_venv_map.example.lua` and all map-loading, project-prefix matching, and map-related state. No replacement mapping file is introduced.

## Verification

- Headless Neovim tests cover scope discovery, local-over-shared resolution, manual override precedence, declaration lookup, missing/broken venv warnings, and chooser inventory boundaries.
- Shell tests or a deterministic Zsh smoke script cover root override/fallback and direct-child enumeration.
- Run Lua syntax/headless tests and `nix flake check` or the repository's available Nix evaluation command before completion.
