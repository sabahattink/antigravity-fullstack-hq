---
name: systematic-debugging
description: Debugging methodology, hypothesis testing, reading stack traces, isolating issues. Use when facing an unexpected bug, a flaky test, a production incident, or any situation where the cause isn't immediately obvious.
---

# Systematic Debugging

## The Scientific Method Applied to Bugs

```
1. OBSERVE   — Reproduce the issue reliably
2. HYPOTHESIZE — Form the simplest explanation consistent with symptoms
3. PREDICT   — "If my hypothesis is correct, then X should be true"
4. TEST      — Run an experiment to falsify the hypothesis
5. CONCLUDE  — If wrong, refine hypothesis and repeat
```

Never jump to a fix before you understand the cause. A fix without understanding is guessing.

## Step 1: Reproduce Reliably

You cannot debug a bug you cannot reproduce.

```bash
# Note the exact conditions:
# - Input / request body
# - Environment (local / staging / prod)
# - User account or data state
# - Frequency (always / sometimes / once)
# - When it started (after which deploy?)

# Find the last good commit
git bisect start
git bisect bad HEAD
git bisect good v1.2.3   # last known good tag
# git bisect then checks out midpoints — test and mark good/bad
```

## Step 2: Read the Stack Trace

```
Error: Cannot read properties of undefined (reading 'email')
    at UserService.findOneOrFail (/src/users/users.service.ts:42:23)
    at UsersController.findOne (/src/users/users.controller.ts:28:31)
    at ...

Reading strategy:
1. Top line: the actual error — read it carefully word by word
2. First frame after your code: where it crashed (users.service.ts:42)
3. Frame above that: what called it (users.controller.ts:28)
4. Ignore node_modules frames unless diagnosing a library issue
```

```typescript
// users.service.ts line 42 — the crash site
async findOneOrFail(id: number): Promise<User> {
  const user = await this.repo.findById(id)
  // line 42: user is undefined, not null — we expected null
  return user  // accessing .email somewhere downstream fails
}

// Fix: repo.findOne returns undefined when not found, but our types say null
// The contract mismatch is the root cause, not the downstream access
```

## Step 3: Isolate the Problem

Binary search through the call stack to find where the invariant breaks.

```typescript
// Add strategic logging — not everywhere, but at the boundary
async findOneOrFail(id: number): Promise<User> {
  console.log('[DEBUG] findOneOrFail called with', { id, type: typeof id })
  const user = await this.repo.findById(id)
  console.log('[DEBUG] repo returned', { user, type: user === null ? 'null' : typeof user })
  // ...
}

// Now you know: is `id` the wrong value, or does the repo return unexpected type?
```

```bash
# Isolate environment issues
NODE_ENV=production node -e "require('./dist/main')"  # test prod build locally

# Isolate database issues — run the query directly
psql $DATABASE_URL -c "SELECT * FROM users WHERE id = 42;"

# Isolate network issues
curl -v -H "Authorization: Bearer $TOKEN" http://localhost:3000/api/v1/users/42
```

## Common Bug Patterns

### Async/Await Mistakes
```typescript
// BUG: missing await — returns Promise, not value
async function getBadge(userId: string) {
  const user = this.repo.findById(userId)  // ← missing await
  return user.role === 'admin' ? 'admin' : 'user'  // TypeError: user.role undefined
}

// BUG: forEach with async — fires and forgets
async function notifyAll(userIds: string[]) {
  userIds.forEach(async id => {  // ← async inside forEach is a trap
    await this.emailService.send(id)
  })
  // returns before any emails sent!
}

// FIX: use Promise.all or for...of
async function notifyAll(userIds: string[]) {
  await Promise.all(userIds.map(id => this.emailService.send(id)))
  // OR (sequential):
  for (const id of userIds) {
    await this.emailService.send(id)
  }
}
```

### Stale Closure
```typescript
// BUG: stale closure captures old value
function Timer() {
  const [count, setCount] = useState(0)

  useEffect(() => {
    const id = setInterval(() => {
      setCount(count + 1)  // ← count is always 0 in this closure
    }, 1000)
    return () => clearInterval(id)
  }, [])  // ← empty deps — count never updates in closure

  // FIX: use functional update
  useEffect(() => {
    const id = setInterval(() => {
      setCount(c => c + 1)  // ← always uses latest value
    }, 1000)
    return () => clearInterval(id)
  }, [])
}
```

