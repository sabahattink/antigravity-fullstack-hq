# First-run recipes

These recipes are deliberately small and reversible. They help you evaluate
Full Stack HQ before changing a real host configuration.

## 1. Preview one host

Start with the host you use most often. A dry-run validates the repository and
shows the target paths without writing to your real home directory.

### Windows PowerShell

```powershell
.\install.ps1 -OnlyCodex -DryRun -TargetRoot .\.demo-home
.\install.ps1 -OnlyClaude -DryRun -TargetRoot .\.demo-home
.\install.ps1 -OnlyAntigravity -DryRun -TargetRoot .\.demo-home
```

### macOS/Linux

```bash
bash install.sh --only-codex --dry-run --target-root ./.demo-home
bash install.sh --only-claude --dry-run --target-root ./.demo-home
bash install.sh --only-antigravity --dry-run --target-root ./.demo-home
```

Use one host option at a time. Compare the generated paths with the host
contract in the [setup guide](SETUP.md).

## 2. Exercise all three adapters in isolation

This smoke test writes to a disposable temporary home, checks the generated
rules, agents, skills, and workflows, and removes the temporary target when it
finishes.

```powershell
.\scripts\smoke-test.ps1
```

```bash
bash scripts/smoke-test.sh
```

This is the best first check when you maintain a shared configuration for more
than one AI coding host.

## 3. Diagnose an existing setup

The doctor is read-only. It checks host commands, target paths, active Codex
home selection, and `AGENTS.override.md` precedence.

```powershell
.\scripts\doctor.ps1
.\scripts\doctor.ps1 -OnlyCodex -TargetRoot .\.demo-home
```

```bash
bash scripts/doctor.sh
bash scripts/doctor.sh --only-codex --target-root ./.demo-home
```

Warnings about a missing host executable are useful evidence, not a reason to
modify the machine before you understand the target environment.

## 4. Report what actually happened

Open the [installation feedback form](https://github.com/sabahattink/antigravity-fullstack-hq/issues/new?template=installation_feedback.md)
and include:

- host and operating system;
- Full Stack HQ version or commit;
- the exact install or diagnostic mode;
- expected versus actual paths or behavior;
- a redacted log excerpt or screenshot.

Do not include tokens, credentials, private repository URLs, or personal data.
An unsuccessful dry-run or a confusing path is valuable feedback too.
