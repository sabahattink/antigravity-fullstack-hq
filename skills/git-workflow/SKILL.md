---
name: git-workflow
description: Git branching strategy, commit messages, PR workflow, conflict resolution. Use when setting up a branching strategy, writing commit messages, creating pull requests, or resolving merge conflicts.
---

# Git Workflow

## Branching Strategy (GitHub Flow)

```
main          ← production-ready at all times
  └── feature/add-user-export      ← feature branches (short-lived)
  └── fix/login-rate-limit         ← bug fix branches
  └── chore/upgrade-dependencies   ← maintenance
  └── refactor/extract-auth-module ← refactoring
```

**Rules:**
- `main` is protected — no direct pushes
- Every change goes through a PR
- PRs require at least 1 approval
- CI must pass before merge
- Branches are deleted after merge

## Branch Naming

```bash
# Pattern: <type>/<short-description>
feature/user-profile-page
feature/export-orders-xlsx
fix/refresh-token-cookie-samesite
fix/n-plus-one-users-query
chore/update-nestjs-10
refactor/extract-payment-service
docs/add-api-endpoints-readme
test/add-auth-integration-tests
release/v2.1.0

# DO NOT use:
johns-branch              # ← no name, no context
fix1                      # ← too vague
JIRA-1234                 # ← jira IDs alone mean nothing
wip                       # ← push to a real branch when ready
```

## Commit Messages

```
<type>(<scope>): <short description>

<optional body — wrap at 72 chars>

<optional footer: BREAKING CHANGE or fixes #issue>
```

**Types:**
```
feat     — new feature
fix      — bug fix
refactor — code change that neither fixes a bug nor adds a feature
perf     — performance improvement
test     — adding or correcting tests
docs     — documentation only
chore    — build process, tooling, dependencies
ci       — CI/CD config changes
```

**Examples:**
```bash
# Good
git commit -m "feat(auth): add JWT refresh token rotation"
git commit -m "fix(users): prevent email enumeration on login"
git commit -m "refactor(orders): extract payment processing to dedicated service"
git commit -m "perf(queries): add index on orders.user_id column"
git commit -m "test(auth): add integration tests for token expiry flow"

# With body
git commit -m "fix(uploads): reject files larger than 5MB

Previously the file size limit was only enforced on the frontend.
An attacker could bypass this by posting directly to the API.
Added multer limits and a guard to enforce 5MB server-side.

Fixes #142"

# Bad
git commit -m "fix bug"        # ← no context
git commit -m "WIP"            # ← push to a real WIP branch
git commit -m "asdfgh"         # ← meaningless
git commit -m "changes"        # ← what changes?
```

## Creating a PR

```bash
# 1. Create branch from main
git checkout main
git pull origin main
git checkout -b feature/user-export

# 2. Make changes, commit incrementally
git add src/users/users.service.ts src/users/dto/export.dto.ts
git commit -m "feat(users): add CSV export endpoint"

git add src/users/users.service.spec.ts
git commit -m "test(users): add unit tests for CSV export"

# 3. Push and create PR
git push -u origin feature/user-export
gh pr create \
  --title "feat(users): add CSV export endpoint" \
  --body "$(cat <<'EOF'
## What
Adds a new endpoint GET /users/export.csv that returns all users as CSV.

## Why
Requested by ops team for bulk user management workflows. Fixes #89.

## Testing
- [ ] Unit tests added (users.service.spec.ts)
- [ ] Tested locally with 10k users
- [ ] Response headers verified in browser download

## Breaking Changes
None — new endpoint only.
EOF
)"
```

## Keeping Your Branch Updated

```bash
# Rebase onto main (preferred — keeps history linear)
git fetch origin
git rebase origin/main

# If conflicts:
# 1. Open conflicted files, resolve
# 2. git add <resolved-files>
# 3. git rebase --continue
# If in trouble: git rebase --abort

# Merge main into branch (alternative — creates merge commit)
git merge origin/main
```

## Resolving Merge Conflicts

```bash
# See what's conflicting
git status

# Open in VS Code
code .

# After resolving, mark as done
git add src/users/users.service.ts

# Continue rebase
git rebase --continue
# OR complete merge commit
git commit
```

**Conflict marker anatomy:**
```typescript
<<<<<<< HEAD (your branch)
function getUserById(id: string) {
  return this.repo.findOne({ where: { id } })
=======
async function getUserById(id: number) {
  return this.repo.findOne({ where: { id }, relations: ['profile'] })
>>>>>>> origin/main

// Resolve: pick the right version or combine both intentions
async function getUserById(id: string) {
  return this.repo.findOne({ where: { id }, relations: ['profile'] })
}
```

## Git Commands Reference

```bash
# Status
git status
git diff                    # unstaged changes
git diff --staged           # staged changes
git log --oneline -10       # last 10 commits
git log --graph --oneline   # visual branch tree

# Staging
git add <file>              # stage specific file
git add -p                  # interactive staging — review hunks
git reset HEAD <file>       # unstage

# Commits
git commit -m "message"
git commit --amend          # edit last commit (NOT if already pushed)

# Branches
git branch                  # list local branches
git branch -d feature/done  # delete merged branch
git checkout -              # switch to previous branch
git stash                   # stash work in progress
git stash pop               # restore stash

# Remote
git fetch origin            # download without merging
git push -u origin branch   # push and track
git push --force-with-lease # safer force push (fails if remote was updated)

# Undo
git restore <file>          # discard unstaged changes
git reset --soft HEAD~1     # undo last commit, keep staged
git reset --mixed HEAD~1    # undo last commit, unstage
git revert HEAD             # create a new commit that undoes HEAD
```

## Tagging Releases

```bash
# Create annotated tag
git tag -a v1.2.0 -m "Release v1.2.0 — adds user export feature"

# Push tags
git push origin --tags

# GitHub release from tag
gh release create v1.2.0 \
  --title "v1.2.0 — User Export" \
  --notes "$(cat CHANGELOG.md)" \
  --target main
```

## .gitignore Essentials

```gitignore
# Node
node_modules/
dist/
build/
.next/

# Env files
.env
.env.local
.env.*.local
!.env.example     # keep example file

# IDE
.vscode/settings.json
.idea/
*.iml

# OS
.DS_Store
Thumbs.db

# Logs
*.log
npm-debug.log*
pnpm-debug.log*

# Test artifacts
coverage/
playwright-report/
test-results/

# Generated
*.d.ts.map
```

## Forbidden Patterns

- Never push directly to `main` — always go through a PR
- Never force push to `main` or shared branches
- Never commit `.env` files — add them to `.gitignore` immediately
- Never use `git add .` without reviewing what's staged (`git diff --staged`)
- Never amend or rebase commits that have already been pushed to a shared branch
- Never use `--no-verify` to skip pre-commit hooks — fix the underlying issue
- Never commit generated files (dist/, .next/, coverage/) — add to .gitignore
- Never merge a PR without CI passing
