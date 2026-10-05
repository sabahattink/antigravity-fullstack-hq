# Frequently asked questions

Short answers to the questions people most often ask about Full Stack HQ. Each
answer links to the guide with the details.

## What is Full Stack HQ?

Full Stack HQ is an open-source, MIT-licensed engineering configuration kit for
AI coding agents. It keeps one shared set of engineering rules, 10 specialist
agents, 28 Agent Skills, and 10 workflows in a single repository, then renders
them into the native formats of Claude Code, OpenAI Codex, and Google
Antigravity IDE.

The repository is named `antigravity-fullstack-hq`; the Claude Code plugin is
named `full-stack-hq`.

## How do I stop an AI coding agent from editing files without asking?

Full Stack HQ's shared rules tell the agent to follow
**Plan → Approval → Execute → Verify → Report**. The agent inspects the project
and proposes a plan, then starts executing only when your message contains one
of these exact phrases:

```text
PLAN APPROVED
IMPLEMENTATION APPROVED
PROCEED
DO IT
```

A vague reply such as "sounds good" does not count as approval. The rules are
in [`core/rules/common.md`](../core/rules/common.md).

These are instructions to the agent, not a sandbox. To *enforce* limits, also
use your host's own permission and sandbox settings.

## How do I share one set of rules between Claude Code, Codex, and Antigravity?

Edit the shared policy once in `core/rules/common.md`. The installers append a
small host adapter and write each host's native file:

| Host | Global rules | Agents | Skills |
|---|---|---|---|
| Claude Code | `~/.claude/CLAUDE.md` | `~/.claude/agents/` | `~/.claude/skills/` |
| OpenAI Codex | `~/.codex/AGENTS.md` | `~/.codex/agents/*.toml` | `~/.agents/skills/` |
| Google Antigravity IDE | `~/.gemini/GEMINI.md` | `~/.gemini/config/agents/` | `~/.gemini/config/skills/` |

Because every host file is generated from the same source, the copies do not
drift apart. See the [customization guide](CUSTOMIZATION.md).

## What is the difference between CLAUDE.md, AGENTS.md, and GEMINI.md?

They are the global instruction files that different hosts read:

- `CLAUDE.md` is read by Claude Code.
- `AGENTS.md` is read by OpenAI Codex, which also layers project `AGENTS.md`
  files from the Git root down to the working directory.
- `GEMINI.md` is read by Google Antigravity IDE.

Full Stack HQ generates all three from one source, so you do not maintain three
hand-written copies.

## How do I install it as a Claude Code plugin?

Run these two commands inside Claude Code, then start a new session:

```text
/plugin marketplace add sabahattink/antigravity-fullstack-hq
/plugin install full-stack-hq@full-stack-hq
```

The shared rules load at session start, the agents and skills become available,
and the workflows appear as commands such as `/full-stack-hq:plan`. See
[PLUGIN.md](PLUGIN.md).

## Can I try it without changing my configuration?

Yes. Every installer path has a dry-run that writes nothing:

```bash
curl -fsSL https://raw.githubusercontent.com/sabahattink/antigravity-fullstack-hq/main/bootstrap.sh | bash -s -- --dry-run
```

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/sabahattink/antigravity-fullstack-hq/main/bootstrap.ps1))) -DryRun
```

To test real writes safely, add `--target-root ./demo-home` (Bash) or
`-TargetRoot .\demo-home` (PowerShell) so files go to an isolated directory.
See [first-run recipes](FIRST_RUN.md).

## Does it work on Windows?

Yes. The PowerShell installer, validator, and smoke tests run on Windows in CI
on every pull request. The Claude Code plugin's session hook uses `cat`
through the Git Bash shell that Claude Code uses on Windows; that path has not
been verified on native Windows yet, so installation reports are welcome.

## Should I use the Claude Code plugin or the installer?

Use one of them for Claude Code, not both; together they load the same rules,
agents, and skills twice.

- The **plugin** is the quickest path and updates with
  `claude plugin update full-stack-hq@full-stack-hq`.
- The **installer** writes plain files into `~/.claude/` that you can edit, and
  it also covers Codex and Antigravity.

## How much context does it add?

The shared rules are about 10 KB of text, loaded at the start of each session.
In Claude Code and Codex, agent and skill bodies load only when they are used;
until then the host sees only their short descriptions.

## Can I add my own rules, agents, or skills?

Yes. Change the source files (`core/rules/common.md`, `agents/`, `skills/`,
`workflows/`), run the validator, and reinstall the hosts you use. The
[customization guide](CUSTOMIZATION.md) explains where each change belongs so
host files stay in sync.

## How do I uninstall it?

For the Claude Code plugin:

```bash
claude plugin uninstall full-stack-hq@full-stack-hq
```

The installers do not delete files automatically, because global instruction
files may contain your own edits. Remove the installed files manually after
reviewing them; see [Uninstallation](SETUP.md#uninstallation).

## Is it a security boundary?

No. Full Stack HQ is guidance that the agent is asked to follow. The host still
decides which tools run, what needs approval, and what the sandbox allows. See
the [security policy](../SECURITY.md).
