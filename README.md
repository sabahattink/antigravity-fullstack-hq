# Full Stack HQ

> The most opinionated AI coding configuration for serious full-stack engineers.
> Works with **Google Antigravity IDE** and **Claude Code** — out of the box.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Stars](https://img.shields.io/github/stars/sabahattink/antigravity-fullstack-hq?style=social)](https://github.com/sabahattink/antigravity-fullstack-hq/stargazers)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

<table>
<tr>
<td align="center"><img src="https://img.shields.io/badge/Google%20Antigravity-4285F4?style=for-the-badge&logo=google&logoColor=white" /></td>
<td align="center"><img src="https://img.shields.io/badge/Claude%20Code-CC785C?style=for-the-badge&logo=anthropic&logoColor=white" /></td>
</tr>
</table>

---

## What is Full Stack HQ?

A battle-tested configuration kit that turns your AI coding agent into a **disciplined engineering team**.

Install it once. Your agent will:
- Always ask before acting — no surprises
- Use the right specialist for each task
- Follow your code style automatically
- Know your full stack deeply (Next.js, NestJS, Prisma, TypeScript)
- Enforce conventional commits and branch strategy

| Component | Count | Description |
|-----------|-------|-------------|
| **GEMINI.md / CLAUDE.md** | 2 | Global rules — one per IDE |
| **Agents** | 10 | Specialist AI personas |
| **Skills** | 28 | Domain-specific knowledge modules |
| **Workflows** | 10 | Slash command procedures |

---

## Quick Install

### Mac / Linux

```bash
# Install for both Antigravity + Claude Code
curl -fsSL https://raw.githubusercontent.com/sabahattink/antigravity-fullstack-hq/main/install.sh | bash

# Or clone and run
git clone https://github.com/sabahattink/antigravity-fullstack-hq.git
cd antigravity-fullstack-hq
./install.sh
```

**Options:**
```bash
./install.sh --only-antigravity   # Antigravity only
./install.sh --only-claude        # Claude Code only
./install.sh --force              # Overwrite existing configs
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/sabahattink/antigravity-fullstack-hq/main/install.ps1 | iex
```

**Options:**
```powershell
.\install.ps1 -OnlyAntigravity
.\install.ps1 -OnlyClaude
.\install.ps1 -Force
```

---

## The Core Philosophy

### Permission-First Workflow

Your agent will **never** execute commands, create files, or make changes without explicit approval:

```
PLAN APPROVED        ← approve the plan
IMPLEMENTATION APPROVED  ← approve the code
PROCEED              ← short form
DO IT                ← short form
```

Any variation = **NOT approved**. The agent waits.

### Thinking Before Acting

Before writing a single line of code, the agent asks:

1. **Who** is the right specialist? (architect? frontend? database?)
2. **What** is the minimal, reversible change?
3. **How** does this fit the existing architecture?
4. **Why** is this the right approach?

---

## Tech Stack

Optimized for production-grade full-stack development:

| Layer | Technology |
|-------|-----------|
| Frontend | Next.js 15+ (App Router), TypeScript 5+, Tailwind CSS v4 |
| Backend | NestJS, Node.js 22+, BullMQ, Redis |
| Database | PostgreSQL 16+, Prisma 6+ |
| Auth | JWT with refresh token rotation |
| Testing | Vitest, Jest, Playwright |
| Infra | Docker, GitHub Actions, Vercel |

---

## Agents (10)

| Agent | Expertise |
|-------|-----------|
| `frontend-specialist` | React, Next.js, UI/UX, Tailwind |
| `backend-specialist` | NestJS, APIs, queues, cache |
| `database-specialist` | Prisma, PostgreSQL, migrations |
| `architect` | System design, technical trade-offs |
| `code-reviewer` | Quality, patterns, security |
| `test-engineer` | Vitest, Jest, Playwright |
| `security-auditor` | Auth, input validation, OWASP |
| `devops-engineer` | Docker, CI/CD, infrastructure |
| `performance-optimizer` | Bundle, queries, rendering |
| `documentation-writer` | Technical writing, ADRs |

**Usage:**
```
Use the database-specialist to design a user schema with soft deletes.
```

---

## Skills (28)

**Frontend** — react-best-practices, nextjs-app-router, frontend-design, ui-ux-pro-max, web-design-guidelines, and more

**Backend** — nestjs-patterns, backend-dev-guidelines, prisma-workflow, software-architecture

**Testing** — test-driven-development, systematic-debugging, webapp-testing

**Documents** — docx-official, pdf-official, pptx-official, xlsx-official

**Meta** — prompt-engineering, skill-creator, brainstorming

---

## Workflows (10)

| Command | Description |
|---------|-------------|
| `/plan` | Break a feature into approved phases |
| `/brainstorm` | Explore architecture options |
| `/debug` | Systematic root-cause analysis |
| `/create` | Implement an approved plan |
| `/enhance` | Improve existing code quality |
| `/test` | Generate or fix tests |
| `/status` | Progress checkpoint |
| `/preview` | Review before committing |
| `/orchestrate` | Multi-agent task coordination |
| `/ui-ux-pro-max` | Design with 50+ visual styles |

---

## What's Installed Where

```
~/.gemini/
├── GEMINI.md                    ← global rules (Antigravity)
└── antigravity/
    ├── agents/                  ← 10 specialist agents
    ├── skills/                  ← 28 skill modules
    └── workflows/               ← 10 workflows

~/.claude/
├── CLAUDE.md                    ← global rules (Claude Code)
├── agents/                      ← 10 specialist agents
└── skills/                      ← 28 skill modules
```

---

## IDE Comparison

| Feature | Antigravity | Claude Code |
|---------|-------------|-------------|
| Global rules | `GEMINI.md` | `CLAUDE.md` |
| Agents | ✅ | ✅ |
| Skills | ✅ | ✅ |
| Workflows | ✅ | ✅ (slash commands) |
| Hooks | ❌ | ✅ |
| MCP servers | ❌ | ✅ |

---

## Customization

After installing, edit your global rules file:

```bash
# Antigravity
code ~/.gemini/GEMINI.md

# Claude Code
code ~/.claude/CLAUDE.md
```

Key things to customize:
- **Approval keywords** — change trigger phrases
- **Tech stack defaults** — swap Next.js for Nuxt, NestJS for Fastify, etc.
- **Code style** — semicolons, quotes, indentation
- **Forbidden patterns** — add project-specific rules

---

## Credits

Built with inspiration from:
- [vudovn/antigravity-kit](https://github.com/vudovn/antigravity-kit)
- [sickn33/antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills)
- Vercel Labs official skills
- Anthropic official skills

---

## Contributing

Found a bug or want to add a skill? PRs are welcome.

1. Fork the repo
2. Add your skill/agent/workflow
3. Update the install scripts if needed
4. Open a PR with a clear description

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for details.

---

## License

MIT — see [LICENSE](LICENSE)
