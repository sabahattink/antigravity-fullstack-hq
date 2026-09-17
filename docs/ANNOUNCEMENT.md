# Launch announcement pack

> Draft for review before publishing. This file contains copy only; it does
> not publish to any external channel.

## Positioning

Full Stack HQ is a tool-agnostic, permission-first engineering configuration
kit for Claude Code, Google Antigravity IDE, and OpenAI Codex.

The message is simple: one shared engineering core, rendered into native host
formats, with specialist agents, reusable skills, workflow bridges, and safe
cross-platform installers.

## LinkedIn / Dev.to draft

AI coding tools are powerful when they can act. They become much more useful
when they also know how to inspect the real state, propose a bounded plan, ask
for approval, and verify the result.

I built **Full Stack HQ** to make that engineering loop portable across the
tools I use:

- Claude Code
- Google Antigravity IDE
- OpenAI Codex

The project keeps the behavior in one shared source of truth and renders only
the host-specific adapter details. It includes:

- 10 specialist agents
- 28 canonical Agent Skills
- 10 reusable workflows and workflow-to-skill bridges
- PowerShell and Bash installers
- dry-run, backup, isolated-target, and validation flows
- first-class Codex `AGENTS.md`, Agent Skills, and TOML custom-agent output

The goal is not to pretend that prompt configuration is a sandbox. The host
still controls tools, approvals, network access, and filesystem permissions.
The goal is to give the agent a clearer engineering operating model and give
the developer a more reviewable workflow.

Repository: https://github.com/sabahattink/antigravity-fullstack-hq

Feedback is welcome, especially from people using more than one AI coding
host and trying to keep their engineering standards consistent.

## Short post

I built Full Stack HQ: one permission-first engineering core for Claude Code,
Google Antigravity IDE, and OpenAI Codex.

It renders native rules, specialist agents, reusable skills, workflow bridges,
and safe installers from one source of truth.

MIT licensed: https://github.com/sabahattink/antigravity-fullstack-hq

## GitHub Discussion draft

### Full Stack HQ now supports Claude Code, Antigravity, and Codex from one core

Full Stack HQ started as an opinionated AI engineering configuration kit. It
now has a tool-agnostic core and first-class adapters for three AI coding
hosts.

The important design decision is to keep shared behavior in one place:

```text
core/rules/common.md
        ├── Claude Code adapter
        ├── Google Antigravity adapter
        └── OpenAI Codex adapter
```

The repository also preserves the existing public source layout, supports safe
upgrades, and validates generated outputs on Windows and Ubuntu.

If you try it, please share:

1. Which host you installed.
2. Whether the rules, agents, and skills appeared in the expected locations.
3. Which workflow or specialist needs the most improvement.

## Before publishing checklist

- [ ] Open the GitHub README and confirm the SVG visuals render correctly.
- [ ] Run the PowerShell and Bash validators from a clean checkout.
- [ ] Use the repository link from the current `main` branch.
- [ ] Keep the post factual: no invented adoption, performance, or security claims.
- [ ] Invite installation feedback instead of asking for an artificial star push.
