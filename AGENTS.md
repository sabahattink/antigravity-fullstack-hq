# Full Stack HQ repository instructions

This repository is a configuration and documentation kit. It has no application
runtime, package manager, or production service to deploy.

## Source of truth

- `core/rules/common.md` contains host-neutral engineering policy.
- `adapters/<host>/rules.md` contains only host-specific integration guidance.
- `agents/` contains canonical Markdown agent bodies.
- `skills/` contains canonical Agent Skills.
- `workflows/` contains canonical workflow bodies and the Antigravity legacy bridge.
- `scripts/build-adapters.*` renders Codex TOML agents and workflow-to-skill adapters.

Do not create separate copies of shared agent or skill instructions for each
host. Put shared behavior behind the smallest useful interface and keep host
differences in an adapter.

## Verification

Run the platform-native validator before proposing a release:

```text
PowerShell: .\scripts\validate.ps1
Bash:       bash scripts/validate.sh
```

The validator must pass on Windows and Linux. Installers should be tested with
their dry-run option and must not push, create branches, or deploy.

## Change discipline

- Keep the existing top-level `agents/`, `skills/`, and `workflows/` paths for
  compatibility.
- Update README, setup/customization docs, and `CHANGELOG.md` when behavior or
  supported hosts change.
- Do not put host-specific tool names, paths, or commands in canonical agent
  and skill bodies unless the example is explicitly about that host.
- Prefer additive migration bridges over deleting legacy installation paths.
