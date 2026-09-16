# Setup Guide

Full Stack HQ installs prompt/configuration files for Google Antigravity IDE,
Claude Code, and OpenAI Codex. It does not install runtimes, packages, or
project dependencies.

## Prerequisites

- Git
- One or more supported hosts
- PowerShell on Windows, or Bash on macOS/Linux
- A local checkout of this repository

## Standard installation

### Windows

    git clone https://github.com/sabahattink/antigravity-fullstack-hq.git
    Set-Location antigravity-fullstack-hq
    .\install.ps1

### macOS / Linux

    git clone https://github.com/sabahattink/antigravity-fullstack-hq.git
    cd antigravity-fullstack-hq
    bash install.sh

By default, all supported host integrations are prepared.

## Selective installation

### Windows

    .\install.ps1 -OnlyAntigravity
    .\install.ps1 -OnlyClaude
    .\install.ps1 -OnlyCodex

### macOS / Linux

    bash install.sh --only-antigravity
    bash install.sh --only-claude
    bash install.sh --only-codex

Only one selective host option may be used at a time.

## Safe upgrades

The default behavior is intentionally conservative:

- Existing global rule files are confirmed interactively.
- Existing agent and skill files are kept.
- Use Force only when you explicitly want managed files replaced.
- Use Backup together with Force to create sibling backups before replacement.
- Use DryRun to inspect the plan without writing target files.
- Use TargetRoot / --target-root to run an isolated smoke test without touching
  the real home directory.

### Windows

    .\install.ps1 -DryRun
    .\install.ps1 -Force -Backup
    .\install.ps1 -TargetRoot .\tmp\host-home -OnlyCodex -Force

### macOS / Linux

    bash install.sh --dry-run
    bash install.sh --force --backup
    bash install.sh --target-root ./tmp/host-home --only-codex --force

Backups are named with a Full Stack HQ timestamp suffix. The installer never
deletes unrelated files or removes a legacy tree automatically.

## Installed files

| Component | Google Antigravity IDE | Claude Code | OpenAI Codex |
|-----------|------------------------|-------------|--------------|
| Global rules | ~/.gemini/GEMINI.md | ~/.claude/CLAUDE.md | ~/.codex/AGENTS.md |
| Agents | ~/.gemini/config/agents/ | ~/.claude/agents/ | ~/.codex/agents/*.toml |
| Skills | ~/.gemini/config/skills/ | ~/.claude/skills/ | ~/.agents/skills/ |
| Workflows | ~/.gemini/config/workflows/ | Generated skills | Generated skills |

If CODEX_HOME is set, Codex's global rules and custom agents use that
directory. Codex user skills remain in ~/.agents/skills/.

If the active Codex home already contains AGENTS.override.md, Codex prioritizes
that file over AGENTS.md. The installer warns but never overwrites the
override; merge the shared policy there only after reviewing the difference.

## Antigravity migration bridge

Older Full Stack HQ releases used ~/.gemini/antigravity/ for agents, skills,
and workflows. The current installer writes the documented global locations
under ~/.gemini/config/. When the old tree already exists, matching files are
refreshed there as well unless NoLegacyPaths is selected.

New installations do not create the legacy tree. This keeps upgrades safe while
avoiding two active copies for new users.

## Workflow migration

The canonical workflow files remain in workflows/ so existing Antigravity users
can continue using them. The installer also converts each workflow to an
Agent Skills-compatible directory with SKILL.md for all three hosts.

This gives Codex and Claude Code the same reusable procedures without relying on
Codex's deprecated custom-prompt mechanism. In modern Antigravity, the skill
bridge is ready for the host's workflow-to-skill migration.

## Verification

Run source and adapter validation before installation:

### Windows

    .\scripts\validate.ps1
    .\install.ps1 -Check

### macOS / Linux

    bash scripts/validate.sh
    bash install.sh --check

The validator checks:

- YAML frontmatter and name/path consistency
- Skill and workflow metadata
- Canonical content for accidental host-specific leakage
- Codex TOML agent generation
- Workflow-to-skill conversion counts

After installation, restart the host application and start a new conversation.
Use a small reversible prompt:

    Create a React component called UserCard

The expected behavior is plan → approval → execution → verification → report.
This is instruction guidance, not a runtime sandbox.

## Troubleshooting

### Rules do not appear

Restart the host application and start a new conversation. For Codex, confirm
the active Codex home and the project root from which the session starts.

### Existing files were not replaced

Use Force after reviewing DryRun output. Use Backup if you need a recoverable
copy of each replaced file.

### Antigravity loads an older copy

If an older installation created ~/.gemini/antigravity/, let the default
compatibility bridge refresh it, or remove that old tree manually only after
confirming it contains no custom files.

## Uninstallation

The installer does not provide an automatic delete operation because global
configuration files may contain user customizations.

To remove this repository's managed files, first inspect the installed paths,
restore any backups you need, then remove only the matching files manually.
Never remove an entire home directory or a host configuration directory.
