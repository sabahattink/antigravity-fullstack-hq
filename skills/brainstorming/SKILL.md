---
name: brainstorming
description: Structured brainstorming techniques, idea generation, trade-off analysis. Use when exploring design options, choosing between architectural approaches, generating feature ideas, or making technology decisions.
---

# Brainstorming

## When to Brainstorm vs When to Decide

**Brainstorm** when:
- Multiple valid approaches exist
- You don't yet know the constraints
- The cost of choosing wrong is high
- You want to surface blind spots

**Decide immediately** when:
- One approach is clearly better
- Time is critical and any reasonable option works
- The decision is easily reversible

## Technique 1: Six Thinking Hats

Work through each lens sequentially before converging.

```
WHITE HAT — Facts & Data
  "What do we know for certain?"
  "What data do we have? What data do we need?"
  Example: "We have 10k users. P95 response time is 2s. Database has 1M rows."

RED HAT — Gut Feelings & Emotions
  "What feels wrong about this?"
  "What are we uncomfortable with?"
  Example: "This approach feels fragile. I'm not confident in the third-party service."

BLACK HAT — Critical Thinking & Risks
  "What could go wrong?"
  "What are the weaknesses?"
  Example: "If the cache fails, we hit the DB directly and it falls over."

YELLOW HAT — Optimism & Benefits
  "What's the best-case scenario?"
  "What does success look like?"
  Example: "If this works, we reduce load by 80% and can scale without upgrading the DB."

GREEN HAT — Creativity & Alternatives
  "What else could we do?"
  "Are there completely different approaches?"
  Example: "What if we precomputed this nightly? What if we used read replicas?"

BLUE HAT — Process & Facilitation
  "What's our decision process?"
  "What do we need to decide today vs later?"
  Example: "We need to pick an approach now for sprint planning. Cache vs CDN can be decided next sprint."
```

## Technique 2: Diverge-Converge

```
DIVERGE (10 minutes — no judgment)
  Generate as many options as possible
  Crazy options are welcome — they often contain the seed of the real solution
  No evaluation, no "but", no "however"

CONVERGE (10 minutes — structured evaluation)
  Group similar options
  Apply constraints to eliminate non-starters
  Score remaining options on key criteria
  Select top 2-3 for detailed analysis
```

## Technique 3: How Might We (HMW)

Reframe problems as opportunities.

```
Problem: "Users don't complete onboarding"
HMW: "How might we make onboarding feel like progress, not work?"
HMW: "How might we surface value before asking for effort?"
HMW: "How might we let users skip steps they've done elsewhere?"

Problem: "The API is slow under load"
HMW: "How might we reduce the number of DB queries per request?"
HMW: "How might we serve cached responses for read-heavy endpoints?"
HMW: "How might we move expensive work out of the request path entirely?"
```

## Technique 4: Pre-Mortem

Imagine it's 6 months from now and the project failed spectacularly.
Work backwards to find what caused it.

```
"It's October. The launch went badly. What happened?"

Participants each write 3-5 reasons it failed:
- "We underestimated the data migration complexity"
- "The third-party auth provider had an outage on launch day"
- "The mobile app wasn't tested on Android 12"
- "We shipped without rate limiting and got scraped"

Now: address the most plausible failure modes before you start.
```

## Trade-off Analysis Matrix

```typescript
// Template for comparing options on explicit criteria

interface Option {
  name: string
  scores: Record<string, number>  // 1-5
}

interface Criterion {
  name:   string
  weight: number  // 0-1, sums to 1.0
}

function scoreOptions(options: Option[], criteria: Criterion[]): ScoredOption[] {
  return options.map(option => {
    const total = criteria.reduce((sum, criterion) => {
      const score = option.scores[criterion.name] ?? 0
      return sum + score * criterion.weight
    }, 0)
    return { ...option, total }
  }).sort((a, b) => b.total - a.total)
}

// Example: Choosing a caching strategy
const criteria: Criterion[] = [
  { name: 'Simplicity',      weight: 0.25 },
  { name: 'Performance',     weight: 0.35 },
  { name: 'Reliability',     weight: 0.25 },
  { name: 'Cost',            weight: 0.15 },
]

const options: Option[] = [
  {
    name: 'Redis (external)',
    scores: { Simplicity: 3, Performance: 5, Reliability: 4, Cost: 3 },
  },
  {
    name: 'In-memory (LRU)',
    scores: { Simplicity: 5, Performance: 5, Reliability: 2, Cost: 5 },
  },
  {
    name: 'Database query cache',
    scores: { Simplicity: 4, Performance: 3, Reliability: 5, Cost: 5 },
  },
]
```

## Architecture Decision Template

```markdown
## Problem
[One paragraph describing the problem clearly]

## Constraints
- Must integrate with existing TypeORM setup
- P95 response must be < 500ms
- Team has 3 days for implementation

## Options Considered

### Option 1: [Name]
**Description:** ...
**Pros:** ...
**Cons:** ...
**Effort:** S / M / L

### Option 2: [Name]
**Description:** ...
**Pros:** ...
**Cons:** ...
**Effort:** S / M / L

## Decision
Option X — because [one sentence reason].

## Consequences
- We gain: [positive outcome]
- We accept: [trade-off]
- We will need to revisit when: [trigger condition]
```

## Feature Prioritization: RICE

```
RICE = (Reach × Impact × Confidence) / Effort

Reach:      How many users does this affect per quarter?
Impact:     1=minimal, 2=low, 3=medium, 4=high, 5=massive
Confidence: % of how confident you are in your estimates
Effort:     Person-weeks

Feature A: (500 × 4 × 0.8) / 2  = 800
Feature B: (100 × 5 × 0.5) / 1  = 250
Feature C: (2000 × 2 × 0.9) / 5 = 720

Priority: A > C > B
```

## API Design Brainstorm Checklist

When designing a new API endpoint, ask:

```
□ Who is the primary consumer? (frontend, mobile, third-party)
□ What's the simplest URL that makes sense? (noun, not verb)
□ What does a successful response look like? (shape, status code)
□ What are the failure modes? (validation error, not found, unauthorized)
□ What are the pagination needs? (cursor, offset, none)
□ What fields should be filterable/sortable?
□ What auth level is required? (public, authenticated, admin)
□ Will this be called frequently? (rate limiting, caching strategy)
□ What changes might break clients? (versioning strategy)
□ Is there an existing similar endpoint we should be consistent with?
```

## Forbidden Patterns

- Never brainstorm for more than 25 minutes without converging — it becomes circular
- Never let the loudest voice shut down divergence — document all ideas before filtering
- Never confuse "brainstorming" with "deciding" — separate the two phases explicitly
- Never skip the trade-off analysis for architectural decisions — "it feels right" is not enough
- Never generate options without also defining the evaluation criteria
