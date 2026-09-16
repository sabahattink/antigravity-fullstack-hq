# Claude Code adapter

This adapter is appended to the shared policy when rendering
`~/.claude/CLAUDE.md`.

## Native integration

- Reusable specialist agents are Markdown files in `~/.claude/agents/`.
- Reusable skills are directories containing `SKILL.md` in `~/.claude/skills/`.
- Use Claude's native agent and skill selectors. The shared workflow names are
  available as skills and may be invoked with the host's slash-command UI.
- Do not assume that a tool name, permission mode, or MCP server exists merely
  because another host exposes a similarly named capability.
- Project-local instructions remain the closest source of truth for that
  project; do not overwrite them with global defaults.
