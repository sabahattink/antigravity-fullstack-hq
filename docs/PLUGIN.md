# Portable plugin package

Full Stack HQ has a portable plugin boundary in the repository root:

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
`CHANGELOG.md`, and the versioned release notes together. Do not describe the
package as listed in a public marketplace unless that listing has actually
been accepted and published.

## References

- [OpenAI build plugins](https://learn.chatgpt.com/docs/build-plugins)
- [OpenAI build skills](https://learn.chatgpt.com/docs/build-skills)
- [Agent Skills specification](https://agentskills.io/)
