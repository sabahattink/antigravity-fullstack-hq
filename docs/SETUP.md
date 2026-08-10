# Setup Guide

This repository installs prompt/configuration files for Google Antigravity and Claude Code. It does not install runtimes, packages, or project dependencies.

## Prerequisites

- Git
- Google Antigravity and/or Claude Code
- PowerShell on Windows, or Bash on macOS/Linux

The installers copy files relative to the repository. Clone the repository before running either installer; do not pipe the script directly from a URL.

## Standard installation

### Windows (PowerShell)

```powershell
git clone https://github.com/sabahattink/antigravity-fullstack-hq.git
Set-Location antigravity-fullstack-hq
.\install.ps1
```

### macOS / Linux

```bash
git clone https://github.com/sabahattink/antigravity-fullstack-hq.git
cd antigravity-fullstack-hq
chmod +x install.sh
./install.sh
```

By default, both host integrations are prepared.

## Selective installation

### Windows

```powershell
.\install.ps1 -OnlyAntigravity
.\install.ps1 -OnlyClaude
.\install.ps1 -Force
```

### macOS / Linux

```bash
./install.sh --only-antigravity
./install.sh --only-claude
./install.sh --force
```

`-Force` / `--force` skips the prompt for an existing `GEMINI.md` or `CLAUDE.md`. The current scripts prompt only for those global rules files; same-named agent, skill, and workflow files are copied into their target directories.

## Installed files

| Component | Google Antigravity | Claude Code |
|-----------|-------------------|-------------|
| Global rules | `~/.gemini/GEMINI.md` | `~/.claude/CLAUDE.md` |
| Agents | `~/.gemini/antigravity/agents/` | `~/.claude/agents/` |
| Skills | `~/.gemini/antigravity/skills/` | `~/.claude/skills/` |
| Workflows | `~/.gemini/antigravity/workflows/` | Not installed by these scripts |

Restart the host application and start a new conversation after installation.

## Verification

Try a small, reversible prompt such as:

```text
Create a React component called UserCard
```

The installed rules are intended to make the agent present a plan and request approval before making changes. This is prompt/configuration guidance, not a runtime permission boundary.

Workflows are available to Antigravity using their slash commands, for example `/brainstorm` and `/plan`. Claude Code receives its host-specific rules, agents, and skills; these scripts do not install the Antigravity workflow directory into Claude Code.

## Customization

- Edit `~/.gemini/GEMINI.md` for Antigravity defaults.
- Edit `~/.claude/CLAUDE.md` for Claude Code defaults.
- Add or refine agents, skills, and workflows in the cloned repository before reinstalling.

See [CUSTOMIZATION.md](CUSTOMIZATION.md) for examples.

## Uninstallation

To remove the Antigravity files installed by this repository:

```powershell
Remove-Item -Recurse -Force "$env:USERPROFILE\\.gemini\\antigravity"
```

```bash
rm -rf ~/.gemini/antigravity
```

Remove `GEMINI.md` or `CLAUDE.md` separately only if you are sure they are managed by this repository and do not contain your own rules.
