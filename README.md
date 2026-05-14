# Antigravity Full Stack HQ

> Production-ready configuration kit for [Google Antigravity IDE](https://antigravity.google) — agents, skills, workflows, and GEMINI.md for Next.js + NestJS + TypeScript + Prisma + Tailwind.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Stars](https://img.shields.io/github/stars/sabahattink/antigravity-fullstack-hq?style=social)](https://github.com/sabahattink/antigravity-fullstack-hq/stargazers)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

[English](#english) | [Türkçe](#türkçe)

---

## English

### What is This?

A complete **"Full Stack Headquarters"** for Google Antigravity IDE. Drop this into your project and your AI agent instantly becomes a disciplined, role-aware engineering team.

| Component | Count | Description |
|-----------|-------|-------------|
| **GEMINI.md** | 1 | Global rules with permission-first workflow |
| **Agents** | 10 | Specialist AI personas |
| **Skills** | 28 | Domain-specific knowledge modules |
| **Workflows** | 10 | Slash command procedures |

### Philosophy

This is a **thinking-first engineering headquarters**:

- Separates decision-making from implementation
- Enforces role-based reasoning via specialist agents
- Makes workflows explicit and repeatable
- Uses AI as an engineering amplifier, not an autopilot

Before writing code, the agent decides: **who thinks, how things are done, and in what order work happens.**

### Quick Install

#### Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/sabahattink/antigravity-fullstack-hq/main/install.ps1 | iex
```

#### Mac/Linux (Bash)
```bash
curl -fsSL https://raw.githubusercontent.com/sabahattink/antigravity-fullstack-hq/main/install.sh | bash
```

#### Manual Install
```bash
git clone https://github.com/sabahattink/antigravity-fullstack-hq.git
cd antigravity-fullstack-hq
# Windows
.\install.ps1
# Mac/Linux
./install.sh
```

### Tech Stack

Optimized for:

- **Frontend**: Next.js (App Router), React, TypeScript, Tailwind CSS
- **Backend**: NestJS, Node.js
- **Database**: PostgreSQL, Prisma ORM
- **Testing**: Vitest, Jest, Playwright

### What's Included

#### Agents (10)

| Agent | Expertise |
|-------|-----------|
| `frontend-specialist` | React, Next.js, UI/UX |
| `backend-specialist` | NestJS, Node.js, APIs |
| `database-specialist` | Prisma, PostgreSQL |
| `code-reviewer` | Code quality, PR reviews |
| `architect` | System design, trade-offs |
| `test-engineer` | Testing strategies |
| `security-auditor` | Security reviews |
| `devops-engineer` | CI/CD, infrastructure |
| `performance-optimizer` | Performance tuning |
| `documentation-writer` | Technical writing |

#### Skills (28)

**Frontend**: react-best-practices, web-design-guidelines, frontend-design, nextjs-app-router, ui-ux-pro-max, and more

**Backend**: nestjs-patterns, backend-dev-guidelines, prisma-workflow, software-architecture

**Testing**: test-driven-development, systematic-debugging, webapp-testing

**Documents**: docx-official, pdf-official, pptx-official, xlsx-official

**Meta**: prompt-engineering, skill-creator, brainstorming

#### Workflows (10)

| Command | Description |
|---------|-------------|
| `/brainstorm` | Explore ideas and options |
| `/plan` | Create task breakdown |
| `/debug` | Systematic debugging |
| `/create` | Create new features |
| `/enhance` | Improve existing code |
| `/test` | Generate tests |
| `/status` | Check project status |
| `/preview` | Preview changes |
| `/orchestrate` | Multi-agent coordination |
| `/ui-ux-pro-max` | Design with 50+ styles |

### Key Features

#### Permission-First Workflow

The agent will **never** execute commands, create files, or make changes without explicit approval:

```
PLAN APPROVED
IMPLEMENTATION APPROVED
PROCEED
DO IT
```

#### Tech Stack Awareness

The agent knows your stack and follows your conventions:
- No semicolons
- Single quotes
- 2 spaces indentation
- Conventional commits

### Customization

Edit `~/.gemini/GEMINI.md` to customize tech stack defaults, code style, git conventions, and approval keywords.

### Credits

Built with resources from:
- [vudovn/antigravity-kit](https://github.com/vudovn/antigravity-kit)
- [sickn33/antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills)
- Vercel Labs official skills
- Anthropic official skills

---

## Türkçe

### Bu Nedir?

Google Antigravity IDE için eksiksiz bir **"Full Stack Yazılım Üssü"**. Projenize ekleyin ve AI ajanınız anında disiplinli, rol-farkında bir mühendislik ekibine dönüşsün.

| Bileşen | Adet | Açıklama |
|---------|------|----------|
| **GEMINI.md** | 1 | Permission-first workflow ile global kurallar |
| **Agents** | 10 | Uzman AI personaları |
| **Skills** | 28 | Domain-spesifik bilgi modülleri |
| **Workflows** | 10 | Slash command prosedürleri |

### Hızlı Kurulum

#### Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/sabahattink/antigravity-fullstack-hq/main/install.ps1 | iex
```

#### Mac/Linux (Bash)
```bash
curl -fsSL https://raw.githubusercontent.com/sabahattink/antigravity-fullstack-hq/main/install.sh | bash
```

### Kullanım

**Agent çağırma:**
```
Use the database-specialist to design a schema for user management
```

**Workflow çağırma:**
```
/plan Create authentication system with JWT
/debug Why is my API returning 500 error
```

### Temel Özellikler

Agent açık onay almadan **asla** komut çalıştırmaz, dosya oluşturmaz veya değişiklik yapmaz:

```
PLAN APPROVED
IMPLEMENTATION APPROVED
PROCEED
DO IT
```

---

## Contributing

Contributions are welcome!

## License

MIT License — see [LICENSE](LICENSE) file.
