---
title: I built a permission-first CLAUDE.md + agent stack for Claude Code (free, MIT)
tags: claudecode, ai, devtools, productivity
---

I've been using Claude Code daily for months. And I kept hitting the same wall:

The agent would just **start doing things**. No plan. No approval. Just... acting.

It deleted files I didn't want deleted. It refactored things I didn't ask it to refactor. It made "helpful" assumptions that broke my architecture.

So I built **Full Stack HQ** — a configuration kit that encodes a permission-first workflow. Here's what I learned.

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

---

## What's inside Full Stack HQ

| Component | Count | Description |
|-----------|:-----:|-------------|
| `CLAUDE.md` | 1 | Global rules for Claude Code |
| `GEMINI.md` | 1 | Global rules for Google Antigravity IDE |
| Agents | 10 | Specialist AI personas |
| Skills | 28 | Domain-specific knowledge modules |
| Workflows | 10 | Antigravity workflow files |

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

### 10 Workflows (Antigravity Commands)

```
/plan       → phased breakdown with approval checkpoints
/brainstorm → explore architecture options
/debug      → systematic root-cause analysis
/create     → implement an approved plan
/enhance    → improve existing code quality
/test       → generate or fix tests
/orchestrate → coordinate multiple agents
```

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
./install.sh --force              # Skip the global-rules overwrite prompt
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
└── antigravity/
    ├── agents/
    ├── skills/
    └── workflows/
```

---

## The CLAUDE.md philosophy

The rules file describes several things I found critical in practice:

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

What does your current CLAUDE.md look like? I'd love to see what rules others have found valuable.
