---
name: code-review-patterns
description: Code review checklist, what to look for, how to give feedback, PR review flow. Use when reviewing a pull request, or when preparing code for review.
---

# Code Review Patterns

## The Goal of Code Review

Code review is NOT about finding mistakes to win arguments. It is about:
1. **Correctness** — Does the code do what it's supposed to do?
2. **Safety** — Are there security or data integrity risks?
3. **Clarity** — Will the next developer understand this in 6 months?
4. **Consistency** — Does this follow the established patterns in the codebase?

## What to Look For — Priority Order

### P0 — Block (must fix before merge)
```
□ Security vulnerability (SQL injection, XSS, auth bypass, hardcoded secrets)
□ Data loss risk (wrong delete scope, missing transaction, no backup)
□ Correctness bug (wrong logic, off-by-one, race condition)
□ Broken tests or test coverage dropped below 80%
□ Deployment risk (migration without rollback, breaking API change)
```

### P1 — Should Fix
```
□ Missing error handling (silent catch, swallowed exception)
□ N+1 query problem
□ Function over 50 lines (extract responsibility)
□ File over 800 lines (extract module)
□ Nesting depth > 4 (use early returns)
□ Missing input validation on public endpoints
□ console.log / debug statements left in
□ TODO comments without tracking issue
```

### P2 — Consider Fixing
```
□ Naming: unclear variable/function names
□ Missing comments on non-obvious logic
□ Magic numbers (use named constants)
□ Duplicate code (extract utility)
□ Missing type annotations
```

### P3 — Optional / Style
```
□ Formatting inconsistency (should be caught by linter/prettier)
□ Minor naming preferences
□ Ordering of exports
```

## How to Write Review Comments

### Be specific and constructive

```
# Bad comment
"This is wrong."

# Good comment
"This will fail when `user` is null (e.g., when the token is valid but
the user account was deleted). Consider throwing `UnauthorizedException`
here rather than proceeding: `if (!user) throw new UnauthorizedException()`"
```

### Distinguish opinion from requirement

Use prefixes to signal severity:
```
[BLOCK]   — Must fix before merge (security, correctness)
[SHOULD]  — Strong recommendation, technical debt if skipped
[NIT]     — Minor, only fix if easy — don't hold up the PR
[IDEA]    — Thought worth considering, not a request
[QUESTION]— Genuine question, not criticism
```

### Examples by category

```typescript
// [BLOCK] SQL injection risk — user input is directly interpolated
// Change to: db.query('SELECT * FROM users WHERE email = $1', [email])
const result = await db.query(`SELECT * FROM users WHERE email = '${email}'`)

// [SHOULD] Missing await — this returns a Promise<void>, not void.
// The function returns before the email is sent.
emailService.send(user.email, 'Welcome!')

// [NIT] Could simplify with optional chaining:
// return user?.profile?.avatar ?? null
if (user && user.profile && user.profile.avatar) {
  return user.profile.avatar
}
return null

// [IDEA] Consider using a discriminated union here instead of nullable
// fields — it makes the state machine explicit at compile time.

// [QUESTION] Is this intentionally public? Seems like an admin-only action.
@Get('all-users')
findAllUsers() { ... }
```

## PR Checklist for the Author

Before requesting review:
```
□ Self-review the diff — read your own code as if reviewing someone else's
□ All tests pass (npm test / pnpm test)
□ No lint errors (npm run lint)
□ Type check passes (npm run type-check)
□ No debug statements or commented-out code
□ PR description explains WHY, not just WHAT
□ Related issues linked
□ Screenshots for UI changes
□ Breaking changes documented
□ Migration scripts tested locally
```

## PR Description Template

```markdown
## What
[One paragraph: what does this change do?]

## Why
[Why is this change needed? Link to issue if applicable.]

## How
[Brief explanation of the approach taken.]

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Tested locally against real data

## Screenshots
[For UI changes — before/after]

## Breaking Changes
[List any breaking API changes, DB schema changes, or env var changes]
```

## Reviewing Large PRs

For PRs with 500+ lines changed:

```
1. Read the PR description first — understand the intent
2. Start with tests — they document expected behavior
3. Read the new interfaces/types — they reveal the design
4. Read the service/business logic — the core of the change
5. Read the controllers/handlers — boundary validation
6. Check the migrations last — easy to miss side effects
```

## Common Code Smells to Flag

### The God Object
```typescript
// Bad: UsersService does everything
class UsersService {
  createUser() {}
  sendEmail() {}
  generateReport() {}
  processPayment() {}
  updateInventory() {}
}

// Flag it: "This service has too many responsibilities.
// Consider extracting EmailService, ReportService, PaymentService."
```

### Boolean Traps
```typescript
// Bad: what do the booleans mean?
createUser(name, email, true, false, true)

// Flag it: "[SHOULD] These boolean arguments are opaque.
// Consider an options object: createUser(name, email, { isAdmin: true, sendWelcome: false, isVerified: true })"
```

### Premature Optimization
```typescript
// Flag with [IDEA]:
// "This optimization adds complexity. Do we have a measured performance
// problem here? If not, let's keep the simple version and optimize when needed."
```

## Approval Criteria

| Finding | Action |
|---------|--------|
| Any P0 | Block — request changes |
| P1 items | Comment with [SHOULD], can approve with conditions |
| Only P2/P3 | Approve — note as optional suggestions |
| No issues | Approve immediately — don't delay |

## Forbidden Patterns

- Never write vague comments like "This could be better" — always explain how
- Never block a PR for style issues that should be caught by the linter
- Never make the author feel attacked — critique the code, not the person
- Never approve without reading — a rubber-stamp approval provides false confidence
- Never let PRs sit unreviewed for more than 24 hours — slow reviews demoralize teams
- Never request changes without explaining what change is needed
- Never re-review already-addressed comments — trust the author and move forward
