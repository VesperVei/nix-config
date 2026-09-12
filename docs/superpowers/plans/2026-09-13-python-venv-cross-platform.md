# Python Venv Cross-Platform Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild Python venv discovery so macOS and Linux share `~/.py_venvs`, project `.venv` files work automatically, and manual selection remains scoped and persistent.

**Architecture:** Keep the public Neovim module API used by `lspconfig.lua`, but replace its discovery/state internals with explicit environment records (`system`, `shared`, `local`) and a single resolver. Use the same environment-root variable in Nix and Zsh. Add a headless Neovim regression harness and a Zsh smoke test because this repository has no existing Lua test framework.

**Tech Stack:** Lua (Neovim `vim.fs`/`vim.uv` APIs), Zsh, Home Manager/Nix, headless Neovim.

## Global Constraints

- Support macOS+nix-darwin and Linux+NixOS; Windows is out of scope.
- Shared environments live under `~/.py_venvs`.
- Only `.venv/` is recognized as a project-local environment.
- Manual override is the highest resolution priority within its project scope.
- Project-local environments are excluded from the global inventory except for the current project's chooser entry.
- Remove `python_venv_map.lua` loading and `python_venv_map.example.lua`.
- Do not mutate or rebuild venvs automatically; warn with a rebuild command.

---

### Task 1: Add failing Neovim discovery tests

**Files:**
- Create: `home/base/tui/nvim/tests/python_venv_test.lua`
- Modify: `home/base/tui/nvim/config/lua/chenhun/core/python_venv.lua` only after the test fails

**Interfaces:**
- The test invokes exported discovery helpers or a test-facing `M._test` table containing `resolve_project_root`, `resolve_state`, and `list_choices`.
- The resolver returns records with `kind` (`system`, `shared`, `local`), `name`, `path`, and `python_path`.

- [ ] **Step 1: Create a headless fixture test**

Create temporary directories with `.pyvenv`, `pyproject.toml`, `.git`, `.venv/bin/python`, and `~/.py_venvs/shared` fixtures. Assert:

```lua
assert(root_for(project_file_with_pyvenv) == project_with_pyvenv)
assert(root_for(file_under_pyproject) == pyproject_root)
assert(root_for(file_under_git) == git_root)
assert(root_for(standalone_file) == nil)
assert(resolve(local_project_file).kind == "local")
assert(resolve(declared_project_file).name == "shared")
```

- [ ] **Step 2: Add priority and inventory assertions**

Set a manual override for the fixture scope and assert it wins over `.venv`; set `system` and assert automatic discovery is suppressed. Assert the chooser contains only the current local environment, direct shared children, and `system`, never a sibling project's `.venv`.

- [ ] **Step 3: Run the test before implementation**

Run:

```bash
nvim --headless -u NONE -l home/base/tui/nvim/tests/python_venv_test.lua
```

Expected: FAIL because the new test-facing resolver contract does not yet exist.

### Task 2: Rewrite Neovim venv discovery and state management

**Files:**
- Modify: `home/base/tui/nvim/config/lua/chenhun/core/python_venv.lua`
- Delete: `home/base/tui/nvim/config/lua/chenhun/core/python_venv_map.example.lua`

**Interfaces:**
- Preserve `resolve_project_root`, `get_pyright_python_settings_for_path`, `on_pyright_attach`, `autoset_venv`, `set_venv`, `choose_venv`, `show_session_status`, and `lualine_component`.
- `set_venv(value)` accepts `system`, a shared name, or the current project's local `.venv` absolute path.

- [ ] **Step 1: Replace configuration and map state**

Use:

```lua
local config = {
  venv_root = vim.env.CHENHUN_PYTHON_VENV_ROOT or (home .. "/.py_venvs"),
  default_bin = python3 ~= "" and python3 or "python3",
  icon = "🐍 ",
}
```

Remove `pcall(require, "chenhun.core.python_venv_map")`, `project_venv_map`, and `project_roots`.

- [ ] **Step 2: Implement marker-based project scope**

Implement upward traversal from `path_to_directory(path)`. Check `.pyvenv` first, then `pyproject.toml`, `setup.py`, `setup.cfg`, then `.git`. Return the first matching directory and stop at filesystem root. Use exact directory equality or `root .. "/"` prefix checks for scope matching.

- [ ] **Step 3: Implement explicit environment records**

Use absolute local paths and shared names without guessing. A shared record resolves to `venv_root/name`; a local record resolves directly to `project/.venv`; the system record uses `default_bin`. Validate `bin/python` using `vim.uv.fs_stat` plus executable/usable checks, and distinguish missing/broken environments from `system`.

- [ ] **Step 4: Implement the exact priority chain**

For a path, consult `cache.project_overrides[scope]` first, then nearest `.venv`, then `.pyvenv`'s trimmed first line, then system. Store override values as `system`, shared names, or local absolute paths. Keep the existing nil-scope fallback for standalone files so a manual choice still affects the current session without leaking into unrelated files.

