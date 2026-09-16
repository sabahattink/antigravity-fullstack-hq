# Full Stack HQ core

The existing top-level directories are intentionally kept as the public source
layout for compatibility:

| Core module | Source path | Purpose |
|---|---|---|
| Rules | `core/rules/` | Host-neutral operating policy |
| Agents | `agents/` | Canonical Markdown agent bodies |
| Skills | `skills/` | Canonical Agent Skills |
| Workflows | `workflows/` | Canonical workflow bodies and legacy bridge |

The integration seam is `adapters/`. An adapter translates the same core into a
host's native format and invocation model. It should not duplicate domain
guidance.

## Adapter outputs

`scripts/build-adapters.ps1` and `scripts/build-adapters.sh` render temporary
adapter output:

```text
<output>/claude/CLAUDE.md
<output>/antigravity/GEMINI.md
<output>/codex/AGENTS.md
<output>/codex/agents/*.toml
<output>/workflow-skills/*/SKILL.md
```

The generated files are install artifacts. Edit the core or adapter source,
then render again; do not hand-edit generated snapshots.
