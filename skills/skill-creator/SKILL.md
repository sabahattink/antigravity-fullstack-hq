---
name: skill-creator
description: How to create new skills for this HQ — format, frontmatter, content structure. Use when you need to add a new skill to this repository, or when reviewing whether an existing skill is well-formed.
---

# Skill Creator

## What is a Skill?

A skill is a reference document that gives an AI agent (or a developer) deep, actionable knowledge for a specific domain. It is **not** a README, a tutorial, or a one-liner tip. It contains real patterns, real code, and clear guidance on what NOT to do.

## File Location

```
skills/
└── <skill-name>/
    └── SKILL.md
```

Skill names are lowercase, hyphenated: `api-design-patterns`, `auth-patterns`, `docker-patterns`.

## Required Structure

```markdown
---
name: skill-name
description: One-line description. Use when [specific trigger condition].
---

# Title

## [Section 1]
[Content with real code examples]

## [Section 2]
...

## Forbidden Patterns
[What NOT to do — these are as important as the positive guidance]
```

## Frontmatter Rules

```yaml
---
name: skill-name          # must match the directory name
description: >            # one line: what it does + when to trigger
  Generates Excel files with ExcelJS. Use when creating .xlsx exports
  from database data in a NestJS app.
---
```

The `description` field is what an AI uses to decide whether to load this skill. Make the trigger condition specific:

```
# Good — specific trigger
description: JWT access/refresh tokens, Passport.js strategies. Use when implementing auth in a NestJS + Next.js app.

# Bad — too vague
description: Authentication patterns. Use when building auth.
```

## Content Rules

### 1. Real code, not pseudocode
Every code block must be runnable with the imports shown. Never use `...` to hide required setup.

```typescript
// Good — complete, runnable snippet
import { Injectable } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository } from 'typeorm'
import { User } from './user.entity'

@Injectable()
export class UsersRepository {
  constructor(
    @InjectRepository(User)
    private readonly repo: Repository<User>
  ) {}

  findById(id: number) {
    return this.repo.findOne({ where: { id } })
  }
}

// Bad — too abstract
class MyRepo {
  // inject the repo here
  findById(id) { ... }
}
```

### 2. Forbidden Patterns section is mandatory
The "Forbidden Patterns" section must be the last section. List 5-10 concrete things that cause real bugs, security issues, or maintenance problems.

```markdown
## Forbidden Patterns

- Never store access tokens in localStorage — XSS can steal them
- Never use the same JWT secret for access and refresh tokens
- Never skip `@IsEmail()` validation on email fields
```

### 3. Aim for 200-400 lines
- Under 200 lines: too shallow, not useful as a reference
- Over 400 lines: likely covering too many topics, should be split

### 4. One topic per skill
Don't mix unrelated concerns. If you're writing a `testing` skill, don't include deployment. If the topic is naturally broad, split it:

```
# Too broad:
skills/backend/SKILL.md  ← covers NestJS + TypeORM + auth + caching

# Better:
skills/backend-dev-guidelines/SKILL.md   ← NestJS layering
skills/auth-patterns/SKILL.md            ← JWT + Passport
skills/docker-patterns/SKILL.md          ← Containerization
```

## Section Patterns to Follow

### Command blocks for setup
```bash
npm install exceljs
npm install -D @types/node
```

### Configuration files
Show actual config files, not fragments.

### Patterns with comparison (good vs bad)
```typescript
// Bad: explanation of why it's bad
const bad = doWrongThing()

// Good: explanation of why it's better
const good = doRightThing()
```

### Checklists for pre-flight checks
```
Production Deployment Checklist:
□ NODE_ENV=production set
□ Secrets validated at startup
□ Health checks responding
□ Rate limiting enabled
```

## Quality Checklist

Before merging a new skill:

```
□ Frontmatter has name + description
□ name matches directory name
□ Description includes "Use when [specific condition]"
□ Code examples are complete (have imports, no ellipsis hiding setup)
□ At least 3 major sections with real content
□ "Forbidden Patterns" section exists and has 5+ entries
□ 200-400 lines total
□ No tutorial prose — reference-style only
□ TypeScript/language specifics match the project stack
```

## Example: Creating a New Skill

```bash
# 1. Create the directory and file
mkdir skills/redis-patterns
touch skills/redis-patterns/SKILL.md

# 2. Write the skill following the template above

# 3. Commit
git add skills/redis-patterns/SKILL.md
git commit -m "feat: add redis-patterns skill"
```

## Forbidden Patterns

- Never write a skill that's just a list of links — content must be here, not linked
- Never use placeholders like `[your code here]` — write the actual code
- Never mix two unrelated domains in one skill — split instead
- Never skip the "Forbidden Patterns" section — negative examples are the most valuable
- Never write in tutorial style ("first you need to...") — use reference style (show the code)
- Never omit the trigger condition from the description — it's what activates the skill
