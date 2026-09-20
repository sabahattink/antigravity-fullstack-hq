# Launch announcement pack

> Status: the GitHub Discussion, X launch post, and Dev.to article are
> published. The remaining channel copy is prepared for review; the Dev.to
> media correction is pending the PNG asset push and article update.

## Canonical links

- Repository: https://github.com/sabahattink/antigravity-fullstack-hq
- Latest functional release: https://github.com/sabahattink/antigravity-fullstack-hq/releases/tag/v1.1.0
- GitHub announcement: https://github.com/sabahattink/antigravity-fullstack-hq/discussions/5
- README: https://github.com/sabahattink/antigravity-fullstack-hq/blob/main/README.md
- Long-form article: [`docs/devto-article.md`](devto-article.md)
- Launch playbook: [`docs/LAUNCH_PLAYBOOK.md`](LAUNCH_PLAYBOOK.md)

## Core positioning

Full Stack HQ is a tool-agnostic, permission-first engineering configuration
kit for Claude Code, Google Antigravity IDE, and OpenAI Codex.

The message is simple: one shared engineering core, rendered into native host
formats, with specialist agents, reusable skills, workflow bridges, and safe
cross-platform installers. The same canonical skills are also exposed through
a portable `plugin.json` package boundary.

## Visual assets

Use the visuals in this order when a channel supports images:

| Asset | Best use | Source |
|---|---|---|
| Terminal hero | GitHub README and repository preview | [`hero-terminal.svg`](assets/hero-terminal.svg) |
| Terminal hero | Dev.to cover and external social previews | [`hero-terminal.png`](assets/hero-terminal.png) |
| Architecture | GitHub README and vector-friendly channels | [`architecture.svg`](assets/architecture.svg) |
| Architecture | Dev.to body and external image proxies | [`architecture.png`](assets/architecture.png) |
| Workflow loop | GitHub README and vector-friendly channels | [`workflow-loop.svg`](assets/workflow-loop.svg) |
| Workflow loop | LinkedIn, Dev.to body, and presentations | [`workflow-loop.png`](assets/workflow-loop.png) |

GitHub renders the SVG versions well. For Dev.to and other platforms that
proxy remote images, use the PNG versions: they are more broadly accepted than
repository-hosted SVGs.

The terminal visual is explicitly illustrative. Do not describe it as a raw
captured log unless it is replaced with output from a real clean-checkout run.

## Rollout sequence

| Timing | Channel | Purpose | Status |
|---|---|---|---|
| T+0 | GitHub Discussions | Give the repository a canonical public announcement. | Published |
| T+1 | LinkedIn | Reach the personal technical network with the project story. | Ready below |
| T+1 | X / short social | Share the core idea in a compact thread. | Published; follow-up ready |
| T+2 | Dev.to | Publish the durable technical explanation. | Published; media update pending |
| T+3 | Relevant communities | Invite targeted installation feedback. | Ready below |
| T+7 | GitHub follow-up | Summarize feedback and publish the next milestone. | Pending feedback |

Stagger the posts. It is easier to answer questions and understand which
message resonates when every channel does not publish at the same time.

Lead with a useful problem or demonstration, then place the repository link in
the natural next step. A link alone is an announcement; a short explanation,
real output, and a focused question create a feedback loop.

## LinkedIn post

AI coding tools can move fast. The engineering challenge is keeping intent,
approval, and verification visible while they do.

I built **Full Stack HQ** to make that engineering loop portable across:

- Claude Code
- Google Antigravity IDE
- OpenAI Codex

The project keeps shared behavior in one source of truth and renders only the
host-specific adapter details. It includes:

- 10 specialist agents
- 28 canonical Agent Skills
- 10 reusable workflows and workflow-to-skill bridges
- PowerShell and Bash installers
- dry-run, backup, isolated-target, and validation flows
- first-class Codex `AGENTS.md`, Agent Skills, and TOML custom-agent output
- portable `plugin.json` package for the canonical skills

The intended loop is:

```text
inspect → scope → approval → implement → verify → report
```

This is instruction-level guidance, not a runtime sandbox. The host still
controls tools, approvals, network access, and filesystem permissions.

Repository: https://github.com/sabahattink/antigravity-fullstack-hq

If you use more than one AI coding host, I would especially like to hear where
your shared engineering standards still drift.

Suggested image: `docs/assets/hero-terminal.png`

## X / single-post version

