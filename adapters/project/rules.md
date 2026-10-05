# Project adapter

This adapter is appended to the shared policy when Full Stack HQ is installed
into a repository with the installer's project option.

## Native integration

- This `AGENTS.md` is the repository's shared instruction source. Codex,
  Cursor, and GitHub Copilot read it directly; the repository's `CLAUDE.md`
  and `GEMINI.md` import it, so every host follows the same rules.
- The installer owns only the block between the `full-stack-hq:start` and
  `full-stack-hq:end` markers and replaces it on every run. Put
  repository-specific instructions outside that block; they are preserved.
- Nested `AGENTS.md` files in subdirectories may add narrower rules for that
  part of the tree. Keep the combined guidance concise.
