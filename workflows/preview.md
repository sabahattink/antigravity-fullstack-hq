---
name: preview
description: Pre-commit review workflow — check changes, verify no regressions, confirm code is ready to commit or push.
trigger: /preview
---

# Preview Workflow

## Purpose

Use `/preview` before committing or opening a PR to catch issues before they reach review. This is a structured self-review that ensures:
- No accidental files are staged
- Tests pass
- No debug artifacts left in code
- The change is coherent and well-described
- Security checklist passes

## Steps

### 1. Review What's Changed
```bash
# See all modified files
git status

# Review unstaged changes
git diff

# Review staged changes
git diff --staged

# See what's changed vs main
git diff main...HEAD --stat
git log --oneline main..HEAD
```

**Check each file for:**
- Is this file intentionally changed?
- Are `.env` files accidentally staged?
- Any generated or build artifacts (`.next/`, `dist/`, `coverage/`)?

### 2. Code Quality Scan

Read through each changed file and verify:

```
□ No console.log, console.debug, or debugger statements
□ No TODO/FIXME comments without an issue number
□ No hardcoded credentials, API keys, or tokens
□ No commented-out blocks of code
□ All new functions have typed parameters and return types
□ No `any` type used as a shortcut
□ Imports are clean (no unused imports)
```

### 3. Test Verification

```bash
# Run all tests
pnpm test

# Run only tests related to changed files (faster)
pnpm test -- --changed

# Verify coverage hasn't dropped
pnpm test:cov
```

**Verify:**
```
□ All tests pass (no red)
□ Coverage >= 80% for changed modules
□ No tests marked `.skip` that weren't skipped before
□ New code has tests
```

### 4. Build & Type Check

```bash
pnpm run type-check
pnpm run lint
pnpm run build
```

```
□ TypeScript: 0 errors
□ Lint: 0 errors (warnings OK if pre-existing)
□ Build: successful
```

### 5. Security Quick-Check

```
□ No hardcoded secrets (grep for: password, secret, api_key, token)
□ New endpoints have authentication guards
□ User input is validated (DTOs with class-validator)
□ No raw SQL strings with user input
□ File uploads validate MIME type
```

### 6. Write the Commit Message

Draft before committing to ensure it's meaningful:

```
feat(auth): add JWT refresh token rotation

Rotates the refresh token on each use to prevent token reuse attacks.
Old refresh token is invalidated when a new one is issued.

Fixes #87
```

**Commit message checklist:**
```
□ Type prefix: feat / fix / refactor / test / docs / chore
□ Scope in parentheses: (auth) / (users) / (api)
□ Description is present-tense, imperative mood ("add", not "added")
□ Body explains WHY if not obvious
□ Issue reference if applicable (Fixes #XX)
```

### 7. PR Description Draft (if opening a PR)

```markdown
## What
[What does this change do?]

## Why
[Why is it needed? Link to issue.]

## How
[Approach taken — any non-obvious decisions?]

## Testing
- [ ] Unit tests added
- [ ] Tested locally
- [ ] Migration tested (if applicable)

## Breaking Changes
[None / list them]
```

## Output

```markdown
## Preview Results

### Changed Files
- src/auth/auth.service.ts ✓
- src/auth/strategies/jwt-refresh.strategy.ts ✓ (new file)
- src/auth/auth.service.spec.ts ✓

### Staging Area
- All files are intentional
- No accidental env files or build artifacts

### Tests
- 18 passing, 0 failing
- Coverage: 86% (was 84%)

### Build
- TypeScript: clean
- Lint: clean
- Build: OK

### Security
- No hardcoded secrets found
- New endpoints have JwtAuthGuard
- Input validation present on all DTOs

### Commit Ready
Yes — commit message drafted:
`feat(auth): add JWT refresh token rotation`

### Notes
- src/auth/auth.module.ts has an unused import warning — fixed
```

## Checklist

```
□ git diff reviewed — no surprises
□ No debug/console statements
□ No hardcoded credentials
□ Tests pass, coverage maintained
□ TypeScript and lint clean
□ Build succeeds
□ Commit message drafted
□ PR description drafted (if needed)
```
