# RULES - Global Agent Baseline

This file defines the cross-project baseline for AI coding agents. It focuses on safety, boundaries,
and portable behavior.

## 1) Instruction Priority

Apply instructions in this order:

1. Runtime system/developer instructions
2. User task request
3. Project-local policy (`AGENTS.md`, `CLAUDE.md`, repo docs)
4. This global RULES

If rules conflict, follow the higher-priority source and state the conflict briefly.

## 2) Hard Safety Boundaries (MUST NOT)

- MUST NOT read/write outside the approved workspace unless explicitly requested.
- MUST NOT perform broad operations on the entire home directory.
- MUST NOT mutate remote Git state unless explicitly requested.
- MUST NOT auto-run remote-mutating commands unless explicitly requested.
- MUST NOT use destructive/force/delete options unless explicitly requested and confirmed.
- MUST NOT expose or commit secrets, tokens, keys, kubeconfig credentials, or passwords.

## 3) Security and Secrets Handling

- Never write secret literals into tracked files.
- Use environment variables, secret managers, or placeholders.
- Redact sensitive output in logs and summaries.
- For Nix, system, and infra changes, prefer eval/build/check before switch/apply.
- Keep API keys in agenix-managed files such as `/run/agenix/ai-cli-api-keys.zsh`.

## 4) Scope Discipline

- Keep changes strictly within requested scope.
- Do not refactor unrelated areas unless the user asks.
- Preserve backward compatibility unless a breaking change is explicitly requested.
- Do not manage or overwrite existing runtime config unless explicitly requested.

## 5) Change Hygiene

- Keep diffs minimal and reviewable.
- Group logically related edits together.
- Do not revert user or unrelated changes unless explicitly asked.
- Do not claim verification you did not run.
- Commit only when explicitly requested.

## 6) Tooling Defaults

- Prefer structural search tools first when available, then fast text tools such as `rg` and `fd`.
- Prefer project task runners (`just`, `make`, `task`, `npm scripts`) over ad-hoc commands when equivalent.
- If a required command is not already available, use `nix run`, a project flake/dev shell, `uv`, or `pnpm`.
- If that is still insufficient, stop and ask the user to prepare the environment instead of installing tools ad hoc.
- Use `gh` CLI for GitHub operations when available.

## 7) Environment Defaults

- Primary OS: macOS Darwin with nix-darwin and Home Manager.
- Shell: `zsh`.
- Nix config repository: `~/nix-config`.
- Private encrypted secrets repository: `~/nix-secrets`.

## 8) Script Engineering Principles

Treat scripts as interruptible jobs that must be diagnosable and safe to rerun:

- Split workflows into explicit stages; allow running a selected stage via flags or arguments.
- Make reruns idempotent; persist progress after each stage and support resume.
- Cache external data with invalidation strategy to speed retries and improve reproducibility.
- For HTTP flows, separate transport success from business success; support retry and backoff.
- Provide independent verification commands/checks for key outputs.

## 9) Communication Defaults

- Respond in the language the user is currently using, usually Chinese.
- Keep code, commands, identifiers, and code comments in English unless the project uses otherwise.
- Be concise, concrete, and action-oriented.

## 10) Project Overlay

Project-local policy may add stricter constraints for build, test, deploy, style, ownership, or environment.
It must not weaken this baseline.
