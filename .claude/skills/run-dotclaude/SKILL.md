---
name: run-dotclaude
description: Install, bootstrap, and verify dotclaude on a new machine. Use when asked to set up dotclaude, install dotfiles, create symlinks, register MCPs, or onboard a new machine.
---

Dotfiles repo for Claude Code — agents, skills, global settings, and MCP server registration. Driven via two shell scripts in this skill directory.

All paths below are relative to the repo root (`repo/dotclaude/`).

## Prerequisites

- `git`, `python3`, `claude` CLI, `npx` (Node.js) — already present on any machine with Claude Code installed.
- No additional `apt-get` needed.

## Run (agent path)

### Step 1 — Symlinks

```bash
bash .claude/skills/run-dotclaude/install.sh
```

Expected output (fresh machine):
```
dotclaude: installing from /home/<user>/repo/dotclaude
  linked  /home/<user>/.claude/settings.json -> ...
  linked  /home/<user>/.claude/agents -> ...
  linked  /home/<user>/.claude/skills -> ...
  linked  /home/<user>/.claude.json -> ...
```

If symlinks already exist and point to the right targets, each line shows `ok` instead of `linked`. If a plain file is in the way, it's renamed to `*.bak` before the symlink is created.

Creates these four symlinks:

| Symlink | Points to |
|---|---|
| `~/.claude/settings.json` | `.claude/settings.json` |
| `~/.claude/agents` | `.claude/agents/` |
| `~/.claude/skills` | `.claude/skills/` |
| `~/.claude.json` | `.claude.json` |

### Step 2 — MCP servers

```bash
bash .claude/skills/run-dotclaude/register-mcps.sh
```

Registers all 8 MCP servers at `--scope user` (global). Safe to re-run — removes then re-adds each one.

For `github`, set `GITHUB_PAT` in your environment — the header is `Bearer ${GITHUB_PAT}` and Claude Code expands it at runtime.

For `elasticsearch`, set `ES_URL` and `ES_API_KEY` in your environment or shell profile.

### Verify

```bash
claude mcp list
```

Should show all 8 servers. HTTP ones (`betterstack`, `linear`, `sentry`, `clickup`, `github`) show "Needs authentication" until you OAuth-authorize them in a Claude Code session.

## Run (human path)

Same as agent path — there's no GUI.

## Gotchas

- **`~/.claude.json` is machine-local state** — it also contains `numStartups`, `tipsHistory`, `oauthAccount`, `userID`, and `projects`. Syncing it across machines will overwrite that state. Use the symlink for MCP config portability, but don't be surprised if UI state resets when you push from one machine and pull on another.

- **`register-mcps.sh` removes then re-adds** — this means any OAuth tokens stored in `~/.claude.json` for HTTP MCPs (linear, sentry, etc.) get cleared on re-run. Re-authorize in Claude Code after running it.

- **Sounds hook is Linux/WSL-only as configured** — `play.py` detects the OS. On WSL it calls `wslpath` + `powershell.exe`. On macOS, switch the hook in `settings.json` to use `afplay` directly.
