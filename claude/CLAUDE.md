# Full Stack HQ — Claude Code Rules

> Global rules for Claude Code. These rules are always active across all projects.
> Optimized for: Next.js · NestJS · TypeScript · Prisma · Tailwind CSS

---

## 1. Core Principles

### Permission-First Workflow

You are an amplifier, not an autopilot. Every action requires explicit approval.

**NEVER without approval:**
- Execute shell commands
- Create or delete files
- Modify schemas or migrations
- Install packages
- Push to remote
- Create branches

**The only valid approval keywords:**
```
PLAN APPROVED
IMPLEMENTATION APPROVED
PROCEED
DO IT
```

Any variation, implication, or partial approval = **NOT approved**.
When in doubt: *"Please confirm with PLAN APPROVED to proceed."*

### Thinking-First Engineering

Before writing a single line of code:
1. **Who** is the right specialist for this task?
2. **What** is the minimal, reversible change?
3. **How** does this fit the existing architecture?
4. **Why** is this the best approach?

Present your reasoning. Wait for approval. Then execute.

### Plan Mode Usage

For any task involving more than 2 files or 30 minutes of work:
- Enter Plan Mode automatically
- Break into phases with explicit `[APPROVAL NEEDED]` checkpoints
- Each phase must be independently reversible

---

## 2. Agent Roles

Use the appropriate specialist agent for each domain. Never use a generalist when a specialist exists.

| Agent | Trigger | Scope |
|-------|---------|-------|
| `frontend-specialist` | UI, components, pages, styles | React, Next.js, Tailwind |
| `backend-specialist` | APIs, services, controllers | NestJS, Node.js |
| `database-specialist` | Schema, migrations, queries | Prisma, PostgreSQL |
| `architect` | Cross-cutting decisions | System design, trade-offs |
| `code-reviewer` | Post-implementation review | Quality, security, patterns |
| `test-engineer` | Test strategy and implementation | Vitest, Jest, Playwright |
| `security-auditor` | Security review | Auth, input validation, secrets |
| `performance-optimizer` | Bottleneck analysis | Bundle, queries, rendering |

**Invocation pattern:**
```
Use the database-specialist to design a schema for [feature].
```

---

## 3. Tech Stack

### Frontend
- **Framework**: Next.js 15+ (App Router only — no Pages Router)
- **Language**: TypeScript 5+ (strict mode, `noUncheckedIndexedAccess: true`)
- **Styling**: Tailwind CSS v4
- **State**: React hooks → Zustand (when shared state needed)
- **Forms**: React Hook Form + Zod
- **Animation**: Framer Motion (premium projects only, opt-in)
- **Data fetching**: TanStack Query v5

### Backend
- **Primary**: NestJS with TypeScript
- **Runtime**: Node.js 22+ (LTS)
- **Validation**: class-validator + class-transformer
- **Auth**: Passport.js + JWT (access + refresh token rotation)
- **Queue**: BullMQ (Redis-backed)
- **Cache**: Redis (ioredis)

### Database
- **Primary**: PostgreSQL 16+
- **ORM**: Prisma 6+
- **Migrations**: Prisma Migrate (never manual SQL unless reviewed)
- **Search**: pgvector for vector search, pg_trgm for full-text

### Infrastructure
- **Containerization**: Docker + docker-compose
- **CI**: GitHub Actions
- **Deployment**: Vercel (frontend), Railway/Fly.io (backend)
- **Secrets**: Environment variables only — never in code

---

## 4. Code Style

### TypeScript

```typescript
// ✅ CORRECT
const getUserById = async (id: string): Promise<User | null> => {
  return db.user.findUnique({ where: { id } })
}

// ❌ WRONG — any, var, semicolons, double quotes
var getUser = async (id: any) => {
  return await db.user.findUnique({ where: { id } });
}
```

**Rules:**
- No semicolons
- Single quotes
- 2 spaces (no tabs)
- `const` over `let`, never `var`
- Arrow functions preferred
- Explicit return types on all functions
- No `any` — use `unknown` if truly dynamic
- Early returns over nested conditionals
- Barrel exports (`index.ts`) for public APIs

### React / Next.js

```tsx
// ✅ CORRECT
interface UserCardProps {
  user: User
  onSelect: (id: string) => void
}

export const UserCard = ({ user, onSelect }: UserCardProps) => {
  return (
    <button onClick={() => onSelect(user.id)}>
      {user.name}
    </button>
  )
}
```

**Rules:**
- Functional components only — no class components
- Named exports only — no default exports (except Next.js pages/layouts)
- Props interface: `{ComponentName}Props`
- `'use client'` / `'use server'` explicit on every file that needs it
- No CSS-in-JS — Tailwind only
- Colocate: `Component.tsx`, `Component.test.tsx`, `Component.stories.tsx`

### NestJS

```typescript
// ✅ Module structure
@Module({
  imports: [TypeOrmModule.forFeature([User])],
  controllers: [UserController],
  providers: [UserService, UserRepository],
  exports: [UserService],
})
export class UserModule {}
```

**Rules:**
- One module per domain feature
- Controller → Service → Repository layering (no skipping layers)
- DTOs for all request/response shapes
- Guards for auth, Interceptors for logging/transform
- Never inject repositories directly into controllers

### Prisma

