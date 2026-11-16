# one-md

One `CLAUDE.md` that makes Claude Code answer plainly, check current docs before acting, settle everything up front, and then work for hours without waiting on you.

Claude Code reads `~/.claude/CLAUDE.md` at the start of every session, in every project. This repo is that file, plus an installer and a test.

## Install

```bash
git clone https://github.com/MoeDia/one-md.git && one-md/install.sh
```

Then open Claude Code and run `/memory`: the file should be listed under user memory.

| To | Run |
|---|---|
| Update | `cd one-md && git pull && ./install.sh` |
| Remove | `one-md/install.sh --uninstall` |

The installer works on macOS and Fedora 45. It is safe to run again: it changes nothing if the file is already current. If you already have a `~/.claude/CLAUDE.md`, it keeps it as `CLAUDE.md.bak-<date>`, and `--uninstall` puts the newest backup back. If that file is a link to somewhere else, it leaves it alone.

## What it makes Claude do

| Section | Behaviour |
|---|---|
| Talking to the user | Plain, short answers, recommendation first, evidence before saying "done" |
| Your knowledge is out of date | Reads current official docs before using any tool, flag, model or price |
| Being right | A source for every claim, a second check by a different route, "unknown" when unsure |
| First: what's missing? | Before changing anything, tests every tool, login and connector the task needs, installs what it can, and asks once for what needs a person |
| Long or unattended work | Asks everything at the start, keeps a progress file with a done condition, commits after each passing step |
| How work is done | Small commits, tests seen failing first, independent review of risky changes |
| Permission | Deploys, pushes, installs, uses sudo and credentials without asking; stops only for money, permanent deletion and messaging people |
| Secrets | Uses secrets, never writes them anywhere |
| Research | One file per question, with evidence labels |
| Notes that last | Corrections become dated rules; incidents are written up |
| Saving tokens | Reads only what's needed; prefers interactive sessions to `claude -p` loops |
| Working in herdr | One task per pane, asks through the question prompt, own branch per pane |

## Read before installing

- **It gives Claude wide permission.** Claude is told it may deploy, push, use sudo and use credentials without asking. It still stops for three things: spending money, permanently deleting real data, and messaging real people. Edit the "Permission" section if you want less.
- **Instructions, not locks.** Anthropic's docs describe `CLAUDE.md` as context, not enforcement. A rule that must never be broken belongs in a [hook](https://code.claude.com/docs/en/hooks-guide.md).
- **Prompts are a separate setting.** Whether Claude Code asks before each command is set in `~/.claude/settings.json`. Auto mode keeps a background safety check while removing most prompts:

  ```json
  { "permissions": { "defaultMode": "auto" } }
  ```

- **Project files still apply.** A repo's own `CLAUDE.md` or `AGENTS.md` loads too and wins on that repo's specifics. What you say in the conversation wins over both.

The rules about Claude Code and herdr were checked against [Claude Code's docs](https://code.claude.com/docs/en/best-practices), [herdr's docs](https://herdr.dev/docs/agents) and the most-reported issues on [anthropics/claude-code](https://github.com/anthropics/claude-code/issues) in November 2026.

## Test

```bash
./test.sh
```

It checks the file (under 200 lines, no placeholders, no secrets, no personal names, every section described here) and the installer, in a throw-away home directory. CI runs it on macOS and Fedora 45 on every push.

## License

MIT
