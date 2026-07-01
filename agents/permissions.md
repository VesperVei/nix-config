# Permissions Configuration

This document records the baseline permission requirements for AI agents on this workstation.

## Scope

| Environment | Policy |
| --- | --- |
| Personal macOS workstation | Restrictive - protect daily workflow and credentials |
| Disposable development VM | Permissive - agents may have broader autonomy |

The permissions below apply to the personal workstation only.

## Default Policy

| Tool | Permission |
| --- | --- |
| `*` | ask |

## File Read Permissions

| Pattern | Permission |
| --- | --- |
| `*` | allow |
| `*.env` | deny |
| `*.env.*` | deny |
| `*.env.example` | allow |
| `*.pem` | deny |
| `*.key` | deny |
| `*kubeconfig*` | deny |
| `.ssh/**` | deny |
| `.aws/**` | deny |
| `.kube/**` | deny |
| `.gnupg/**` | deny |
| `~/nix-secrets/**` | deny |
| `/run/agenix/**` | deny |

## Always Allowed Tools

- `glob`
- `grep`
- `lsp`
- `question`
- `skill`
- `todowrite`
- `webfetch`
- `edit` within approved workspace

## Bash Command Permissions

### Always Allowed Read-Only Operations

- `git status`, `git diff`, `git log`, `git show`, `git branch`, `git remote`
- `nix eval`, `nix build`, `nix flake show`, `nix flake metadata`, `nix flake check`
- `nix profile list`, `nix profile history`, `nix store ls`, `nix store path-info`
- `darwin-rebuild build`, `home-manager build`, `nh os build`, `nh home build`
- `just --list`, `just --show`, `just --dry-run`
- `statix check`, `deadnix`, `nixfmt --check`, `shellcheck`, `prettier --check`, `ruff check`
- `node --version`, `pnpm list`, `uv pip list`, `python3 --version`
- `rg`, `fd`, `ls`, `pwd`, `date`, `file`, `stat`, `du`, `tree`, `bat`, `eza`, `jq`

### Requires Confirmation

| Command | Permission |
| --- | --- |
| `git push *` | ask |
| `git commit *` | ask |
| `nh darwin switch *` | ask |
| `nh home switch *` | ask |
| `darwin-rebuild switch *` | ask |
| `rm *` | ask |
| `mv *` outside workspace | ask |

### Always Denied Unless Explicitly Requested And Reconfirmed

| Command | Permission |
| --- | --- |
| `rm -rf *` | deny |
| `git reset --hard *` | deny |
| `git push --force *` | deny |
| `terraform destroy *` | deny |
| Secret-printing commands such as `cat /run/agenix/*` | deny |

## Summary

- Default policy: ask unless explicitly safe.
- Read-only search and evaluation are usually allowed.
- Sensitive files, private keys, cloud configs, and agenix secrets are blocked.
- Remote mutation, system switch, and commits require explicit user intent.
