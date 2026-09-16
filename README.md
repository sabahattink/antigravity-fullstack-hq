# Full Stack HQ

A tool-agnostic, permission-first AI engineering configuration kit for Google
Antigravity IDE, Claude Code, and OpenAI Codex.

Full Stack HQ packages shared engineering rules, specialist agents, reusable
skills, workflow bridges, and safe installers. It is a configuration and
documentation repository—not a SaaS product, agent runtime, application
framework, or hard security boundary.

> The permission model is instruction-level guidance. The host still controls
> actual tools, approvals, sandboxing, network access, and filesystem behavior.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)

## What is included

| Component | Count | Role |
|-----------|:-----:|------|
| Shared rule core | 1 | Host-neutral engineering policy |
| Host adapters | 3 | Claude Code, Antigravity, and Codex integration layers |
| Agents | 10 | Specialist role definitions |
| Skills | 28 | Reusable domain guidance modules |
| Workflows | 10 | Canonical workflows plus generated skill bridges |
| Validators | 2 | PowerShell and Bash source/adapter checks |

The existing top-level agents/, skills/, and workflows/ directories remain the
public source layout. This keeps existing customizations and links usable while
adding a proper adapter seam.

## Architecture

    core/rules/common.md
            │
            ├── adapters/claude/rules.md       ──► ~/.claude/CLAUDE.md
            ├── adapters/antigravity/rules.md  ──► ~/.gemini/GEMINI.md
            └── adapters/codex/rules.md        ──► ~/.codex/AGENTS.md

    agents/*.md ──────────────────────────────► Claude / Antigravity native agents
                 └────────────────────────────► Codex .toml custom agents

    skills/*/SKILL.md ────────────────────────► all three hosts
    workflows/*.md ───────────────────────────► Antigravity legacy workflows
                 └────────────────────────────► workflow skills for all hosts

The core is the deep module: callers learn one stable engineering policy and
each host adapter carries only the details that genuinely vary. The renderer
keeps generated files synchronized:

    scripts/build-adapters.ps1
    scripts/build-adapters.sh

Generated output is temporary by default. To refresh the compatibility
snapshots in claude/CLAUDE.md and gemini/GEMINI.md, run:

    PowerShell: .\scripts\build-adapters.ps1 -SyncSnapshots
    Bash:       bash scripts/build-adapters.sh --sync-snapshots

## Native host mapping

| Capability | Google Antigravity IDE | Claude Code | OpenAI Codex |
|---|---|---|---|
| Global rules | ~/.gemini/GEMINI.md | ~/.claude/CLAUDE.md | ~/.codex/AGENTS.md |
| Agents | ~/.gemini/config/agents/ | ~/.claude/agents/ | ~/.codex/agents/*.toml |
| Skills | ~/.gemini/config/skills/ | ~/.claude/skills/ | ~/.agents/skills/ |
| Workflows | ~/.gemini/config/workflows/ (legacy bridge) | Generated skills | Generated skills |
| Project-local guidance | .agents/ | .claude/ / CLAUDE.md | AGENTS.md, .codex/, .agents/ |

The Codex adapter follows its current native formats: AGENTS.md for layered
instructions, Agent Skills for reusable workflows, and TOML custom agents with
name, description, and developer_instructions.

- Codex AGENTS.md: https://learn.chatgpt.com/docs/agent-configuration/agents-md
- Codex skills: https://learn.chatgpt.com/docs/build-skills
- Codex custom agents: https://learn.chatgpt.com/docs/agent-configuration/subagents
- Claude Code skills: https://code.claude.com/docs/en/skills
- Antigravity rules and workflows: https://antigravity.google/docs/rules-workflows

## Workflow model

The shared rules describe a controlled engineering workflow:

1. Inspect the real state and identify the relevant specialist.
2. Present scope, assumptions, risk, and the proposed change.
3. Wait for explicit approval before executing the approved slice.
4. Verify the result and report changed, failed, and unverified checks.

The configured approval phrases are:

    PLAN APPROVED
    IMPLEMENTATION APPROVED
    PROCEED
    DO IT

These phrases are prompt/configuration guidance. They do not intercept shell
commands or guarantee host-agent behavior.

## Installation

Run installers from a local checkout; they do not install runtimes or packages.

### macOS / Linux

    git clone https://github.com/sabahattink/antigravity-fullstack-hq.git
    cd antigravity-fullstack-hq
    bash install.sh

### Windows PowerShell

    git clone https://github.com/sabahattink/antigravity-fullstack-hq.git
    Set-Location antigravity-fullstack-hq
    .\install.ps1

By default, all three integrations are prepared. Existing global instruction
files are confirmed interactively. Existing agent and skill files are kept
unless --force / -Force is provided.

Useful options:

| PowerShell | Bash | Effect |
|---|---|---|
| -OnlyAntigravity | --only-antigravity | Antigravity only |
| -OnlyClaude | --only-claude | Claude Code only |
| -OnlyCodex | --only-codex | Codex only |
| -Force | --force | Replace managed files without prompts |
| -Backup | --backup | Back up files replaced by the installer |
| -DryRun | --dry-run | Preview changes without writing targets |
| -TargetRoot DIR | --target-root DIR | Install into an isolated home-like directory for testing |
| -NoLegacyPaths | --no-legacy-paths | Do not refresh an existing Antigravity legacy tree |
| -Check | --check | Validate source and adapter generation |

For an upgrade, the recommended safe command is:

    PowerShell: .\install.ps1 -Force -Backup
    Bash:       bash install.sh --force --backup

Restart each host application and start a new conversation after installation.

### Antigravity compatibility

Current Antigravity global agents and skills are installed under
~/.gemini/config/. If an older Full Stack HQ installation already has
~/.gemini/antigravity/, the installer refreshes its matching files as a
compatibility bridge unless -NoLegacyPaths / --no-legacy-paths is selected.
No legacy tree is created for a new installation.

### Codex scope

Codex user skills are installed under ~/.agents/skills/; custom agents and
global instructions use the active Codex home, normally ~/.codex/. If CODEX_HOME
is set, the installer uses that directory for AGENTS.md and custom agents while
keeping user skills in ~/.agents/skills/.

If ~/.codex/AGENTS.override.md exists, Codex prioritizes it over AGENTS.md.
The installer warns about this and leaves the override untouched; merge any
desired local policy there deliberately.

There is intentionally no separate Codex workflow directory. The canonical
workflow bodies are converted to skills because skills are the current
shareable workflow format.

## Verification

Validate the repository before installing:

    PowerShell: .\scripts\validate.ps1
    Bash:       bash scripts/validate.sh

Preview an upgrade without touching the user's home:

    PowerShell: .\install.ps1 -DryRun
    Bash:       bash install.sh --dry-run

Then test each host with a small, reversible prompt such as:

    Create a React component called UserCard

The expected behavior is that the agent states scope, requests approval, and
reports verification. This is an instruction-level expectation, not a runtime
permission guarantee.

## Agents

| Agent | Focus |
|-------|-------|
| frontend-specialist | React, Next.js, Tailwind, and UI/UX |
| backend-specialist | NestJS, APIs, queues, and Redis |
| database-specialist | Prisma, PostgreSQL, and migrations |
| architect | System design, ADRs, and trade-offs |
| code-reviewer | Quality, patterns, and security |
| test-engineer | Vitest, Jest, and Playwright |
| security-auditor | Auth, OWASP, and input validation |
| devops-engineer | Docker, CI/CD, and deployment |
| performance-optimizer | Bundles, queries, and rendering |
| documentation-writer | Technical writing, READMEs, and ADRs |

## Skills

The 28 canonical skills are grouped by purpose:

| Area | Skills |
|------|--------|
| Frontend | react-best-practices, typescript-patterns, tailwind-patterns, frontend-design, web-design-guidelines, nextjs-app-router |
| Backend | nestjs-patterns, backend-dev-guidelines, software-architecture, api-design-patterns, prisma-workflow |
| Testing | test-driven-development, systematic-debugging, webapp-testing |
| DevOps | docker-patterns, github-actions, deployment-guide |
| Auth and security | auth-patterns, security-checklist |
| Documents | docx-official, pdf-official, pptx-official, xlsx-official |
| Meta | brainstorming, skill-creator, code-review-patterns, git-workflow, prompt-engineering |

## Workflows

The 10 canonical workflows remain in workflows/ for Antigravity's legacy
workflow loader. The installer also generates them as skills so the same
procedures are available through the native selector on Claude Code, Codex, and
modern Antigravity:

| Name | Purpose |
|------|---------|
| /plan / $plan | Break work into phases and approval checkpoints |
| /brainstorm / $brainstorm | Explore options before implementation |
| /create / $create | Implement an approved plan |
| /debug / $debug | Perform systematic root-cause analysis |
| /enhance / $enhance | Improve existing code quality |
| /test / $test | Design or improve meaningful tests |
| /status / $status | Record progress, blockers, and next steps |
| /preview / $preview | Review quality, security, and readiness |
| /orchestrate / $orchestrate | Coordinate specialist workstreams |
| /ui-ux-pro-max / $ui-ux-pro-max | Run a structured UI/UX review |

The exact invocation is host-native: Antigravity and Claude commonly expose
slash commands, while Codex exposes skill selection and $skill-name
invocation.

## Documentation

- Setup guide: docs/SETUP.md
- Customization guide: docs/CUSTOMIZATION.md
- Contributing guide: docs/CONTRIBUTING.md
- Core and adapter design: core/README.md

## Contributing

Please read docs/CONTRIBUTING.md before opening a pull request. Changes should
remain focused on the core, adapters, installers, validators, skills, agents,
workflows, and documentation.

## License

MIT License. Maintained by Sabahattin Kalkan:
https://github.com/sabahattink
