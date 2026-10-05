# How Full Stack HQ compares

AI coding agents now share a crowded space of configuration projects. They
fall into three groups, and Full Stack HQ sits between two of them. This page
explains the differences so you can choose the right tool. Projects change
quickly; the comparison reflects their public READMEs in October 2026.

## The three groups

| Group | What it gives you | Examples |
|---|---|---|
| **Rule-sync tools** | A CLI that copies *your* rules into each agent's file format. You write the content. | [rulesync](https://github.com/dyoshikawa/rulesync), [Ruler](https://github.com/intellectronica/ruler) |
| **Skill frameworks and harnesses** | Large libraries of skills, agents, hooks, and workflows, mostly built around one primary host. | [Superpowers](https://github.com/obra/superpowers), [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) |
| **Full Stack HQ** | A ready-made, permission-first engineering policy plus agents, skills, and workflows, rendered natively for several hosts from one source. | This repository |

## Side by side

| | Full Stack HQ | rulesync | Ruler | Superpowers | Everything Claude Code |
|---|---|---|---|---|---|
| Ships engineering rules you can use as-is | Yes | No, you bring the rules | No, you bring the rules | Yes, as a methodology | Yes |
| Explicit approval gate before edits | Yes, exact phrases such as `PLAN APPROVED` | — | — | Brainstorm and plan steps before coding | Plans before code; hooks for enforcement |
| Agents and skills included | 10 agents, 28 skills, 10 workflows | Generates them from your sources | Skills support | Skills-first library | Very large library (about 70 agents and 290 skills) |
| Global install | Claude Code, Codex, Antigravity | Yes | Yes | Through each host's plugin system | Yes |
| Repository install | `AGENTS.md` with `CLAUDE.md` and `GEMINI.md` imports | Yes | Yes | — | Yes |
| Hosts reached | Claude Code, Codex, Antigravity natively; Cursor, GitHub Copilot, and Gemini CLI through `AGENTS.md` | Many tools | 30+ agents | Many hosts through plugins | Claude Code first; Codex native; others in beta |
| Runtime needed to install | None beyond Bash or PowerShell and Git | Node.js, Homebrew, or a single binary | Node.js 20+ | The host's plugin manager | Node.js (`npx`) or the Claude Code plugin manager |
| Removal | Project `--uninstall` restores files; plugin uninstall | — | `ruler revert` | Plugin uninstall | Guided uninstall |

A dash means the README does not describe the feature; it does not mean the
project cannot do it.

## When to choose which

- **You already have good rules and just need them in every tool:** a
  rule-sync tool such as rulesync or Ruler is the most direct fit. It
  supports more tools and more file types, such as MCP and ignore files.
- **You want a strict, opinionated development methodology inside one main
  host:** Superpowers or Everything Claude Code go deeper, with
  automatic skill triggering, hooks, memory, and large skill libraries.
- **You want a ready-made, reviewable policy that makes agents plan, wait for
  explicit approval, and report what they verified, and you want it identical
  across Claude Code, Codex, Antigravity, and your repository:** use Full Stack
  HQ. It is small enough to read in one sitting, has no Node.js dependency,
  and every renderer and installer runs in CI on Windows and Ubuntu.

These options are not exclusive. Full Stack HQ's `core/rules/common.md` is plain
Markdown, so a team can also feed it into a rule-sync tool.

## What Full Stack HQ deliberately does not do

- It is not a sandbox. Rules are instructions; the host still enforces
  permissions.
- It does not install hooks that block tool calls. The approval gate is
  instruction-level, which keeps it portable across hosts.
- It does not manage MCP servers, model selection, or API keys.
