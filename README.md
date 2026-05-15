<div align="center">

# Full Stack HQ

### The most opinionated AI coding configuration for serious engineers.

**Works with Google Antigravity IDE and Claude Code — out of the box.**

<br/>

[![Release](https://img.shields.io/github/v/release/sabahattink/antigravity-fullstack-hq?style=flat-square&color=orange&label=Release)](https://github.com/sabahattink/antigravity-fullstack-hq/releases)
[![Stars](https://img.shields.io/github/stars/sabahattink/antigravity-fullstack-hq?style=flat-square&color=gold&label=Stars)](https://github.com/sabahattink/antigravity-fullstack-hq/stargazers)
[![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen?style=flat-square)](http://makeapullrequest.com)
[![Last Commit](https://img.shields.io/github/last-commit/sabahattink/antigravity-fullstack-hq?style=flat-square&color=purple)](https://github.com/sabahattink/antigravity-fullstack-hq/commits)

<br/>

| ![Antigravity](https://img.shields.io/badge/Google%20Antigravity-4285F4?style=for-the-badge&logo=google&logoColor=white) | ![Claude Code](https://img.shields.io/badge/Claude%20Code-CC785C?style=for-the-badge&logo=anthropic&logoColor=white) |
|:---:|:---:|
| `GEMINI.md` + full agent stack | `CLAUDE.md` + full agent stack |

</div>

---

## The Problem

AI coding agents are powerful — but without guardrails, they become unpredictable. They create files without asking. They make assumptions. They break things mid-session.

**Full Stack HQ solves this.**

Install once. Your agent becomes a disciplined senior engineer who:

- ✅ Always plans before acting
- ✅ Uses the right specialist for each task
- ✅ Knows your full tech stack deeply
- ✅ Never surprises you with unexpected changes
- ✅ Writes consistent, production-grade code every time

---

## What's Inside

<table>
<tr>
<td width="50%">

**`GEMINI.md`** — Global rules for Antigravity
- Permission-first workflow
- Tech stack defaults
- Code style enforcement
- Git conventions

</td>
<td width="50%">

**`CLAUDE.md`** — Global rules for Claude Code
- Same philosophy, Claude-native syntax
- Agent role definitions
- Slash command workflows
- Security checklist

</td>
</tr>
</table>

| Component | Count | What it does |
|-----------|:-----:|--------------|
| **Agents** | 10 | Specialist AI personas for each domain |
| **Skills** | 28 | Deep knowledge modules (Next.js, NestJS, Prisma...) |
| **Workflows** | 10 | Slash commands for your dev loop |

---

## Install in 30 Seconds

<details open>
<summary><b>Mac / Linux</b></summary>

```bash
curl -fsSL https://raw.githubusercontent.com/sabahattink/antigravity-fullstack-hq/main/install.sh | bash
```

```bash
# Or clone for more control
git clone https://github.com/sabahattink/antigravity-fullstack-hq.git
cd antigravity-fullstack-hq
./install.sh
```

| Flag | Effect |
|------|--------|
| `--only-antigravity` | Skip Claude Code |
| `--only-claude` | Skip Antigravity |
| `--force` | Overwrite existing configs |

</details>

<details>
<summary><b>Windows (PowerShell)</b></summary>

```powershell
irm https://raw.githubusercontent.com/sabahattink/antigravity-fullstack-hq/main/install.ps1 | iex
```

```powershell
# Or with options
.\install.ps1 -OnlyClaude
.\install.ps1 -OnlyAntigravity
.\install.ps1 -Force
```

</details>

After install, restart your IDE. That's it.

---

## The Permission-First Workflow

Every action requires your explicit approval. The agent plans, shows you what it intends to do, and **waits**.

```
You:    "Add user authentication with JWT"

Agent:  Here's my plan:
        Phase 1: Create auth module + JWT strategy
        Phase 2: Add guards to protected routes
        Phase 3: Implement refresh token rotation

        [APPROVAL NEEDED] Should I proceed with Phase 1?

You:    PLAN APPROVED

Agent:  [implements Phase 1 only, then stops and reports]
```

**Valid approval keywords:**
```
PLAN APPROVED  ·  IMPLEMENTATION APPROVED  ·  PROCEED  ·  DO IT
```

Anything else = the agent waits.

---

## Tech Stack

Full Stack HQ is tuned for modern production stacks:

```
Frontend     Next.js 15 (App Router)  ·  TypeScript 5  ·  Tailwind CSS v4
Backend      NestJS  ·  Node.js 22+  ·  BullMQ  ·  Redis
Database     PostgreSQL 16+  ·  Prisma 6+
Auth         JWT with refresh token rotation
Testing      Vitest  ·  Jest  ·  Playwright
Infra        Docker  ·  GitHub Actions  ·  Vercel
```

> Not using this stack? Edit `~/.claude/CLAUDE.md` or `~/.gemini/GEMINI.md` to swap any technology.

---

## Agents

<details>
<summary>View all 10 agents</summary>

| Agent | Trigger phrase | Specialty |
|-------|---------------|-----------|
| `frontend-specialist` | `Use the frontend-specialist to...` | React, Next.js, Tailwind, UI/UX |
| `backend-specialist` | `Use the backend-specialist to...` | NestJS, APIs, queues, Redis |
| `database-specialist` | `Use the database-specialist to...` | Prisma, PostgreSQL, migrations |
| `architect` | `Use the architect to...` | System design, ADRs, trade-offs |
| `code-reviewer` | `Use the code-reviewer to...` | Quality, patterns, security |
| `test-engineer` | `Use the test-engineer to...` | Vitest, Jest, Playwright |
| `security-auditor` | `Use the security-auditor to...` | Auth, OWASP, input validation |
| `devops-engineer` | `Use the devops-engineer to...` | Docker, CI/CD, deployment |
| `performance-optimizer` | `Use the performance-optimizer to...` | Bundle, queries, rendering |
| `documentation-writer` | `Use the documentation-writer to...` | Technical writing, READMEs, ADRs |

</details>

---

## Skills

<details>
<summary>View all 28 skills</summary>

| Category | Skills |
|----------|--------|
| **Frontend** | `react-best-practices` `typescript-patterns` `tailwind-patterns` `frontend-design` `web-design-guidelines` `nextjs-app-router` |
| **Backend** | `nestjs-patterns` `backend-dev-guidelines` `software-architecture` `api-design-patterns` `prisma-workflow` |
| **Testing** | `test-driven-development` `systematic-debugging` `webapp-testing` |
| **DevOps** | `docker-patterns` `github-actions` `deployment-guide` |
| **Auth & Security** | `auth-patterns` `security-checklist` |
| **Documents** | `docx-official` `pdf-official` `pptx-official` `xlsx-official` |
| **Meta** | `brainstorming` `skill-creator` `code-review-patterns` `git-workflow` `prompt-engineering` |

</details>

---

## Workflows

| Command | When to use |
|---------|------------|
| `/plan` | Before starting any feature — produces a phased breakdown |
| `/brainstorm` | Exploring architecture options before committing |
| `/debug` | Systematic root-cause analysis on bugs |
| `/create` | Implementing an approved plan |
| `/enhance` | Improving existing code quality |
| `/test` | Generating or fixing tests |
| `/status` | Progress checkpoint on long tasks |
| `/preview` | Pre-commit review — quality, security, commit draft |
| `/orchestrate` | Multi-agent task coordination |
| `/ui-ux-pro-max` | Deep UI/UX audit with 10 visual style directions |

---

## What Gets Installed

```
~/.gemini/
├── GEMINI.md                     ← global rules for Antigravity
└── antigravity/
    ├── agents/                   ← 10 specialist agents
    ├── skills/                   ← 28 skill modules
    └── workflows/                ← 10 workflow files

~/.claude/
├── CLAUDE.md                     ← global rules for Claude Code
├── agents/                       ← 10 specialist agents
└── skills/                       ← 28 skill modules
```

---

## IDE Support

| Feature | Antigravity | Claude Code |
|---------|:-----------:|:-----------:|
| Global rules file | ✅ `GEMINI.md` | ✅ `CLAUDE.md` |
| Specialist agents | ✅ | ✅ |
| Skills / modules | ✅ | ✅ |
| Slash workflows | ✅ | ✅ |
| Hooks system | ❌ | ✅ |
| MCP servers | ❌ | ✅ |
| Plan mode | ❌ | ✅ |

---

## Contributing

Want to add a skill, improve an agent, or fix a workflow? PRs are very welcome.

```bash
git clone https://github.com/sabahattink/antigravity-fullstack-hq.git
cd antigravity-fullstack-hq

# Add a new skill
mkdir skills/your-skill-name
cat > skills/your-skill-name/SKILL.md << 'EOF'
---
name: your-skill-name
description: What this skill covers. Use when [trigger condition].
---

# Your Skill Title

## Section
Content here...
EOF

git checkout -b feat/add-your-skill-name
```

Please read [CONTRIBUTING.md](docs/CONTRIBUTING.md) before opening a PR.

---

## Credits

Built with inspiration from the community:

- [vudovn/antigravity-kit](https://github.com/vudovn/antigravity-kit)
- [sickn33/antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills)
- Vercel Labs official skills
- Anthropic official skills

---

<div align="center">

**[⭐ Star this repo](https://github.com/sabahattink/antigravity-fullstack-hq) · [Report a bug](https://github.com/sabahattink/antigravity-fullstack-hq/issues) · [Request a feature](https://github.com/sabahattink/antigravity-fullstack-hq/issues)**

<br/>

MIT License · Made by [Scuton Technology](https://github.com/scuton-technology)

</div>
