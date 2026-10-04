# Plugin packages

Full Stack HQ ships two plugin boundaries from the same canonical files:

- a **Claude Code plugin marketplace** in `.claude-plugin/`;
- a **portable OpenAI-style package** in `plugin.json`.

Neither one copies agent, skill, or workflow bodies.

## Claude Code plugin

```text
.claude-plugin/
  marketplace.json   the marketplace, listing one plugin with source "./"
  plugin.json        the plugin manifest; commands point to ./workflows/
hooks/
  hooks.json         SessionStart hook that prints the shared rules
agents/              10 specialist agents, read as-is
skills/              28 Agent Skills, read as-is
workflows/           10 workflows, exposed as /full-stack-hq:<name> commands
```

Install it from inside Claude Code:

```text
/plugin marketplace add sabahattink/antigravity-fullstack-hq
/plugin install full-stack-hq@full-stack-hq
```

The session hook prints `core/rules/common.md` followed by
`adapters/claude/plugin.md`. Claude Code limits the context a hook may inject
to 10,000 characters, so the validators fail when those two files together
exceed 10,000 bytes. Keep the shared rules concise rather than raising that
limit.

The hook command uses `cat`, so it needs the POSIX shell Claude Code runs hooks
with. On Windows that is Git Bash from Git for Windows. The Windows hook path
has not been verified yet; installation reports are welcome.

The plugin and the Claude installer (`--only-claude`) deliver the same
content. Use one of them, not both.

### Checking the Claude plugin locally

```bash
claude plugin validate .claude-plugin/marketplace.json --strict
claude plugin validate .claude-plugin/plugin.json --strict
claude --plugin-dir . # loads the working tree for one session
```

CI runs both `validate` commands on every pull request.

## Portable OpenAI-style package

The portable plugin boundary is in the repository root:

```text
plugin.json
skills/
  <skill-name>/SKILL.md
```

The manifest and the existing canonical `skills/` tree follow the portable
plugin layout documented by OpenAI. This gives plugin-aware hosts a shareable
package without creating a second copy of the engineering guidance.

## What the package contains

- The 28 canonical Agent Skills under `skills/`.
- The same tool-agnostic procedures used by the host installers.
- A small manifest that identifies the package and its current version.

The portable package does not replace the installers. The installers are still
the right path when you want global rules, specialist agents, Antigravity
workflow files, backups, dry-runs, or the generated Codex TOML agents.

## Source-of-truth rule

Edit `skills/<name>/SKILL.md` once. Do not copy skill bodies into a second
plugin directory or add host-specific instructions to the canonical skill.
Keep host paths, invocation syntax, and capability notes in the relevant
adapter instead.

## Local checks before sharing

From the repository root, run the platform-native validator:

```powershell
.\scripts\validate.ps1
```

```bash
bash scripts/validate.sh
```

The validator checks the manifest schema URL, package name, semantic version,
description, and the canonical skill tree before adapter generation begins.

When a release changes the package contract, update `plugin.json`,
`.claude-plugin/plugin.json`, `CHANGELOG.md`, and the versioned release notes
together. The validators require both manifests to carry the same version.
Claude Code only offers an update when that version changes, so bump it for
every release that changes agents, skills, workflows, or rules.

Do not describe the package as listed in a public marketplace unless that
listing has actually been accepted and published.

## References

- [Claude Code plugins](https://code.claude.com/docs/en/plugins)
- [Claude Code plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
- [OpenAI build plugins](https://learn.chatgpt.com/docs/build-plugins)
- [OpenAI build skills](https://learn.chatgpt.com/docs/build-skills)
- [Agent Skills specification](https://agentskills.io/)
