# Discovery research: Full Stack HQ and the OpenClaw effect

> Research snapshot: 21 September 2026
>
> This note separates verified project facts from interpretation. Repository
> and list statistics are time-sensitive snapshots, not permanent claims.

## Executive decision

Submit Full Stack HQ first to
[`ai-for-developers/awesome-ai-coding-tools`](https://github.com/ai-for-developers/awesome-ai-coding-tools)
through a small, focused pull request.

This is the best immediate fit because the list is explicitly about AI-powered
developer tools, includes Claude Code, Google Antigravity, and OpenAI Codex in
its coverage, has an active contribution flow, and is large enough to create
real discovery. At the research snapshot it had 2,094 stars, 682 forks, and
1,493 commits. Its contribution guide asks for a public, well-documented,
developer-useful tool and a one-line entry at the end of the relevant section:

<https://github.com/ai-for-developers/awesome-ai-coding-tools/blob/main/CONTRIBUTING.md>

The second target is
[`hesreallyhim/awesome-claude-code`](https://github.com/hesreallyhim/awesome-claude-code),
which had 54,383 stars and 4,741 forks at the same snapshot. It has much more
reach, but it is deliberately selective, requires a web issue form rather than
a PR, and asks that recommendations be specific to Claude Code. Full Stack HQ
is eligible by age and active development, but acceptance is not guaranteed:

<https://github.com/hesreallyhim/awesome-claude-code/blob/main/CONTRIBUTING.md>

The existing PRs remain useful backlinks, but they are not the main discovery
strategy:

- [`ohong/awesome-coding-ai#21`](https://github.com/ohong/awesome-coding-ai/pull/21)
  is on-topic but the list had only 19 stars and 13 forks at the snapshot.
- [`hztBUAA/awesome-claude-code#8`](https://github.com/hztBUAA/awesome-claude-code/pull/8)
  is even smaller, at 4 stars and 6 forks. It is not a meaningful reach
  channel by itself.
- [`subinium/awesome-claude-code`](https://github.com/subinium/awesome-claude-code)
  explicitly lists only repositories with 1,000+ stars, so it is a future
  target rather than a current submission path.
- [`ccplugins/awesome-claude-code-plugins`](https://github.com/ccplugins/awesome-claude-code-plugins)
  is focused on Claude plugins. Full Stack HQ exposes a portable plugin
  boundary, but the repository is a complete cross-host configuration kit, not
  primarily a plugin.

## Prepared submissions

These drafts are ready for review. They have not been submitted from this
research pass.

### Target 1: `awesome-ai-coding-tools`

Suggested section: **Developer Productivity Tools**.

```markdown
- **[Full Stack HQ](https://github.com/sabahattink/antigravity-fullstack-hq)** – Permission-first, tool-agnostic engineering configuration with shared rules, agents, skills, workflow bridges, and native adapters for Claude Code, Google Antigravity, and OpenAI Codex.
```

### Target 2: `awesome-claude-code`

The maintainer requires the web issue form and does not accept a CLI-created
recommendation or a PR. Suggested values:

| Field | Value |
|---|---|
| Display name | `Full Stack HQ` |
| Category | `Configuration` |
| Link | `https://github.com/sabahattink/antigravity-fullstack-hq` |
| Author name | `sabahattink` |
| Author link | `https://github.com/sabahattink` |

Suggested description:

> Tool-agnostic engineering configuration for Claude Code with a shared permission-first core and native adapters for Claude Code, Google Antigravity, and OpenAI Codex. It includes layered instructions, custom agents, Agent Skills, workflow bridges, installers, dry-runs, backups, and validation.

Submission form:

<https://github.com/hesreallyhim/awesome-claude-code/issues/new?template=recommend-resource.yml>

## What the primary sources show about OpenClaw

### The project was not an overnight OpenAI product

The GitHub API records `openclaw/openclaw` as created on 24 November 2025.
At the 21 September 2026 snapshot it reported 390,184 stars, 82,065 forks,
and 8,278 open issues:

<https://api.github.com/repos/openclaw/openclaw>

The current README describes a concrete product rather than a general prompt
collection: a local personal assistant, one Gateway, many chat channels and
devices, swappable model providers, a guided installer, and an onboarding flow
that ends with a working dashboard:

<https://github.com/openclaw/openclaw/blob/main/README.md>

That distinction matters. People can understand what OpenClaw does and see a
short path from the repository to a visible result. Full Stack HQ is useful,
but its value is currently more architectural: it improves how another coding
host behaves. That is harder to demonstrate in a single screenshot or sentence.

### The creator had an existing technical and distribution surface

Peter Steinberger was not an unknown builder entering the ecosystem for the
first time. His public speaker profile says he founded and bootstrapped PSPDFKit
in 2011 and remained deeply involved in its engineering:

<https://speakerdeck.com/steipete>

His own writing also shows a long-running public practice around AI-assisted
engineering, including talks, workflow posts, and an audience interested in
agentic development:

<https://steipete.me/posts/just-talk-to-it>

This does not mean the stars were bought or fabricated. It means the project
started with product experience, credibility, an existing network, and a
distribution surface that a brand-new account normally does not have.

### The initial growth preceded the OpenAI announcement

In his 14 February 2026 announcement, Steinberger describes OpenClaw as a
“playground project” that had already created a whirlwind during the previous
month. He says the project inspired people around the world, that major labs
were speaking with him, and that he chose OpenAI to bring agents to more people:

<https://steipete.me/posts/2026/openclaw>

The sequence is therefore important:

```text
working product → people sharing it → community and attention → lab interest
→ founder joins OpenAI and the project gains institutional support
```

OpenAI was an amplifier and credibility event after the project had already
become notable. It should not be treated as the explanation for the first
wave of stars.

### What “OpenAI bünyesine girdi” actually means

The verified public description is more precise than “OpenAI bought OpenClaw”:

- Steinberger said he was joining OpenAI to work on bringing agents to
  everyone.
- He said OpenClaw would move to a foundation and stay open and independent.
- The current OpenClaw README says the OpenClaw Foundation is an independent
  501(c)(3), and that OpenAI is a donor rather than the owner.

Sources:

- [Steinberger’s announcement](https://steipete.me/posts/2026/openclaw)
- [OpenClaw README governance section](https://github.com/openclaw/openclaw/blob/main/README.md)
- [OpenClaw GitHub organization](https://github.com/openclaw)

So the accurate shorthand is: **OpenAI hired the creator and supported the
project’s independent foundation; the repository did not simply become an
OpenAI-owned repo.**

## Why the star curve can look sudden

The public sources support a distribution explanation, not a single magic
trick:

1. **A sharply legible promise.** “The AI that really does things” is easier
   to repeat than a long architecture description.
2. **Visible outcomes.** Calendar, messaging, browser, local-device, and
   automation demos create content people can show to other people.
3. **Low activation friction.** OpenClaw gives a platform-aware installer and
   guided onboarding. A curious visitor can reach a working assistant quickly.
4. **A memorable identity.** The lobster, project lore, and community language
   make the project easy to recognize and discuss.
5. **Founder credibility and network.** The project was connected to a builder
   with a previous company, public writing, and an audience already following
   agentic engineering.
6. **Social proof compounding.** Once a project is shared by enough people,
   GitHub discovery, forks, issues, articles, videos, and contributor activity
   reinforce each other.
7. **Institutional signal after the breakout.** The OpenAI announcement made
   the story much larger, but it came after the project had already attracted
   attention.

Stars are a discovery signal, not a direct user count. They do not prove that
all stargazers installed the project, use it regularly, or agree with every
design decision.

## What this means for Full Stack HQ

Full Stack HQ should not imitate OpenClaw’s mascot or create artificial hype.
It should copy the underlying mechanics:

```text
one obvious problem
→ one visible 45-second result
→ one safe command
→ one focused community question
→ real installation evidence
→ curated-list and media discovery
→ repeatable updates
```

The current repository already has several good foundations: native adapters,
dry-runs, backups, validation, first-run recipes, a release, and a durable
technical article. The remaining discovery gap is that the first README view
still asks the visitor to understand an architecture before they experience an
outcome.

Recommended next milestone:

1. Record one clean-checkout demo that shows a Codex dry-run and the generated
   native files in under 45 seconds.
2. Ask for three real installations and host-specific feedback, not generic
   stars.
3. Submit the prepared one-line entry to `awesome-ai-coding-tools`.
4. After the first external feedback, submit the Claude-specific issue form to
   `awesome-claude-code` if the maintainer’s eligibility and distinctness
   criteria still look satisfied.
5. Measure repository visits, clones, forks, issues, discussions, and actual
   installation reports alongside stars.

The objective is not to manufacture a sudden star spike. It is to make the
project easy to understand, easy to try, and easy for another maintainer to
recommend honestly.
