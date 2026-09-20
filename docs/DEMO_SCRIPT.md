# Full Stack HQ 45-second demo script

## Goal

Show the real value of the repository in one short recording:

```text
validate → preview → render native Codex output → inspect the result
```

The recording is a product explanation, not a claim that the repository is a
runtime sandbox. Keep that distinction visible in the caption or final frame.

## Preparation

Start from a clean checkout. Close unrelated browser tabs and terminals. Use a
temporary or isolated target root if the recording shows installation paths.

Windows:

```powershell
pwsh -NoProfile -File .\scripts\validate.ps1
pwsh -NoProfile -File .\install.ps1 -OnlyCodex -DryRun -TargetRoot .\.demo-home
```

macOS/Linux:

```bash
bash scripts/validate.sh
bash install.sh --only-codex --dry-run --target-root ./.demo-home
```

Capture the actual output from the checkout. Do not type illustrative output
over the real command result.

## Shot list

| Time | Shot | On-screen message |
|---:|---|---|
| 0–4s | Title card with terminal visual | One engineering core. Three AI-native hosts. |
| 4–12s | Run the validator | The source and renderers are checked before installation. |
| 12–24s | Run the Codex dry-run | Preview the target paths without changing the real home directory. |
| 24–34s | Show the generated adapter tree | `AGENTS.md`, TOML custom agents, and shared skills. |
| 34–41s | Show architecture visual | Shared policy stays central; host syntax stays at the edge. |
| 41–45s | End card with repository URL | Try a dry-run and report what differs on your host. |

## Voiceover or captions

> Full Stack HQ keeps engineering guidance in one shared core. The installer
> renders native adapters for Claude Code, Antigravity, and Codex. Start with
> validation, preview the change with a dry-run, then inspect the generated
> host files. It is instruction-level guidance, so the host still controls
> tools, approvals, network access, and filesystem permissions.

## Recording rules

- Show real commands and real output.
- Mask usernames, home paths, tokens, and unrelated project names.
- Keep the terminal font large enough for mobile viewing.
- Do not claim that a dry-run proves a real installation succeeded.
- If the architecture image is shown, keep the adapter boundary visible.
- Export a 16:9 version for LinkedIn and a short vertical crop only if the
  text remains readable.
