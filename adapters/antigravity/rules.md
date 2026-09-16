# Google Antigravity IDE adapter

This adapter is appended to the shared policy when rendering
`~/.gemini/GEMINI.md`.

## Native integration

- Global rules live in `~/.gemini/GEMINI.md`.
- Current global agent and skill locations are under
  `~/.gemini/config/agents/` and `~/.gemini/config/skills/`.
- Legacy workflow files are kept under `~/.gemini/config/workflows/` while the
  host transitions workflow behavior to Agent Skills.
- Workspace-specific rules, agents, and skills should use the host's current
  `.agents/` layout when a project needs local overrides.
- Treat host tool names, command execution policies, and model selectors as
  adapter details; shared agents and skills must remain portable.
