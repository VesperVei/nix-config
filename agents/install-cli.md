# Agent CLI Commands

Reference commands for installing and updating agent CLIs. Run only the commands you need.

## Install CLIs

Installed via Nix in `home/base/gui/dev-tools.nix` using `llm-agents`:

- `codex`
- `cursor-cli`
- `claude-code`
- `opencode`
- `rtk`

## API Keys

API keys are injected by zsh from agenix-managed secrets:

```bash
/run/agenix/ai-cli-api-keys.zsh
```

Do not write API keys into tracked files, Nix settings, `opencode.json`, or MCP config.

## Optional Tooling

```bash
# context7: up-to-date docs and code examples for LLMs and agents
npx ctx7 setup
```

`rtk` init snippets:

```bash
rtk init -g
rtk init -g --codex
rtk init -g --opencode
rtk init -g --agent cursor
```

## Update npm-installed agent tools

```bash
npm update -g
```
