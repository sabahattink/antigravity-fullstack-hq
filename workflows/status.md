---
name: status
description: Progress checkpoint workflow — summarize current state, blockers, and next steps for the active development session.
trigger: /status
---

# Status Workflow

## Purpose

Use `/status` to get a clear, structured summary of where you are in a development session. Ideal for:
- Resuming work after a break
- Handing off to another developer
- Daily standup preparation
- Checking in mid-feature to recalibrate

## Steps

1. **Identify current work**
   - What branch are you on? (`git branch --show-current`)
   - What files have been modified? (`git status`, `git diff --stat`)
   - How many commits since branching from main? (`git log --oneline main..HEAD`)

2. **Assess test state**
   - Are tests passing? (`pnpm test`)
   - Coverage at or above 80%?
   - Any skipped or failing tests?

3. **Check build health**
   - Does it compile? (`pnpm run build`)
   - Any TypeScript errors? (`pnpm run type-check`)
   - Any lint errors? (`pnpm run lint`)

4. **Review the task list**
   - Which TodoWrite items are complete?
   - Which are in progress?
   - Which are blocked and why?

5. **Identify blockers**
   - Missing information (API contract, design decision, external data)
   - Technical uncertainty (not sure how to implement X)
   - Dependency on another team or PR

6. **Define next steps**
   - The single most important thing to do next
   - Estimated time to completion
   - Anything that needs a decision before proceeding

## Output

```markdown
## Status Report — [feature/branch-name]

### Completed
- [x] Created UsersRepository with TypeORM
- [x] Added CreateUserDto with validation
- [x] Unit tests for UserService.create (4 tests, all passing)

### In Progress
- [ ] Integration test for email uniqueness check (50% done)
- [ ] Auth guard integration — waiting on JWT strategy review

### Blocked
- [ ] Cannot implement refresh token rotation until JWT_REFRESH_SECRET is added to Railway env
  - Action needed: DevOps to add secret to staging environment

### Next Steps
1. Finish integration test (est. 30 min)
2. Wire up refresh endpoint once secret is available
3. PR review: tag @teammate

### Build State
- Tests: 12 passing, 0 failing
- Coverage: 83%
- TypeScript: clean
- Lint: 1 warning (unused import in auth.module.ts)

### ETA
Feature branch ready for PR review: ~2 hours
```

## Checklist

```
□ Branch name and commit count noted
□ All modified files scanned for obvious issues
□ Tests run and result captured
□ Coverage number noted
□ Build/compile status verified
□ Blockers clearly stated with who can unblock
□ Next action is single, concrete, and actionable
□ Time estimate given
```
