---
title: Full Stack HQ: A Permission-First AI Engineering Stack for Claude Code, Antigravity, and Codex
tags: claudecode, codex, antigravity, devtools
cover_image: https://raw.githubusercontent.com/sabahattink/antigravity-fullstack-hq/main/docs/assets/hero-terminal.png
---

![Full Stack HQ terminal preview](https://raw.githubusercontent.com/sabahattink/antigravity-fullstack-hq/main/docs/assets/hero-terminal.png)

AI coding agents can move quickly. The engineering challenge is keeping intent,
approval, and verification visible while they do.

That is the problem Full Stack HQ is designed to address: a shared,
permission-first engineering workflow that can travel across multiple AI
coding hosts.

The project supports Claude Code, Google Antigravity IDE, and OpenAI Codex from
one tool-agnostic source of truth.

For plugin-aware OpenAI hosts, the root `plugin.json` and the existing
canonical `skills/` directory also form a portable package boundary. The host
installers remain available when you need global rules, native agents, and
generated adapter files.

![Full Stack HQ source-to-host architecture](https://raw.githubusercontent.com/sabahattink/antigravity-fullstack-hq/main/docs/assets/architecture.png)

---

## The core problem with AI coding agents

Most people configure their AI agent once (or never) and just... let it go. The result is an agent that:

- Makes assumptions about what you want
- Takes irreversible actions without asking
- Mixes planning and execution in the same step
- Has no consistent code style or architectural awareness

The agent is powerful but unpredictable. That's the worst combination in software development.

---

## The solution: permission-first workflow

The installed rules are designed to make the agent plan, show what it intends to do, and request explicit approval before execution.

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

The only valid approval keywords:

```
PLAN APPROVED
IMPLEMENTATION APPROVED
PROCEED
DO IT
```

The rules define these as the approval phrases. They are prompt/configuration guidance, not a runtime permission boundary, so the host agent still determines the observed behavior.

![Full Stack HQ permission-first workflow loop](https://raw.githubusercontent.com/sabahattink/antigravity-fullstack-hq/main/docs/assets/workflow-loop.png)

---

## What's inside Full Stack HQ

| Component | Count | Description |
|-----------|:-----:|-------------|
| Shared rule core | 1 | Host-neutral engineering policy |
| Host adapters | 3 | Claude Code, Antigravity, and Codex |
| `CLAUDE.md` / `GEMINI.md` / `AGENTS.md` | 3 | Generated host instruction files |
| `plugin.json` | 1 | Portable package manifest for canonical skills |
| Agents | 10 | Specialist AI personas |
| Skills | 28 | Domain-specific knowledge modules |
| Workflows | 10 | Legacy workflows plus skill bridges |

### 10 Specialist Agents

Instead of one generic agent trying to do everything, you get domain experts:

| Agent | What it handles |
|-------|----------------|
| `frontend-specialist` | React, Next.js, Tailwind |
| `backend-specialist` | NestJS, Node.js, APIs |
| `database-specialist` | Prisma, PostgreSQL, migrations |
| `architect` | System design, trade-offs, ADRs |
| `code-reviewer` | Quality, patterns, best practices |
| `test-engineer` | Vitest, Jest, Playwright |
| `security-auditor` | Auth, OWASP, input validation |
| `performance-optimizer` | Bundle, queries, rendering |
| `devops-engineer` | Docker, CI/CD |
| `documentation-writer` | READMEs, technical writing |

Calling them is simple:

```
Use the database-specialist to design a user schema with soft deletes.
```

### 28 Skills

Deep knowledge modules for the tools you actually use:

- **Frontend**: `nextjs-app-router`, `react-best-practices`, `ui-ux-pro-max`, `frontend-design`
- **Backend**: `nestjs-patterns`, `prisma-workflow`, `software-architecture`
- **Testing**: `test-driven-development`, `systematic-debugging`, `webapp-testing`
- **Meta**: `brainstorming`, `prompt-engineering`, `skill-creator`

### 10 Workflows (Cross-host procedures)

```
/plan       → phased breakdown with approval checkpoints
/brainstorm → explore architecture options
/debug      → systematic root-cause analysis
/create     → implement an approved plan
/enhance    → improve existing code quality
/test       → generate or fix tests
/orchestrate → coordinate multiple agents
/ui-ux-pro-max → structured UI/UX review
```

The canonical workflow bodies remain in `workflows/`. The installer keeps the
Antigravity legacy form and also renders each one as a skill for Claude Code,
Codex, and modern Antigravity.

---

## Installation

The installers copy files from the cloned repository and should be run from that checkout.

**Mac/Linux:**

```bash
git clone https://github.com/sabahattink/antigravity-fullstack-hq.git
cd antigravity-fullstack-hq
chmod +x install.sh
./install.sh
```

**Windows (PowerShell):**

```powershell
git clone https://github.com/sabahattink/antigravity-fullstack-hq.git
Set-Location antigravity-fullstack-hq
.\install.ps1
```

**Options:**

```bash
./install.sh --only-claude        # Claude Code only
./install.sh --only-antigravity   # Antigravity only
./install.sh --only-codex         # OpenAI Codex only
./install.sh --dry-run            # Preview without writing targets
./install.sh --force --backup     # Replace managed files with backups
```

The scripts perform pre-flight checks and install the selected host files.

---

## What gets installed where

```
~/.claude/
├── CLAUDE.md          ← global rules (Claude Code)
├── agents/            ← 10 specialist agents
└── skills/            ← 28 skill modules

~/.gemini/
├── GEMINI.md          ← global rules (Antigravity)
└── config/
    ├── agents/
    ├── skills/
    └── workflows/     ← legacy bridge

~/.codex/
├── AGENTS.md          ← global rules (Codex)
└── agents/            ← TOML custom agents

~/.agents/skills/      ← shared Codex skills
```

---

## The shared rule-core philosophy

The shared rules describe several things I found critical in practice:

**1. Separation of planning and execution**

The rules separate planning from execution: the agent should plan, request approval, then execute the approved slice.

**2. Role-based reasoning**

Before acting, the agent asks: "Who is the right specialist for this?" A database schema question goes to the database specialist, not the frontend agent pretending to know Prisma.

**3. Explicit code style**

No semicolons. Single quotes. 2-space indentation. Arrow functions. Named exports. These are documented defaults that the host agent is asked to follow.

**4. Security checklist**

Before every commit, the rules include a checklist for hardcoded secrets, input validation, bounded queries, and rate limiting. The checklist is guidance for the host agent, not an automatic scanner.

---

## Why it works

The mental model I was missing: **AI agents should behave like senior engineers, not interns with root access.**

Senior engineers don't start typing when you describe a problem. They think, propose a plan, get sign-off, then execute — one reversible step at a time.

Full Stack HQ encodes this discipline in its global rules and workflow files.

---

## Repo

⭐ [github.com/sabahattink/antigravity-fullstack-hq](https://github.com/sabahattink/antigravity-fullstack-hq)

MIT license. Open to PRs — especially new agents and skills.

What does your current shared agent configuration look like? I'd love to see
what rules others have found valuable across their preferred hosts.
