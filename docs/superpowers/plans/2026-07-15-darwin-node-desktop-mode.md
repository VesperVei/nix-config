# Darwin Node Desktop Mode Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an AeroSpace service-mode `n` binding that starts a `node` desktop mode by opening Obsidian and NetEase Music only when they are not already running.

**Architecture:** Keep window placement delegated to existing AeroSpace `on-window-detected` rules. Add a small `desktop-mode` command that only ensures apps are running, then package it through Home Manager and invoke it from AeroSpace service mode.

**Tech Stack:** Nix Home Manager, AeroSpace TOML, Bash, macOS `osascript`, macOS `open`.

## Global Constraints

- Preserve current workspace names, meanings, and visual footprint.
- Preserve existing app routing rules; do not move windows from the launcher script.
- Node mode opens exactly Obsidian and NetEase Music.
- Existing running apps must be skipped and not opened again.
- Bind node mode to `alt-shift-;` service mode, then `n`.
- Commit changes in reviewable batches.

---

## File Structure

- Create `home/darwin/desktop-mode/desktop-mode.sh`: Bash command implementing `desktop-mode node` and reusable `open_if_not_running` logic.
- Create `home/darwin/desktop-mode/default.nix`: Home Manager module installing `desktop-mode` into `home.packages`.
- Create `tests/desktop-mode.sh`: self-contained regression tests using fake `osascript` and `open` binaries on `PATH`.
- Modify `home/darwin/aerospace/config/aerospace.toml`: add service-mode `n` binding to run `desktop-mode node` and return to main mode.
- Optionally create `home/darwin/README.md`: document existing workspace model and node mode usage if no suitable doc exists.

## Reproducible Review Plan

### Batch 1: Plan Commit

**Files:**
- Create: `docs/superpowers/plans/2026-07-15-darwin-node-desktop-mode.md`

**Review Checks:**
- Run `git status --short` and confirm only the plan file is changed.
- Run `git diff -- docs/superpowers/plans/2026-07-15-darwin-node-desktop-mode.md` and confirm scope is planning only.
- Commit with `docs: plan darwin node desktop mode`.

### Batch 2: Desktop Mode Behavior

**Files:**
- Create: `tests/desktop-mode.sh`
- Create: `home/darwin/desktop-mode/desktop-mode.sh`

**Interfaces:**
- Produces command behavior: `desktop-mode.sh node`
- `node` mode app list:
  - `Obsidian`
  - `NetEaseMusic`
- Uses `osascript -e 'application id "<bundle-id>" is running'` to detect running apps.
- Uses `open -b "<bundle-id>"` only for apps reported as not running.

- [ ] **Step 1: Write the failing tests**

Create `tests/desktop-mode.sh` with tests that fake `osascript` and `open` via `PATH`.

Expected tested behavior:
- Unknown modes exit non-zero and do not open apps.
- `node` opens `md.obsidian` and `com.netease.163music` when both are not running.
- `node` skips `md.obsidian` when already running and still opens `com.netease.163music`.

- [ ] **Step 2: Run tests to verify RED**

Run: `bash tests/desktop-mode.sh`

Expected: FAIL because `home/darwin/desktop-mode/desktop-mode.sh` does not exist yet.

- [ ] **Step 3: Implement minimal script**

Create `home/darwin/desktop-mode/desktop-mode.sh` with:

```bash
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
```

- [ ] **Step 4: Run tests to verify GREEN**

Run: `bash tests/desktop-mode.sh`

Expected: PASS with all desktop-mode tests passing.

- [ ] **Step 5: Commit**

Review:
- Run `git status --short`.
- Run `git diff -- tests/desktop-mode.sh home/darwin/desktop-mode/desktop-mode.sh`.
- Commit with `feat(darwin): add node desktop mode launcher`.

### Batch 3: Home Manager and AeroSpace Integration

**Files:**
- Create: `home/darwin/desktop-mode/default.nix`
- Modify: `home/darwin/aerospace/config/aerospace.toml`
- Optionally create: `home/darwin/README.md`

**Interfaces:**
- `home/darwin/default.nix` already imports subdirectories via `mylib.scanPaths ./.`; adding `home/darwin/desktop-mode/default.nix` should auto-import the module.
- AeroSpace binding should call `desktop-mode node` from service mode.

- [ ] **Step 1: Add Home Manager package module**

Create `home/darwin/desktop-mode/default.nix`:

```nix
{ pkgs, ... }:
let
  desktopMode = pkgs.writeShellScriptBin "desktop-mode" (builtins.readFile ./desktop-mode.sh);
in
{
  home.packages = [ desktopMode ];
}
```

- [ ] **Step 2: Add AeroSpace service binding**

In `home/darwin/aerospace/config/aerospace.toml`, add under `[mode.service.binding]`:

```toml
n = ['exec-and-forget /bin/zsh -lc "desktop-mode node"', 'mode main']
```

- [ ] **Step 3: Document current workflow if needed**

Create or update `home/darwin/README.md` with current compact workspace model and node mode usage. Keep it short and do not propose renaming workspaces.

- [ ] **Step 4: Run verification**

Run:
- `bash tests/desktop-mode.sh`
- `nix eval .#homeConfigurations.zaochuan@macbook.activationPackage.drvPath --show-trace`
- `nix eval .#darwinConfigurations.macbook.system --show-trace --apply 'x: x.drvPath'`

Expected:
- Shell tests pass.
- Home Manager output evaluates.
- Darwin output evaluates.

- [ ] **Step 5: Commit**

Review:
- Run `git status --short`.
- Run `git diff`.
- Commit with `feat(darwin): bind node desktop mode in aerospace`.

## Self-Review

- Spec coverage: node mode, service binding, idempotent app open behavior, existing routing preservation, and batched commits are covered.
- Placeholder scan: no deferred implementation placeholders remain.
- Type consistency: command name is consistently `desktop-mode`; mode name is consistently `node`; apps are consistently `md.obsidian` and `com.netease.163music`.