Use this as the complete single post when the account is using the standard
post composer:

```text
AI coding tools move fast. Full Stack HQ brings one engineering core to Claude Code, Google Antigravity, and OpenAI Codex.

Native rules, agents, skills, workflow bridges, and safe installers.

#AIEngineering #AICoding
https://github.com/sabahattink/antigravity-fullstack-hq
```

This is 274 characters before X normalizes the URL. X shortens posted links to
its own t.co URL, so it remains within the standard limit.

Recommended pair for the general launch: `#AIEngineering #AICoding`.
For a Codex-focused follow-up, use `#OpenAICodex #AIEngineering` instead of
repeating the general pair.

## X / thread version

**Post 1/4**

I built Full Stack HQ: one permission-first engineering core for Claude Code,
Google Antigravity IDE, and OpenAI Codex.

#AIEngineering #AICoding

Repository: https://github.com/sabahattink/antigravity-fullstack-hq

**Post 2/4**

The core stays in one place. Thin adapters render the native rules, agents,
skills, and workflows each host understands.

**Post 3/4**

It includes 10 specialist agents, 28 canonical skills, 10 workflow bridges,
PowerShell/Bash installers, dry-runs, backups, isolated targets, and validation.

**Post 4/4**

The goal is a more reviewable engineering loop: inspect → scope → approval →
implement → verify → report. Feedback and corrections are welcome.

## Dev.to publishing package

Use [`docs/devto-article.md`](devto-article.md) as the long-form source.

Suggested title:

> Full Stack HQ: A Permission-First AI Engineering Stack for Claude Code,
> Antigravity, and Codex

Suggested tags:

```text
claudecode, codex, antigravity, devtools
```

Suggested cover: `docs/assets/hero-terminal.png`

Suggested closing question:

> How do you keep rules, skills, and approval workflows consistent when you
> work across more than one AI coding host?

## Community post

Looking for practical feedback from people using Claude Code, Google
Antigravity IDE, or OpenAI Codex.

I maintain Full Stack HQ, an MIT-licensed configuration kit that keeps a
permission-first engineering policy in one shared core and renders native
adapters for all three hosts.

It currently includes specialist agents, reusable skills, workflow bridges,
safe PowerShell/Bash installers, dry-run and backup options, and validation for
generated outputs.

The repository is here:

https://github.com/sabahattink/antigravity-fullstack-hq

If you try it, please report the host, install mode, and whether the generated
rules/agents/skills appeared where expected. I am more interested in concrete
installation feedback than in unqualified praise or artificial star pushes.

## GitHub Discussion follow-up

The first announcement is published at [Discussion #5](https://github.com/sabahattink/antigravity-fullstack-hq/discussions/5).

Use this follow-up after the first useful feedback arrives:

> Thanks for trying Full Stack HQ. I am collecting host-specific installation
> notes and workflow requests before defining the next milestone. The most
> useful details are your host, operating system, selected install mode, and
> the exact file or behavior that differed from expectation.

## Reply kit

### “Is this a sandbox?”

No. Full Stack HQ provides instruction-level workflow guidance. The host still
controls tools, approvals, network access, and filesystem permissions.

### “Why not maintain three separate copies?”

Shared behavior belongs in one source of truth. The adapters are intentionally
thin so host-specific syntax can change without creating policy drift.

### “What is the Codex support?”

The Codex adapter renders layered `AGENTS.md` guidance, Agent Skills, and TOML
custom agents. The repository also exposes a portable `plugin.json` package
for the canonical skills. It warns about an existing `AGENTS.override.md`
without overwriting it.

### “How can I test it safely?”

Run the validator, preview with dry-run, or use `TargetRoot` / `--target-root`
for an isolated home-like installation before touching real host paths.

## Before publishing checklist

- [ ] Open the GitHub README and confirm all three SVG visuals render.
- [ ] Confirm Dev.to and external previews use the PNG visuals.
- [ ] Confirm the post links to the current `main` repository.
- [ ] Run the PowerShell and Bash validators from a clean checkout.
- [ ] Use the channel-specific copy instead of pasting the same block everywhere.
- [ ] Keep claims factual: no invented adoption, performance, or security guarantees.
- [ ] Invite installation feedback and concrete issues.
- [ ] Record the published URL and the first recurring questions.

## Post-publication notes

Record only observed signals:

```text
Date:
Channel:
URL:
Questions:
Installation issues:
Requested agents/skills/workflows:
```
