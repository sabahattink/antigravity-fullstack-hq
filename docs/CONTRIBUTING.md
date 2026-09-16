# Contributing Guide

Thank you for contributing to Full Stack HQ.

This repository is a cross-host configuration kit. The highest-value changes
improve the shared core once and keep each adapter thin.

## Before opening a change

1. Read the current README and core/README.md.
2. Decide whether the behavior belongs in core/rules, an agent, a skill, a
   workflow, or a host adapter.
3. Keep the public top-level agents/, skills/, and workflows/ paths intact.
4. Run the platform-native validator.
5. Update setup/customization documentation and CHANGELOG.md when behavior or
   supported hosts change.

## Source layout

| Change | Preferred location |
|---|---|
| Shared operating policy | core/rules/common.md |
| Host-specific paths or invocation | adapters/<host>/rules.md |
| Specialist role | agents/<name>.md |
| Reusable domain guidance | skills/<name>/SKILL.md |
| Reusable procedure | workflows/<name>.md |
| Installer behavior | install.ps1 and install.sh |
| Adapter generation | scripts/build-adapters.ps1 and .sh |
| Validation | scripts/validate.ps1 and .sh |

Do not duplicate a shared agent or skill body for each host. If two hosts need
different metadata, keep the shared body in the core and put the metadata in
the adapter.

## Adding an agent

Agent files must:

- be Markdown with YAML frontmatter
- contain name and description
- use a lowercase hyphenated name matching the filename
- explain the responsibility, decision criteria, output format, and exclusions
- avoid host-specific paths and tool names

The builder converts the Markdown body into Codex TOML. Keep the body free of
the TOML multiline delimiter triple single quotes.

## Adding a skill

Skill directories must contain SKILL.md with name and description in
frontmatter. Descriptions should say when the skill activates and when it
should not. Prefer progressive disclosure: keep the entrypoint focused and
place long references, assets, or helper scripts beside it.

A skill should contain real, reusable guidance rather than a generic persona.
Do not put credentials, private data, or unverifiable claims in examples.

## Adding a workflow

Workflow files use consistent metadata:

    ---
    name: workflow-name
    description: What the workflow does and when to use it.
    command: /workflow-name
    ---

The command field is retained for Antigravity's legacy workflow loader. The
adapter builder strips it when producing a skill for Claude Code, Codex, and
modern Antigravity.

## Installer changes

Installers must:

- support Windows PowerShell and Bash behavior consistently
- preserve selective host installation
- support dry-run before writing targets
- keep existing files unless Force is explicitly selected
- support Backup for replaced files
- support an isolated TargetRoot / --target-root smoke-test mode
- avoid deleting unrelated files, branches, or remote state
- use current documented host paths while preserving an existing Antigravity
  legacy tree as an opt-in compatibility bridge

Test installers against temporary target directories or dry-run output. Do not
use a real personal configuration directory in automated checks.

## Verification

Run both validators when possible:

    .\scripts\validate.ps1
    bash scripts/validate.sh

Also review:

- git diff --check
- generated Codex agent count
- generated workflow skill count
- rule file size for Antigravity
- accidental host-specific references in canonical agents and rules
- docs and changelog consistency

The GitHub Actions validation job runs the platform-native validator on Windows
and Ubuntu.

## Commit and pull request conventions

Use Conventional Commits:

- feat: new capability
- fix: behavior correction
- refactor: structural change
- docs: documentation only
- test: verification changes
- chore: maintenance
- ci: automation

A pull request should explain the user-facing outcome, list affected hosts,
describe compatibility impact, and include the verification commands that ran.

## Scope boundaries

Do not push, deploy, create branches, or publish releases as part of a local
change. Those are maintainer decisions outside the installer and validator
scope.
