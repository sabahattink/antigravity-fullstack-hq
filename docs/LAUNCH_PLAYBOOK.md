# Full Stack HQ launch playbook

> Purpose: turn a repository announcement into a repeatable discovery and
> feedback loop.
>
> This is a reviewable launch plan. It does not auto-publish, manufacture
> engagement, or claim adoption that has not been observed.

## Launch objective

The first milestone is not a large star count. It is evidence that real users
can install the kit and explain what differed on their host.

For the first 14 days, use these working targets:

- 5 real installations
- 3 host-specific feedback reports
- 1 useful issue, discussion, or pull request from an external user
- 1 repeatable demo that a new visitor can understand in under one minute

These are targets, not results. Record observed values separately.

## One-sentence positioning

Full Stack HQ keeps permission-first engineering guidance in one shared core
and renders native adapters for Claude Code, Google Antigravity IDE, and
OpenAI Codex.

## The problem to lead with

AI coding hosts can generate code quickly. The harder problem is keeping scope,
approval, specialist routing, and verification visible across tools.

Lead with that problem. The counts of agents and skills are supporting proof,
not the headline.

## Audience slices

| Audience | Their question | Best call to action |
|---|---|---|
| Codex users | Can this fit native `AGENTS.md`, skills, and custom agents? | Try `--only-codex --dry-run` and report the generated paths. |
| Claude Code users | Can shared rules travel without copying policy by hand? | Compare the generated `CLAUDE.md`, agents, and skills with the current setup. |
| Antigravity users | Does the existing workflow remain usable? | Test the adapter and report workflow or rule differences. |
| Maintainers | Can the policy stay readable and reviewable? | Review the source-to-host contract and propose one improvement. |

## Canonical assets

| Asset | Use | Link |
|---|---|---|
| Repository | Primary conversion target | <https://github.com/sabahattink/antigravity-fullstack-hq> |
| Release | Stable starting point | <https://github.com/sabahattink/antigravity-fullstack-hq/releases/tag/v1.1.0> |
| GitHub announcement | Long-lived discussion | <https://github.com/sabahattink/antigravity-fullstack-hq/discussions/5> |
| Technical article | Durable explanation | `docs/devto-article.md` |
| Terminal visual | Hero and cover | `docs/assets/hero-terminal.png` |
| Architecture visual | Technical explanation | `docs/assets/architecture.png` |
| Workflow visual | Short demo and article body | `docs/assets/workflow-loop.png` |

Use PNGs for Dev.to and external image proxies. Keep SVGs for the GitHub
README and vector-friendly surfaces.

## Seven-day rollout

### Day 0 — publishable baseline

- Push the PNG assets and the updated article source.
- Run both validators from a clean checkout.
- Confirm the raw PNG URLs return image content.
- Update the Dev.to article and verify both the cover and body images.
- Open the GitHub README in a signed-out or private window and check the main
  links and visuals.

### Day 1 — native X post

Publish the short post without making the repository link the entire message.
Put the repository in the first reply together with the dry-run command.

### Day 2 — LinkedIn explanation

Use the terminal visual. Explain the engineering problem, the shared-core
architecture, and the limitation: this is instruction-level guidance, not a
runtime sandbox.

### Day 3 — Dev.to article

Publish or update the article only after the PNG URLs are live. Reply to the
article with one concrete installation command and invite host-specific notes.

### Day 4 — one targeted community

Choose one relevant community where configuration, AI coding workflows, or
open-source maintenance is already discussed. Ask for installation feedback,
not stars. Do not paste the same announcement into several communities on the
same day.

### Day 5 — technical follow-up

Publish a small lesson from the build, such as why a shared core needs thin
adapters or how Codex custom-agent output differs from a generic Markdown
agent file.

### Day 7 — feedback checkpoint

Summarize observed questions in GitHub Discussions. Convert repeated questions
into README or setup documentation. Only then decide the next feature or
release milestone.

## Copy-ready X sequence

### Main post

```text
AI coding agents can generate code quickly. The harder part is keeping scope, approval, and verification visible.

I built Full Stack HQ: one permission-first engineering core for Claude Code, Google Antigravity, and OpenAI Codex.

Native rules, agents, skills, workflow bridges, and safe installers.

#AIEngineering #AICoding
```

### First reply