```prisma
// ✅ Always explicit field types, always have createdAt/updatedAt
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

**Rules:**
- Schema changes require migration plan approval first
- Always run `prisma generate` after schema changes
- Use transactions (`$transaction`) for multi-table writes
- Never use `prisma.$queryRaw` without parameterization
- Soft deletes: add `deletedAt DateTime?` pattern

---

## 5. Git Conventions

### Commit Format (Conventional Commits)

```
type(scope): short description in imperative mood

[optional body]
[optional footer]
```

| Type | When |
|------|------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Restructure without behavior change |
| `perf` | Performance improvement |
| `test` | Tests only |
| `docs` | Documentation only |
| `chore` | Dependencies, tooling |
| `ci` | CI/CD changes |
| `style` | Formatting only |

**Examples:**
```
feat(auth): add JWT refresh token rotation
fix(api): handle null user in profile endpoint
refactor(users): extract UserRepository from UserService
```

### Branch Strategy

```
main          → production, protected, no direct push
dev           → integration branch
feature/<slug> → new features (branch from dev)
fix/<slug>     → bug fixes (branch from dev)
hotfix/<slug>  → urgent production fixes (branch from main)
```

**Agent rule**: Never create branches autonomously. Always propose and wait for approval.

---

## 6. Testing

### Frontend (Vitest + Testing Library)

```typescript
// ✅ Test behavior, not implementation
it('shows error when email is invalid', async () => {
  render(<LoginForm />)
  await userEvent.type(screen.getByLabelText('Email'), 'notanemail')
  await userEvent.click(screen.getByRole('button', { name: /login/i }))
  expect(screen.getByText(/invalid email/i)).toBeInTheDocument()
})
```

### Backend (Jest)

```typescript
// ✅ Unit test with mocked dependencies
describe('UserService.create', () => {
  it('throws ConflictException when email exists', async () => {
    mockRepo.findByEmail.mockResolvedValue(existingUser)
    await expect(service.create(dto)).rejects.toThrow(ConflictException)
  })
})
```

### E2E (Playwright)

```typescript
// ✅ Critical user paths only
test('user can complete checkout', async ({ page }) => {
  await page.goto('/cart')
  await page.getByRole('button', { name: 'Checkout' }).click()
  await expect(page.getByText('Order confirmed')).toBeVisible()
})
```

**Philosophy:**
- Test behavior, not implementation
- 80% unit/integration, 20% E2E
- No 100% coverage obsession
- Test the things that break in production

---

## 7. Security

### Mandatory Checks Before Every Commit

- [ ] No hardcoded secrets (`grep -r "api_key\|password\|secret" src/`)
- [ ] All user inputs validated (Zod / class-validator)
- [ ] SQL queries parameterized (no string interpolation)
- [ ] Auth guards on all protected routes
- [ ] Rate limiting on public endpoints
- [ ] CORS configured correctly
- [ ] Error messages don't leak stack traces

### Forbidden Patterns

```typescript
// ❌ NEVER
const query = `SELECT * FROM users WHERE id = ${userId}` // SQL injection
process.env.SECRET_KEY = 'hardcoded'                      // hardcoded secret
app.use(cors({ origin: '*' }))                            // open CORS
console.log('User password:', password)                   // log sensitive data
```

---

## 8. Error Handling Protocol

When you encounter an error:

1. **Report** — What exactly failed?
2. **Analyze** — Root cause, not surface symptom
3. **Impact** — What does this break?
4. **Options** — 2-3 solution paths with trade-offs
5. **Wait** — Which approach should I take?

**Never auto-fix. Always get approval first.**

---

## 9. Claude Code Workflow Commands

Use these slash commands throughout the development workflow:

| Command | When to Use |
|---------|-------------|
| `/plan` | Before starting any feature |
| `/brainstorm` | Exploring architecture options |
| `/debug` | Stuck on a bug |
| `/create` | Implementing approved plan |
| `/enhance` | Improving existing code |
| `/test` | Writing or fixing tests |
| `/status` | Progress checkpoint |
| `/orchestrate` | Coordinating multi-agent tasks |

---

## 10. Memory & Context

### What to Track in TodoWrite

For every multi-step task, maintain a todo list:
- Current phase and status
- Completed items (with ✅)
- Blocked items (with reason)
- Next action required

### Context Hygiene

- If a conversation exceeds 15 turns without a clear outcome → suggest `/compact` or new session
- If requirements shift mid-implementation → stop, re-plan, get approval
- If context becomes contradictory → ask for clarification, don't assume

---

## 11. Forbidden Patterns (All Languages)

```
❌ any type in TypeScript
❌ console.log in production code
❌ hardcoded secrets or API keys
❌ var keyword
❌ default exports (except Next.js pages/layouts)
❌ CSS-in-JS libraries
❌ class components in React
❌ relative imports crossing module boundaries (use path aliases)
❌ direct database access from controllers
❌ unbounded queries (always use pagination)
❌ missing error handling (never silent catch blocks)
❌ TODO comments without ticket reference
```

---

## 12. Quick Reference

| Action | Policy |
|--------|--------|
| Suggest code | ✅ Always (with reasoning) |
| Create files | ⚠️ Approval required |
| Run commands | ⚠️ Approval required |
| Delete files | ⚠️ Approval required |
| Create branches | ⚠️ Approval required |
| Install packages | ⚠️ Approval required |
| Schema migrations | ⚠️ Plan approval + implementation approval |
| Push to remote | ❌ Never autonomously |
| Deploy | ❌ Never autonomously |
| Modify CI/CD | ❌ Never autonomously |
| Access .env files | ❌ Read-only, never modify |
