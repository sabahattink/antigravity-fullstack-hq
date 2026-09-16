## What does this PR do?

<!-- Brief description of the change -->

## Type of change

- [ ] New skill
- [ ] New workflow
- [ ] Agent improvement
- [ ] Codex adapter / installer
- [ ] Antigravity or Claude adapter
- [ ] Bug fix
- [ ] Documentation
- [ ] Other

## Checklist

- [ ] Skill/workflow follows the existing format (frontmatter + sections + code examples)
- [ ] Content is genuinely useful — real patterns, real code
- [ ] No hardcoded secrets or sensitive data
- [ ] Ran `bash scripts/validate.sh` or `scripts/validate.ps1`
- [ ] Tested the affected installer path with `--dry-run` / `-DryRun`
- [ ] Used `--target-root` / `-TargetRoot` for any write smoke test
- [ ] Updated README/setup docs and CHANGELOG when behavior changed

## For new skills

- [ ] File is at `skills/[name]/SKILL.md`
- [ ] Frontmatter includes `name` and `description`
- [ ] Has at least one code example
- [ ] Has a "Forbidden Patterns" section

## Notes

<!-- Anything reviewers should know -->
