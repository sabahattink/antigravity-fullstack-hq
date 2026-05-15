# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-05-15

### Added — Claude Code Support
- `claude/CLAUDE.md` — 12-section permission-first global rules for Claude Code
  - Permission-first workflow with explicit approval keywords
  - 10 agent role definitions
  - Full tech stack defaults (Next.js 15, NestJS, Prisma 6+, TypeScript 5+)
  - Code style enforcement (no semicolons, single quotes, 2 spaces)
  - Git conventions (Conventional Commits)
  - Testing philosophy (Vitest, Jest, Playwright)
  - Security checklist
  - Claude Code workflow commands

### Added — Skills (24 new, total 28)
- `react-best-practices` — Component patterns, hooks, memoization, error boundaries
- `typescript-patterns` — Generics, utility types, discriminated unions, type guards
- `tailwind-patterns` — Tailwind CSS v4, button variants, dark mode, design tokens
- `frontend-design` — Component design principles, visual hierarchy, spacing systems
- `web-design-guidelines` — WCAG 2.1 accessibility, semantic HTML, Core Web Vitals
- `backend-dev-guidelines` — NestJS layering, error handling, structured logging
- `software-architecture` — Clean Architecture, SOLID, domain modeling, CQRS
- `api-design-patterns` — REST conventions, response envelopes, pagination, OpenAPI
- `test-driven-development` — Red-Green-Refactor, Vitest setup, mock factories
- `systematic-debugging` — Scientific method, stack traces, production playbook
- `webapp-testing` — Playwright POM, React Testing Library, MSW mocking
- `docker-patterns` — Multi-stage Dockerfiles, docker-compose dev/prod
- `github-actions` — CI pipeline, E2E testing, deploy workflows
- `deployment-guide` — Vercel + Railway/Fly.io, health checks, zero-downtime
- `auth-patterns` — JWT access/refresh tokens, Passport.js, httpOnly cookies
- `security-checklist` — OWASP Top 10, rate limiting, audit logging, CORS
- `docx-official` — Word document generation with docx library
- `pdf-official` — PDF generation with PDFKit and Puppeteer
- `pptx-official` — PowerPoint generation with pptxgenjs
- `xlsx-official` — Excel generation with ExcelJS
- `brainstorming` — Six Hats, RICE prioritization, ADR template, trade-off matrix
- `skill-creator` — How to create new skills — format, frontmatter, quality checklist
- `code-review-patterns` — P0-P3 severity, comment writing, PR review flow
- `git-workflow` — GitHub Flow, conventional commits, conflict resolution

### Added — Workflows (4 new, total 10)
- `/status` — Progress checkpoint, current state, blockers, next steps
- `/preview` — Pre-commit review, quality check, security scan, commit draft
- `/orchestrate` — Multi-agent coordination, parallel streams, handoff tracking
- `/ui-ux-pro-max` — Visual audit, 10 style directions, accessibility, interactions

### Updated — Install Scripts
- `install.sh` — Added `--only-claude` and `--only-antigravity` flags
- `install.ps1` — Added `-OnlyClaude` and `-OnlyAntigravity` switches
- Auto-detects installed IDEs and configures accordingly

### Updated — README
- Professional redesign with dual IDE presentation
- Collapsible install sections (Mac/Linux + Windows)
- Real conversation example demonstrating permission-first workflow
- Agents table with trigger phrases
- IDE feature comparison table

---

## [0.1.0] - 2026-01-20

### Added — Initial Release
- `gemini/GEMINI.md` — Permission-first global rules for Antigravity IDE
- 10 specialist agents: frontend, backend, database, architect, code-reviewer, test-engineer, security-auditor, devops-engineer, performance-optimizer, documentation-writer
- 4 skills: nestjs-patterns, prisma-workflow, nextjs-app-router, prompt-engineering
- 6 workflows: /brainstorm, /plan, /debug, /create, /enhance, /test
- Install scripts for Mac/Linux and Windows
- Docs: Setup guide, Customization guide, Contributing guide