### Race Condition
```typescript
// BUG: two concurrent requests overwrite each other
async function incrementViews(postId: string) {
  const post = await db.posts.findOne(postId)
  post.views++
  await db.posts.save(post)  // request B may have read same value
}

// FIX: atomic update
async function incrementViews(postId: string) {
  await db.posts.increment({ id: postId }, 'views', 1)
  // or: UPDATE posts SET views = views + 1 WHERE id = $1
}
```

### TypeScript Lies
```typescript
// Type assertions hide runtime issues
const user = result as User  // if result is null, this silently succeeds
user.email  // CRASHES at runtime

// Safe pattern: validate at runtime
function assertIsUser(value: unknown): asserts value is User {
  if (!value || typeof value !== 'object' || !('email' in value)) {
    throw new Error(`Expected User, got: ${JSON.stringify(value)}`)
  }
}

// Or use Zod/io-ts at system boundaries
const UserSchema = z.object({ id: z.number(), email: z.string().email() })
const user = UserSchema.parse(apiResponse)  // throws with clear message if wrong
```

## Debugging Tools

### Node.js Inspector
```bash
# Start with inspector
node --inspect-brk dist/main.js

# Attach VS Code debugger (launch.json)
{
  "type": "node",
  "request": "attach",
  "name": "Attach to Process",
  "processId": "${command:PickProcess}",
  "sourceMaps": true,
  "outFiles": ["${workspaceFolder}/dist/**/*.js"]
}
```

### VS Code launch.json for NestJS
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug NestJS",
      "program": "${workspaceFolder}/src/main.ts",
      "preLaunchTask": "tsc: build",
      "outFiles": ["${workspaceFolder}/dist/**/*.js"],
      "sourceMaps": true,
      "envFile": "${workspaceFolder}/.env.local"
    },
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Tests",
      "program": "${workspaceFolder}/node_modules/vitest/vitest.mjs",
      "args": ["run", "--reporter=verbose"],
      "sourceMaps": true
    }
  ]
}
```

### Database Query Debugging
```typescript
// TypeORM: enable query logging in dev
TypeOrmModule.forRoot({
  logging: process.env.NODE_ENV === 'development' ? ['query', 'error'] : ['error'],
})

// Log specific query with explain
const result = await this.dataSource.query(`
  EXPLAIN ANALYZE
  SELECT * FROM users WHERE email = $1
`, ['jane@example.com'])
console.log(result)
```

## Debugging Checklist

```
□ Can I reproduce it? (if not, gather more info first)
□ Did it ever work? (if yes, git bisect to find regression)
□ What changed recently? (last deploy, config, data migration)
□ What do the logs say? (search by request ID or user ID)
□ Is it environment-specific? (only prod? only with certain data?)
□ What does the stack trace say? (first line, first your-code frame)
□ What is the actual vs expected value at the crash site?
□ Is it a type mismatch? null vs undefined? string vs number?
□ Is it a timing issue? (async, race condition, timeout)
□ Is it an environment issue? (env vars, secrets, config)
```

## Production Incident Playbook

```
1. TRIAGE (< 5 min)
   - Identify affected users/scope
   - Is data at risk? → escalate immediately
   - Can we roll back? → do it if yes and impact is high

2. INVESTIGATE (keep timeline)
   - Pull logs: kubectl logs / CloudWatch / Datadog
   - Find first error occurrence: git log + deploy history
   - Identify causal commit or config change

3. MITIGATE
   - Rollback deploy if a commit caused it
   - Feature flag off if available
   - Scale up if load-related

4. FIX
   - Write a failing test that reproduces the bug
   - Fix it
   - Deploy hotfix

5. POSTMORTEM
   - Timeline of events
   - Root cause (not "human error" — what systemic issue enabled it?)
   - Action items with owners and due dates
```

## Forbidden Patterns

- Never change multiple things at once while debugging — you won't know what fixed it
- Never "fix" a bug by catching and suppressing the error
- Never assume the bug is in someone else's code before verifying
- Never debug production by adding `console.log` to prod builds — use structured logging
- Never close an investigation with "it works now" without understanding why
- Never skip writing a regression test after fixing a bug
