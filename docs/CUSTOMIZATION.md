# Customization Guide

Full Stack HQ has one shared policy core and small host adapters. Customize the
repository source, render the adapters, validate, then reinstall the selected
host.

## Source of truth

- Shared policy: core/rules/common.md
- Host-specific details: adapters/claude/rules.md,
  adapters/antigravity/rules.md, and adapters/codex/rules.md
- Specialist agents: agents/*.md
- Reusable skills: skills/<name>/SKILL.md
- Workflows: workflows/*.md

The files under claude/CLAUDE.md and gemini/GEMINI.md are compatibility
snapshots. They are generated outputs, not the preferred place for permanent
changes.

Render snapshots after changing rules:

    PowerShell: .\scripts\build-adapters.ps1 -SyncSnapshots
    Bash:       bash scripts/build-adapters.sh --sync-snapshots

Then validate:

    PowerShell: .\scripts\validate.ps1
    Bash:       bash scripts/validate.sh

## Change shared rules

Edit core/rules/common.md for behavior that must be consistent across all
hosts. Keep it concise because Antigravity global rule files have a documented
character limit.

Use the adapter files only for differences such as:

- native file discovery paths
- invocation syntax
- host-specific agent/skill formats
- sandbox, approval, model, or MCP capability notes

Do not add a host-specific command or path to a canonical agent or skill body.

## Add or update an agent

Create or edit agents/my-agent.md:

    ---
    name: my-agent
    description: Clear description. Use when a task matches this responsibility.
    ---

    # My Agent

    You are a specialist for one narrow responsibility.

    ## Guiding principles
    - State assumptions.
    - Cite evidence.
    - Report uncertainty.

    ## What I do not do
    - Do not expand the scope without approval.

The Markdown file is the canonical agent body. Claude Code and Antigravity
consume it directly. The adapter renderer converts it to Codex custom-agent
TOML with name, description, and developer_instructions.

Agent names must match the filename and use lowercase letters, numbers, and
hyphens.

## Add or update a skill

Create or edit skills/my-skill/SKILL.md:

    ---
    name: my-skill
    description: Explain exactly when this skill should and should not trigger.
    ---

    # My Skill

    ## Use this skill when
    - ...

    ## Do not use it when
    - ...

    ## Instructions
    - ...

Skills use the open Agent Skills shape: a directory containing SKILL.md, with
optional scripts, references, and assets. Keep the description specific so
implicit activation is reliable on hosts that support it.

Host-native locations after installation:

- Antigravity: ~/.gemini/config/skills/
- Claude Code: ~/.claude/skills/
- Codex: ~/.agents/skills/

For project-specific behavior, prefer a repository-local .agents/skills/
directory so Codex and modern Antigravity can discover the same skill.

## Add or update a workflow

Edit workflows/my-workflow.md:

    ---
    name: my-workflow
    description: What it does and when to use it.
    command: /my-workflow
    ---

    # My Workflow

    ## Purpose
    ...

    ## Process
    1. Inspect the current state.
    2. Present a plan and wait for approval.
    3. Execute only the approved slice.
    4. Verify and report.

Workflows remain the canonical source for the legacy Antigravity loader. The
build adapter also removes the command metadata and renders each workflow as a
skill so Claude Code, Codex, and modern Antigravity can use the same procedure.

Use command metadata consistently. Do not mix command and trigger fields.

## Host-specific customization

### Google Antigravity IDE

- Global rules: ~/.gemini/GEMINI.md
- Global agents: ~/.gemini/config/agents/
- Global skills: ~/.gemini/config/skills/
- Legacy workflows: ~/.gemini/config/workflows/

For project-local rules, agents, and skills use the current .agents/ layout.
The installer refreshes an existing ~/.gemini/antigravity/ tree only as an
upgrade bridge.

### Claude Code

- Global rules: ~/.claude/CLAUDE.md
- Global agents: ~/.claude/agents/
- Global skills: ~/.claude/skills/

Claude Code supports native Markdown agents and skills. Keep their bodies
portable; use the Claude adapter for host-only notes.

### OpenAI Codex

- Global rules: ~/.codex/AGENTS.md
- Global custom agents: ~/.codex/agents/
- Global skills: ~/.agents/skills/
- Project custom agents: .codex/agents/
- Project skills: .agents/skills/

Codex loads layered AGENTS.md guidance from the Codex home and repository
directories. A repository root AGENTS.md can document contribution and
verification rules without being installed as a global file.

If AGENTS.override.md exists in the active Codex home, it takes precedence over
the global AGENTS.md. The installer does not replace it; keep overrides small
and review them when shared policy changes.

Codex custom-agent files are TOML. Do not hand-copy Markdown into a TOML file;
run the adapter builder so metadata and multiline instructions stay synchronized.

## One-off installed changes

For a local experiment, you may edit the installed host file directly and
restart the host. For a reusable change, edit the repository source, render,
validate, and reinstall with DryRun first.