```text
Try it safely first:

./install.sh --only-codex --dry-run

PowerShell: .\install.ps1 -OnlyCodex -DryRun

Repository: https://github.com/sabahattink/antigravity-fullstack-hq
```

### Follow-up question

```text
If you use more than one AI coding host, where does your shared engineering policy drift first: rules, agents, skills, or workflows?
```

Use no more than two hashtags in a post. Keep the question focused and answer
replies with concrete host-specific details.

## Copy-ready LinkedIn post

```text
AI coding tools move fast. The engineering challenge is keeping intent,
approval, and verification visible while they do.

I built Full Stack HQ to make that workflow portable across Claude Code,
Google Antigravity IDE, and OpenAI Codex.

The design is simple:

one shared engineering core
thin native adapters
specialist agents and reusable skills
workflow bridges
dry-runs, backups, and validation

This is not a runtime sandbox or a security boundary. The host still controls
tools, approvals, network access, and filesystem permissions.

The useful test is whether the same engineering intent remains reviewable when
the AI host changes.

Repository: https://github.com/sabahattink/antigravity-fullstack-hq

If you use more than one AI coding host, where does your configuration drift?
```

Suggested image: `docs/assets/hero-terminal.png`.

## Copy-ready community post

```text
I am looking for installation feedback on Full Stack HQ, an MIT-licensed
configuration kit for Claude Code, Google Antigravity IDE, and OpenAI Codex.

It keeps permission-first engineering guidance in one shared core and renders
native host adapters. The repository includes specialist agents, reusable
skills, workflow bridges, PowerShell/Bash installers, dry-run and backup
options, and validation.

Repository:
https://github.com/sabahattink/antigravity-fullstack-hq

If you try it, please report:
- host and operating system
- selected install mode
- whether the generated files appeared where expected
- the first confusing or missing behavior

Concrete installation feedback is more useful than a generic endorsement.
```

## 45-second demo

Use [DEMO_SCRIPT.md](DEMO_SCRIPT.md) as the recording brief. The demo should
show an actual clean-checkout validation and a Codex dry-run, not invented
terminal output.

The viewer should understand this sequence:

```text
one source of truth → native adapter → safe preview → verifiable result
```

Mask local usernames and home paths. Use an isolated `-TargetRoot` when the
demo needs to show generated files. Do not display tokens, private repository
URLs, or personal browser tabs.

## Reply kit

### “Is this a sandbox?”

No. It provides instruction-level workflow guidance and generated host files.
The host still controls tools, approvals, sandboxing, network access, and
filesystem behavior.

### “Why not keep three separate copies?”

Shared behavior belongs in one source of truth. Thin adapters carry only the
syntax and paths that genuinely vary, which makes policy drift easier to see.

### “How do I test without changing my real setup?”

Run the validator, use `--dry-run`, or pass an isolated `--target-root` /
`-TargetRoot` path before installing into real host directories.

### “What should I report?”

The host, operating system, command used, expected path, actual path, and the
smallest reproducible difference. Remove secrets and tokens from logs.

## Measurement sheet

Copy this table into the launch notes and fill only observed values:

| Date | Channel | Impressions | Profile visits | Link clicks | GitHub unique visitors | Clones | Stars | Feedback | Notes |
|---|---:|---:|---:|---:|---:|---:|---:|---|---|
|  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |

Interpret signals carefully:

- Views are not installations.
- Clones are not necessarily unique people.
- Stars are a weak signal without installation or discussion evidence.
- A useful issue, reproducible report, or pull request is stronger evidence of
  product value than a single spike in impressions.

## Release gate

Before calling the launch ready:

- [ ] `git diff --check` passes.
- [ ] `scripts/validate.ps1` and `scripts/validate.sh` pass.
- [ ] GitHub README SVGs render.
- [ ] Dev.to uses the PNG URLs, not the SVG URLs.
- [ ] The repository, release, and discussion links resolve.
- [ ] The demo uses real output or labels illustrative content clearly.
- [ ] No adoption, security, or performance claim lacks evidence.
- [ ] The installation-feedback issue template is available.
- [ ] The first follow-up question is ready before the first post goes live.

## What not to do

- Do not buy or manufacture stars, forks, comments, or traffic.
- Do not mass-post identical copy into unrelated communities.
- Do not describe guidance as a sandbox or hard permission boundary.
- Do not call a clone, view, or like a successful installation.
- Do not publish broken media and hope the platform repairs it later.