- [ ] **Step 5: Add deduplicated warnings and safe fallback**

Warn once per broken path/name per session with the environment path and `uv venv --python <python3-path> <venv-path>` rebuild hint. Do not change `VIRTUAL_ENV`, `PATH`, or Pyright settings to a broken interpreter. Manual selection must return `false` without changing cache state when validation fails.

- [ ] **Step 6: Rebuild chooser entries**

Enumerate direct directories with `vim.fs.dir(config.venv_root)` or `vim.uv.fs_scandir`, sort names, and add the current project's `.venv` first when present. Use an internal entry-to-record map rather than stripping the icon from display text. Always append `system`; mark broken shared entries but keep them selectable for the warning path.

- [ ] **Step 7: Keep LSP integration compatible**

Continue returning `pythonPath` and, for local/shared records, `venvPath` and `venv`. Preserve existing Pyright client synchronization and session UI behavior while updating labels to distinguish `local`, `shared`, and `system`.

- [ ] **Step 8: Run the focused test and syntax check**

Run:

```bash
nvim --headless -u NONE -l home/base/tui/nvim/tests/python_venv_test.lua
nvim --headless -u NONE +'luafile home/base/tui/nvim/config/lua/chenhun/core/python_venv.lua' +qa
```

Expected: the fixture test passes and Neovim exits without Lua errors.

### Task 3: Unify Nix and Zsh shared-root configuration

**Files:**
- Modify: `home/base/tui/zsh/default.nix`
- Modify: `home/base/tui/zsh/scripts/venv.zsh`
- Create: `home/base/tui/zsh/scripts/venv_test.zsh`

**Interfaces:**
- Nix sets `WORKON_HOME` and `CHENHUN_PYTHON_VENV_ROOT` to `${config.home.homeDirectory}/.py_venvs`.
- Zsh helper functions (`va`, `vl`, `vc`, `vd`, `pwn`, `crypto`) use the same root.

- [ ] **Step 1: Write the Zsh smoke test first**

Run the helper with a temporary `CHENHUN_PYTHON_VENV_ROOT`, create two direct child directories and one nested unrelated `.venv`, then assert `va`/the inventory helper reports only the two direct children. Assert an unset variable falls back to `$HOME/.py_venvs`.

- [ ] **Step 2: Run the smoke test and observe failure**

Run:

```bash
zsh home/base/tui/zsh/scripts/venv_test.zsh
```

Expected: FAIL because the current script hard-codes `~/Documents/code/python/.venvs` and has no testable inventory helper.

- [ ] **Step 3: Update the root and add a non-interactive inventory helper**

Use:

```zsh
: ${CHENHUN_PYTHON_VENV_ROOT:=$HOME/.py_venvs}
VENV_DIR="$CHENHUN_PYTHON_VENV_ROOT"
function venv_names() {
  local path
  for path in "$VENV_DIR"/*(/N); do
    print -r -- "${path:t}"
  done
}
```

Make `va` consume `venv_names`, preserve deterministic ordering, and show warnings for unusable `bin/python` entries without scanning project directories.

- [ ] **Step 4: Update Nix and rerun shell verification**

Replace both old `Documents` assignments with:

```nix
WORKON_HOME = "${config.home.homeDirectory}/.py_venvs";
CHENHUN_PYTHON_VENV_ROOT = "${config.home.homeDirectory}/.py_venvs";
```

Run the smoke test again and require PASS.

### Task 4: Verify Nix evaluation and full integration

**Files:**
- Modify only files from Tasks 1-3 as needed after failures

- [ ] **Step 1: Search for stale mapping and root references**

Run:

```bash
rg -n 'python_venv_map|\.virtualenvs|Documents/code/python/\.venvs|CHENHUN_PYTHON_VENV_ROOT|WORKON_HOME' home docs
```

Expected: no Lua map imports or old path literals; only the new root references and design/plan documentation remain.

- [ ] **Step 2: Run focused tests and Lua loading**

Run:

```bash
nvim --headless -u NONE -l home/base/tui/nvim/tests/python_venv_test.lua
zsh home/base/tui/zsh/scripts/venv_test.zsh
```

Expected: both commands exit 0.

- [ ] **Step 3: Evaluate the flake**

Run the repository-supported check:

```bash
nix flake check --no-build
```

Expected: evaluation succeeds without introducing a platform-specific path or syntax error. If this flake has no check outputs, run the relevant Home Manager evaluation target exposed by `outputs/` and record that result instead of claiming a full build.

- [ ] **Step 4: Inspect the final diff**

Run:

```bash
git diff --check
```

Confirm unrelated existing modifications remain untouched, the map example is deleted, and only the design, plan, implementation, and focused test files are included.
