# OpenAI Codex adapter

This adapter is appended to the shared policy when rendering
`~/.codex/AGENTS.md`.

## Native integration

- Codex loads global guidance from `CODEX_HOME/AGENTS.md` (or
  `~/.codex/AGENTS.md`) and layered repository guidance from the Git root to
  the working directory. Each applicable directory contributes at most one
  instruction file; use `AGENTS.override.md` in that directory to replace its
  `AGENTS.md`.
- At the global scope, `AGENTS.override.md` takes precedence over
  `AGENTS.md`; the installer leaves that override untouched. Keep the combined
  project guidance concise because the default instruction budget is 32 KiB.
- If a team configures fallback instruction filenames, Codex can discover
  those names too; do not rely on a fallback name when publishing this kit.
- Repository skills use `.agents/skills/<name>/SKILL.md`; user skills use
  `~/.agents/skills/<name>/SKILL.md`. Shared workflows are rendered as skills,
  not as a separate workflow directory.
- Custom subagents use one TOML file per agent in `~/.codex/agents/` or a
  project-local `.codex/agents/` directory. The adapter supplies the required
  `name`, `description`, and `developer_instructions` fields from the canonical
  Markdown agent.
- Invoke a skill with Codex's skill selector or `$skill-name`. Do not depend on
  deprecated custom prompts for repository-shared behavior.
- Sandbox mode, approval policy, network access, MCP availability, model choice,
  and subagent concurrency are host settings. Prompt rules describe intent but
  do not replace those controls.
