# Full Stack HQ

Opinionated AI engineering workflow and configuration for Google Antigravity and Claude Code.

Full Stack HQ packages global rules, specialist agents, reusable skills, and workflow files for controlled, planned, and reviewable engineering work. It is a configuration and documentation repository—not a SaaS product, generic AI platform, agent runtime, or application framework.

> The permission model is implemented as instructions in `GEMINI.md` and `CLAUDE.md`. It is not a runtime sandbox or hard enforcement layer; behavior still depends on the host agent applying the installed instructions.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)

## What is included

| Component | Count | Role |
|-----------|:-----:|------|
| Global rules | 2 | Host-specific instructions in `GEMINI.md` and `CLAUDE.md` |
| Agents | 10 | Specialist role definitions |
| Skills | 28 | Reusable domain guidance modules |
| Workflows | 10 | Antigravity workflow files |

The maintained integration surfaces are Google Antigravity and Claude Code. The default installers install the rules, agents, and skills for both; workflow files are installed for Antigravity.

## Workflow model

The included rules describe a permission-aware engineering workflow:

1. Plan the work and identify the relevant specialist.
2. Present the scope, assumptions, and proposed changes.
3. Wait for explicit approval before executing the approved slice.
4. Report what changed, what was verified, and what remains.

The configured approval phrases are:

```text
PLAN APPROVED
IMPLEMENTATION APPROVED
PROCEED
DO IT
```

These phrases are part of the installed prompt/configuration guidance. They do not intercept shell commands, enforce filesystem permissions, or guarantee host-agent behavior.

## Installation

The installers copy files from the cloned repository, so run them from a local checkout.

### macOS / Linux

```bash
git clone https://github.com/sabahattink/antigravity-fullstack-hq.git
cd antigravity-fullstack-hq
chmod +x install.sh
./install.sh
```

Available options:

| Option | Effect |
|--------|--------|
| `--only-antigravity` | Install only the Antigravity files |
| `--only-claude` | Install only the Claude Code files |
| `--force` | Skip the prompt for existing global rules files |

### Windows (PowerShell)

```powershell
git clone https://github.com/sabahattink/antigravity-fullstack-hq.git
Set-Location antigravity-fullstack-hq
.\install.ps1
```

Available switches:

| Switch | Effect |
|--------|--------|
| `-OnlyAntigravity` | Install only the Antigravity files |
| `-OnlyClaude` | Install only the Claude Code files |
| `-Force` | Skip the prompt for existing global rules files |

The scripts target the following locations:

```text
Antigravity
  ~/.gemini/GEMINI.md
  ~/.gemini/antigravity/agents/
  ~/.gemini/antigravity/skills/
  ~/.gemini/antigravity/workflows/

Claude Code
  ~/.claude/CLAUDE.md
  ~/.claude/agents/
  ~/.claude/skills/
```

Restart the host application after installation so it reloads the global files.

The current scripts prompt only for existing `GEMINI.md` or `CLAUDE.md`; same-named agent, skill, and workflow files are copied into their target directories.

## Technology defaults

The included guidance is opinionated around common full-stack engineering work:

- Web: Next.js, React, TypeScript, and Tailwind CSS
- Services and data: NestJS, Node.js, PostgreSQL, and Prisma
- Delivery and verification: Vitest, Jest, Playwright, Docker, and GitHub Actions

These are documentation defaults and examples, not dependencies installed by this repository. Edit the installed `~/.claude/CLAUDE.md` or `~/.gemini/GEMINI.md` when a project uses different conventions.

## Agents

| Agent | Focus |
|-------|-------|
| `frontend-specialist` | React, Next.js, Tailwind, and UI/UX |
| `backend-specialist` | NestJS, APIs, queues, and Redis |
| `database-specialist` | Prisma, PostgreSQL, and migrations |
| `architect` | System design, ADRs, and trade-offs |
| `code-reviewer` | Quality, patterns, and security |
| `test-engineer` | Vitest, Jest, and Playwright |
| `security-auditor` | Auth, OWASP, and input validation |
| `devops-engineer` | Docker, CI/CD, and deployment |
| `performance-optimizer` | Bundles, queries, and rendering |
| `documentation-writer` | Technical writing, READMEs, and ADRs |

## Skills

The 28 skills are grouped by purpose:

| Area | Skills |
|------|--------|
| Frontend | `react-best-practices`, `typescript-patterns`, `tailwind-patterns`, `frontend-design`, `web-design-guidelines`, `nextjs-app-router` |
| Backend | `nestjs-patterns`, `backend-dev-guidelines`, `software-architecture`, `api-design-patterns`, `prisma-workflow` |
| Testing | `test-driven-development`, `systematic-debugging`, `webapp-testing` |
| DevOps | `docker-patterns`, `github-actions`, `deployment-guide` |
| Auth and security | `auth-patterns`, `security-checklist` |
| Documents | `docx-official`, `pdf-official`, `pptx-official`, `xlsx-official` |
| Meta | `brainstorming`, `skill-creator`, `code-review-patterns`, `git-workflow`, `prompt-engineering` |

## Workflows

The 10 workflow files are installed under `~/.gemini/antigravity/workflows/`:

| Command | Use |
|---------|-----|
| `/plan` | Break work into phases before implementation |
| `/brainstorm` | Explore options and trade-offs |
| `/debug` | Work through a systematic root-cause analysis |
| `/create` | Implement an approved plan |
| `/enhance` | Improve existing code quality |
| `/test` | Generate or fix tests |
| `/status` | Record progress, blockers, and next steps |
| `/preview` | Review quality, security, and commit readiness |
| `/orchestrate` | Coordinate specialist workstreams |
| `/ui-ux-pro-max` | Run a structured UI/UX review |

Claude Code receives `CLAUDE.md`, the agents, and the skills from the installers; it does not receive these workflow files.

## Documentation

- [Setup guide](docs/SETUP.md)
- [Customization guide](docs/CUSTOMIZATION.md)
- [Contributing guide](docs/CONTRIBUTING.md)

## Contributing

Please read [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) before opening a pull request. Changes should remain focused on the configuration, workflow guidance, skills, agents, and documentation in this repository.

## License

MIT License. Maintained by [Sabahattin Kalkan](https://github.com/sabahattink).
